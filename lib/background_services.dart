import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/secrets/supabase_secret.dart';
import 'package:http/http.dart' as http;

// final SupabaseClient client = serviceLocator<SupabaseClient>();
const notiChannelId = 'location_service';
const nottiChannelName = 'Background Location Tracking';
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notiChannelId, // id
    nottiChannelName, // title
    description:
        'This channel is used for sharing location between member of trip', // description
    importance: Importance.max,
  );
  const AndroidNotificationChannel channelNoti = AndroidNotificationChannel(
    'app_background_noti', // id
    'App Background Notifications', // title
    description:
        'This channel is used for app background notifications', // description
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // void notificationTapBackground(NotificationResponse notificationResponse) {
  //   if (notificationResponse.actionId == 'stop_service') {
  //     FlutterBackgroundService().invoke('stopListen');
  //   }
  // }

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
      onDidReceiveNotificationResponse: notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackgroundAction,
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channelNoti);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,
      autoStart: true,
      isForegroundMode: false,
      notificationChannelId: notiChannelId,
      autoStartOnBoot: true,
      initialNotificationTitle: 'Chia sẻ vị trí',
      initialNotificationContent: 'Khởi động dịch vụ chia sẻ vị trí',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
void notificationTapBackground(
    NotificationResponse notificationResponse) async {
  WidgetsFlutterBinding.ensureInitialized();

  DartPluginRegistrant.ensureInitialized();
  log('notification tap type redirect${notificationResponse.payload}');

  // FlutterBackgroundService().invoke('newNotification');
  if (notificationResponse.payload == 'notification') {
    FlutterBackgroundService().invoke('redirectNoti');
  }
}

@pragma('vm:entry-point')
void notificationTapBackgroundAction(
    NotificationResponse notificationResponse) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // Handle the background notification tap
  // For example, unsubscribe from the position channel
  log('notification tap background task');
  if (notificationResponse.actionId == 'stop_listen') {
    // await FlutterLocalNotificationsPlugin().cancel(888);
    FlutterBackgroundService().invoke('stopListen');
  }
  // FlutterBackgroundService().invoke('stopListen');
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  log('Background service started');
  final supabase = await Supabase.initialize(
    url: SupabaseSecret.supabaseUrl, // Replace with your Supabase URL
    anonKey: SupabaseSecret.supabaseKey, // Replace with your Supabase anon key
  );
  final SupabaseClient client = supabase.client;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? channelName;
  RealtimeChannel positionChannel = client.channel('position');

  // Stream<Position>? positionStream;
  if (service is AndroidServiceInstance) {
    final user = client.auth.currentUser;
    if (user == null) {
      log('User is null');
      // return;
    }
    client
        .channel('background_noti_receiver:${user?.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: user != null
              ? PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'receiver_id',
                  value: user.id,
                )
              : null,
          callback: (payload) async {
            log('new notification');
            final event = payload.eventType;
            final data = payload.newRecord;
            final sender = data['sender_id'] != null
                ? await client
                    .from('profiles')
                    .select('first_name,avatar_url')
                    .eq('id', data['sender_id'])
                    .maybeSingle()
                : null;
            final trip = data['trip_id'] != null
                ? await client
                    .from('trips')
                    .select('name,cover')
                    .eq('id', data['trip_id'])
                    .maybeSingle()
                : null;
            service.invoke('newNotification', {
              'eventType': payload.eventType == PostgresChangeEvent.update
                  ? 'update'
                  : 'insert',
              'newRecord': data,
            });
            if (event == PostgresChangeEvent.insert) {
              // check avatar_url maybe null

              final http.Response response = await http.get(Uri.parse(sender !=
                      null
                  ? sender['avatar_url'] ??
                      "https://dovercourt.org/wp-content/uploads/2019/11/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.jpg"
                  : trip!['cover']));
              flutterLocalNotificationsPlugin.show(
                data['id'],
                sender != null
                    ? "Thông báo từ ${sender['first_name']}"
                    : "Thông báo từ ${trip!['name']}",
                data['type'] != "trip_update"
                    ? "${sender != null ? "${sender['first_name']}" : ""} ${data['content']} ${trip != null ? "${trip['name']}" : ""}"
                    : "${trip != null ? "${trip['name']}" : ""} ${data['content']}",
                payload: 'vntravelcompanion://app/notifications',
                NotificationDetails(
                  android: AndroidNotificationDetails(
                    'app_background_noti',
                    'App Background Notifications',
                    icon: 'ic_bg_service_small',
                    importance: Importance.max,
                    channelDescription: 'App Background Notifications',
                    priority: Priority.high,
                    ongoing: false,
                    largeIcon: ByteArrayAndroidBitmap.fromBase64String(
                      base64Encode(response.bodyBytes),
                    ),
                    // autoCancel: false,
                  ),
                ),
              );
            }
          },
        )
        .subscribe();

    if (await service.isForegroundService()) {
      log('foreground service');
    } else {
      log('background service');
    }
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

    service.on('listenToLocation').listen((data) async {
      log('listen to location');
      log(data.toString());
      if (data == null) {
        log('data is null');
        return;
      }
      // if (await service.isForegroundService()) {
      flutterLocalNotificationsPlugin.show(
        888,
        'Đang chia sẻ vị trí',
        'Vui lòng không tắt ứng dụng',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notiChannelId,
            nottiChannelName,
            icon: 'ic_bg_service_small',
            importance: Importance.max,
            channelDescription: 'Shared position with other members',
            priority: Priority.max,
            ongoing: true,
            color: Color.fromARGB(255, 23, 78, 52),
            colorized: true,
            autoCancel: false,
            actions: [
              AndroidNotificationAction(
                'stop_listen',
                'Dừng chia sẻ vị trí',
                // showsUserInterface: true,
                cancelNotification: true,
              ),
            ],
          ),
        ),
      );

      final currentUser = data['data'];

      if (channelName != data['channel_name']) {
        channelName = data['channel_name'] as String;

        positionChannel = client.channel(channelName!);
        positionChannel.subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            positionChannel.track({
              'data': currentUser,
            });
          }
        });
        // positionChannel.sendBroadcastMessage(event: 'position', payload: {
        //   'data': currentUser,
        // });
        Stream<Position> positionStream = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5, // Update every 5 meters
          ),
        );
        positionChannel.track({
          'data': currentUser,
        });
        positionStream.listen((Position position) {
          currentUser['latitude'] = position.latitude;
          currentUser['longitude'] = position.longitude;
          positionChannel.track({
            'data': currentUser,
          });
        });
      }
    });

    service.on('redirectNoti').listen((data) {
      service.invoke('redirecting');
    });
    service.on('stopListen').listen((event) {
      // remove notificaiton id 888
      log('stop listening');
      flutterLocalNotificationsPlugin.cancel(888);
      positionChannel.unsubscribe();
      channelName = null;
    });
    service.on('stopService').listen((event) {
      log('stop listening');
      client.removeAllChannels();
      service.stopSelf();
    });
  }
}
