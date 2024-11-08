import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lolcheck/Constant.dart';
import 'package:lolcheck/page/MainPage.dart';
import 'package:lolcheck/util/TokenManager.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController verificationCodeController =
      TextEditingController();

  bool isVerificationSent = false;
  bool isResendEnabled = false;
  Timer? _timer;
  int _countdown = 180; // 3분(180초) 카운트다운
  String errorMessage = ''; // 오류 메시지를 저장할 변수

  void startCountdown() {
    setState(() {
      _countdown = 180;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void sendVerificationEmail() {
    // 이메일 인증 메일 발송 로직 추가
    _timer?.cancel();
    setState(() {
      isVerificationSent = true;
      isResendEnabled = true;
    });
    startCountdown(); // 카운트다운 시작
  }

  void verifyEmailCode() {
    // 이메일 인증 코드 검증 로직 추가
  }

  Future<void> signUp(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    final url = Uri.parse('$baseUrl/api/v1/auth/signUp');

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        TokenManager().setAccessToken(data['accessToken']);
        TokenManager().setRefreshToken(data['refreshToken']);

        await fetchSaveDevice();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          errorMessage = '회원가입 실패';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = '회원가입 요청 중 오류가 발생했습니다';
      });
    }
  }

  Future<void> fetchSaveDevice() async {
    final url = Uri.parse('$baseUrl/api/v1/devices');
    final accessToken = await TokenManager().getAccessToken();
    final fcmToken =
        await FirebaseMessaging.instance.getToken(vapidKey: fcmKey);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode({'deviceToken': fcmToken}),
      );

      if (response.statusCode != 200) {
        print('Failed to fetch data: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: sendVerificationEmail,
                    child: Text(isResendEnabled ? '재발송' : '이메일 인증 메일 발송'),
                  ),
                ],
              ),
              if (isVerificationSent) SizedBox(height: 8.0),
              if (isVerificationSent)
                Text(
                  '남은 시간: ${_countdown ~/ 60}:${(_countdown % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 16.0),
              if (isVerificationSent)
                Column(
                  children: [
                    TextField(
                      controller: verificationCodeController,
                      decoration: InputDecoration(
                        labelText: '인증 번호',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: verifyEmailCode,
                      child: Text('이메일 인증'),
                    ),
                  ],
                ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  signUp(context);
                },
                child: Text('회원가입'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
