import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/auth/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<UserModel> logInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel?> getCurrentUserData();

  Future<void> logOut();

  Future<UserModel> logInWithGoogle();

  Stream<AuthState> listenToAuthChanges();

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<void> updatePassword({
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(
    this.supabaseClient,
  );

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      var parts = name.split(' ');
      String firstName = parts.last;
      String lastName = parts.sublist(0, parts.length - 1).join(' ');
      final response = await supabaseClient.auth
          .signUp(email: email, password: password, data: {
        'full_name': '$firstName $lastName',
      });

      if (response.user == null) {
        throw const ServerException("Couldn't sign up");
      }
      return UserModel.fromJson(response.user!.toJson()).copyWith(
        email: response.user!.email,
        id: response.user!.id,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const ServerException("Couldn't log in");
      }
      return UserModel.fromJson(response.user!.toJson()).copyWith(
        email: response.user!.email,
        id: response.user!.id,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession == null) {
        return null;
      }
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', currentUserSession!.user.id);
      return UserModel.fromJson(response.first);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> logInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: dotenv.env['GOOGLE_ANDROID_CLIENT_ID']!,
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID']!,
      );
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw const ServerException('No Access Token found.');
      }
      if (idToken == null) {
        throw const ServerException('No ID Token found.');
      }

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw const ServerException("Couldn't log in");
      }
      return UserModel.fromJson(response.user!.toJson()).copyWith(
        email: response.user!.email,
        id: response.user!.id,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<AuthState> listenToAuthChanges() =>
      supabaseClient.auth.onAuthStateChange.map(
        (event) {
          print(event.toString());
          return event;
        },
      );

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email,
          redirectTo: 'vntravelcompanion://reset-password');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updatePassword({
    required String password,
  }) async {
    try {
      await supabaseClient.auth.updateUser(UserAttributes(
        password: password,
      ));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
