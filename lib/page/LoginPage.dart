import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lolcheck/page/MainPage.dart';
import 'package:lolcheck/page/SignUpPage.dart';
import 'package:lolcheck/util/ApiClient.dart';
import 'package:lolcheck/util/TokenManager.dart';

import '../Constant.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = ''; // 오류 메시지를 저장할 변수

  Future<void> fetchLogin(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    // API의 엔드포인트 URL
    final url = Uri.parse('$baseUrl/api/v1/auth/login');

    updateLoading();

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        TokenManager().setAccessToken(data['accessToken']);
        TokenManager().setRefreshToken(data['refreshToken']);

        await fetchSaveDevice(context);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          errorMessage = '부정확한 이메일/패스워드 입니다';
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        errorMessage = '로그인 요청 중 오류가 발생했습니다';
      });
    }
    updateLoading();
  }

  Future<void> fetchSaveDevice(BuildContext context) async {
    final ApiClient apiClient = ApiClient(context);

    await FirebaseMessaging.instance.deleteToken();

    final fcmToken =
        await FirebaseMessaging.instance.getToken(vapidKey: fcmKey);

    await apiClient.dio.delete('/api/v1/devices');
    await apiClient.dio
        .post('/api/v1/devices', data: {'deviceToken': fcmToken});
  }

  void updateLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LOL CHECK'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
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
                    SizedBox(height: 16.0),

                    // Error message
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),

                    SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: () {
                        // 로그인 버튼 기능 추가
                        fetchLogin(context);
                      },
                      child: Text('로그인'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
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
