import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lolcheck/Constant.dart';
import 'package:lolcheck/util/ApiClient.dart';

import '../util/TokenManager.dart';

class SummonerDetailsPage extends StatefulWidget {
  final String summonerName;
  final String tagLine;
  final DateTime recentGame;
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
  });

  @override
  void initState() {
    super.initState();
    fetchSubscriptionStatus();
  }

  Future<void> fetchSubscriptionStatus() async {
    final url = Uri.parse('$baseUrl/api/v1/subscribe/me/$summonerId');

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

  Future<void> fetchSubscribe(BuildContext context) async {
    final url = Uri.parse('$baseUrl/api/v1/subscribe/me/$summonerId');
    final accessToken = await TokenManager().getAccessToken();
    final ApiClient apiClient = ApiClient(context);

    setState(() {
      isLoading = true;
    });

    if (!isSubscribed) {
      final response =
          await apiClient.dio.post('/api/v1/subscribe/me/$summonerId');
      if (response.statusCode == 200) {
        setState(() {
          isSubscribed = true;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      final response =
          await apiClient.dio.delete('/api/v1/subscribe/me/$summonerId');

      if (response.statusCode == 200) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('소환사 정보'),
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
                      onPressed: () {
                        fetchSubscribe(context);
                      },
                      child: Text(isSubscribed ? '구독 취소' : '구독하기'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
