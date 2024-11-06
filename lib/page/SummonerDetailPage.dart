import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lolcheck/Constant.dart';

import '../util/TokenManager.dart';

class SummonerDetailsPage extends StatefulWidget {
  final String summonerName;
  final String tagLine;
  final String recentGame;
  final String summonerId;

  SummonerDetailsPage({
    required this.summonerName,
    required this.tagLine,
    required this.recentGame,
    required this.summonerId,
    super.key,
  });

  @override
  _SummonerDetailsPageState createState() =>
      _SummonerDetailsPageState(summonerId: summonerId);
}

class _SummonerDetailsPageState extends State<SummonerDetailsPage> {
  bool isSubscribed = false;
  bool isLoading = true;
  String summonerId;

  _SummonerDetailsPageState({
    required this.summonerId,
  }); // API 로드 상태를 관리할 변수

  @override
  void initState() {
    super.initState();
    fetchSubscriptionStatus();
  }

  Future<void> fetchSubscriptionStatus() async {
    // API 엔드포인트 URL
    final url = Uri.parse('$baseUrl/api/v1/subscribe/me/$summonerId'); // 예시 URL

    try {
      final accessToken = await TokenManager().getAccessToken();

      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        // 구독 상태를 서버 응답에 따라 업데이트
        setState(() {
          isSubscribed = true;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to fetch subscription status: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching subscription status: $error');
    }
  }

  void toggleSubscription() {
    fetchSubscribe();
  }

  Future<void> fetchSubscribe() async {
    // API 엔드포인트 URL
    final url = Uri.parse('$baseUrl/api/v1/subscribe/me/$summonerId'); // 예시 URL
    final accessToken = await TokenManager().getAccessToken();

    setState(() {
      isLoading = true;
    });

    if (!isSubscribed) {
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          // 구독 상태를 서버 응답에 따라 업데이트
          setState(() {
            isSubscribed = true;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Failed to fetch subscription status: ${response.statusCode}');
        }
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        print('Error fetching subscription status: $error');
      }
    } else {
      try {
        final response = await http.delete(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          // 구독 상태를 서버 응답에 따라 업데이트
          setState(() {
            isSubscribed = false;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Failed to fetch subscription status: ${response.statusCode}');
        }
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        print('Error fetching subscription status: $error');
      }
    }
  }

  Future<void> fetchUnsubscribe() async {
    final url = Uri.parse('$baseUrl/api/v1/subscribe/me/$summonerId'); // 예시 URL

    try {
      final accessToken = await TokenManager().getAccessToken();

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        // 구독 상태를 서버 응답에 따라 업데이트
        setState(() {
          isSubscribed = true;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to fetch subscription status: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching subscription status: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('소환사 정보'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? CircularProgressIndicator() // API 호출 중에는 로딩 표시
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '소환사명: ${widget.summonerName}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '태그: ${widget.tagLine}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '최근 게임: ${widget.recentGame}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: toggleSubscription,
                      child: Text(isSubscribed ? '구독 취소' : '구독하기'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
