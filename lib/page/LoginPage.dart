import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lolcheck/page/MainPage.dart';
import 'package:lolcheck/util/TokenManager.dart';

import '../Constant.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  Future<void> fetchLogin(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    // API의 엔드포인트 URL
    final url = Uri.parse('$baseUrl/api/v1/auth/login');

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        TokenManager().setAccessToken(data['accessToken']);
        TokenManager().setRefreshToken(data['refreshToken']);

        await fetchSaveDevice();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        print('data : ${response}');
        // 실패 응답 처d
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> fetchSaveDevice() async {
    final url = Uri.parse('$baseUrl/api/v1/devices');
    final accessToken = await TokenManager().getAccessToken();
    final fcmToken =
        await FirebaseMessaging.instance.getToken(vapidKey: fcmKey);

    try {
      print(accessToken);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode({'deviceToken': fcmToken}),
      );

      if (response.statusCode == 200) {
      } else {
        // 실패 응답 처d
        print('Failed to fetch data: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LOL_CHECK'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  // 로그인 버튼 기능 추가
                  fetchLogin(context);
                },
                child: Text('로그인'),
              ),
              TextButton(
                onPressed: () {
                  // 회원가입 버튼 기능 추가
                },
                child: Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
