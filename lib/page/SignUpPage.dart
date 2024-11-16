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
  bool isLoading = false;
  bool isVerified = false;

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
    startCountdown(); // 카운트다운 시작
    sendSignUpVerifyingMail();
  }

  Future<void> sendSignUpVerifyingMail() async {
    final email = emailController.text;

    updateLoading();
    final url = Uri.parse('$baseUrl/api/v1/auth/signUp/mail');

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}));
      if (response.statusCode == 200) {
        setState(() {
          isVerificationSent = true;
          isResendEnabled = true;
          errorMessage = "";
        });
      } else {
        setState(() {
          errorMessage = "올바르지 않은 이메일 입니다.";
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = '메일 발송 요청 중 오류가 발생했습니다';
      });
    }

    updateLoading();
  }

  Future<void> verifyAuthNumber() async {
    final email = emailController.text;
    final authNumber = verificationCodeController.text;

    updateLoading();
    final url = Uri.parse('$baseUrl/api/v1/auth/signUp/mail/verify');

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'authNumber': authNumber}));

      if (response.statusCode == 200) {
        setState(() {
          isVerified = true;
          errorMessage = "";
        });
      } else {
        setState(() {
          errorMessage = "잘못된 인증코드 입니다.";
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "잘못된 인증코드 입니다.";
      });
    }

    updateLoading();
  }

  Future<void> signUp(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    updateLoading();
    final url = Uri.parse('$baseUrl/api/v1/auth/signUp');

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        TokenManager().setAccessToken(data['accessToken']);
        TokenManager().setRefreshToken(data['refreshToken']);

        updateLoading();
        await fetchSaveDevice();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          updateLoading();
          errorMessage = '회원가입 실패';
        });
      }
    } catch (error) {
      setState(() {
        updateLoading();
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

  void updateLoading() {
    setState(() {
      isLoading = !isLoading;
    });
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
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
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
                            onPressed: () => verifyAuthNumber(),
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
                      onPressed: isVerified ? () => signUp(context) : null,
                      child: Text('회원가입'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
