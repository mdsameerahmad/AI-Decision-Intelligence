abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String message;
  AuthLoading({this.message = "Loading..."});
}

class AuthSuccess extends AuthState {}

class ProfileLoaded extends AuthState {
  final Map<String, dynamic> profile;

  ProfileLoaded(this.profile);
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}
