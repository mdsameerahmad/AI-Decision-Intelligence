import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/api_service.dart'; // Import ApiService
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final ApiService apiService; // Add ApiService

  AuthBloc(this.repository, this.apiService) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      try {
        final token = await apiService.getToken();
        if (token != null) {
          emit(AuthSuccess());
        } else {
          emit(AuthInitial());
        }
      } catch (e) {
        emit(AuthFailure("Failed to check authentication status: $e"));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading(message: "Reading credentials..."));
      await Future.delayed(const Duration(milliseconds: 500));
      emit(AuthLoading(message: "Authenticating..."));

      try {
        final response = await repository.login(
          event.email,
          event.password,
        );

        if (response != null && response["access_token"] != null) {
          emit(AuthLoading(message: "Verifying session..."));
          await Future.delayed(const Duration(milliseconds: 500));
          emit(AuthLoading(message: "Login successful!"));
          await Future.delayed(const Duration(milliseconds: 300));
          emit(AuthSuccess());
        } else {
          emit(AuthFailure("Login failed: Invalid response"));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SignupEvent>((event, emit) async {
      emit(AuthLoading(message: "Creating account..."));

      try {
        // 1. Perform Signup
        await repository.signup(
          event.email,
          event.password,
        );

        emit(AuthLoading(message: "Account created! Logging in..."));
        await Future.delayed(const Duration(milliseconds: 500));

        // 2. Automatically Login after successful signup
        final response = await repository.login(
          event.email,
          event.password,
        );

        if (response != null && response["access_token"] != null) {
          emit(AuthLoading(message: "Verifying session..."));
          await Future.delayed(const Duration(milliseconds: 500));
          emit(AuthLoading(message: "Welcome aboard!"));
          await Future.delayed(const Duration(milliseconds: 300));
          emit(AuthSuccess());
        } else {
          emit(AuthSuccess()); 
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await repository.logout();
      emit(AuthInitial());
    });

    on<FetchProfileEvent>((event, emit) async {
      emit(AuthLoading(message: "Fetching profile..."));
      try {
        final profile = await repository.getProfile();
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
