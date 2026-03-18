import '../../core/constants/api_constants.dart';
import '../services/api_service.dart';

class AuthRepository {

final ApiService apiService;

AuthRepository(this.apiService);

Future login(String email, String password) async {


final response = await apiService.post(
      ApiConstants.login,
      {
        "username": email,
        "password": password
      },
      contentType: "application/x-www-form-urlencoded",
    );

    // Assuming the response contains a token, save it
    if (response != null && response['access_token'] != null) {
      await apiService.saveToken(response['access_token']);
    }
    return response;

}

Future signup(String email, String password) async {
    return await apiService.post(
      ApiConstants.signup,
      {
        "email": email,
        "password": password
      },
    );
  }

  Future logout() async {
    await apiService.deleteToken();
  }

  Future getProfile() async {
    return await apiService.get(ApiConstants.profile);
  }
}
