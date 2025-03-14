import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/secrets/supabase_secret.dart';

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
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log('notification tap background');
        log(response.toString());
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,
      autoStart: true,
      isForegroundMode: false,
      notificationChannelId: notiChannelId,
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
      // }
      // }
      final currentUser = data['data'];
      log("current channel name: $channelName");
      log("new channel name: ${data['channel_name']}");

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

      // log('initial position');
    });
    service.on('stopListen').listen((event) {
      // remove notificaiton id 888
      log('stop listening');

      positionChannel.unsubscribe();
      channelName = null;
    });
    service.on('stopService').listen((event) {
      log('stop listening');

      service.stopSelf();
    });
  }
}
