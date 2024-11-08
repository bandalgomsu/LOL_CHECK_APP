import 'package:flutter/material.dart';
import 'package:lolcheck/util/ApiClient.dart';

import '../util/TokenManager.dart';
import 'LoginPage.dart';
import 'MainPage.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  Future<void> checkLoginStatus(BuildContext context) async {
    final accessToken = await TokenManager().getAccessToken();

    final ApiClient apiClient = ApiClient(context);
    final response = await apiClient.dio.get('/api/v1/subscribe/me');

    if (response.statusCode == 200) {
      // 유효한 토큰이 있으면 MainPage로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      // 토큰이 없으면 LoginPage로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    checkLoginStatus(context);

    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
