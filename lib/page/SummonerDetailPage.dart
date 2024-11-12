import 'package:flutter/material.dart';
import 'package:lolcheck/main.dart';
import 'package:lolcheck/util/ApiClient.dart';

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
  bool isLoading = false;
  String summonerId;
  final ApiClient apiClient = ApiClient(navigatorKey.currentContext!);

  _SummonerDetailsPageState({
    required this.summonerId,
  });

  @override
  void initState() {
    super.initState();
    fetchSubscriptionStatus();
  }

  Future<void> fetchSubscriptionStatus() async {
    updateLoading();

    try {
      final response =
          await apiClient.dio.get('/api/v1/subscribe/me/$summonerId');

      if (response.statusCode == 200) {
        setState(() {
          isSubscribed = true;
        });
      }
    } catch (error) {
      print('SUBSCRIPTION STATUS ERROR');
    }

    updateLoading();
  }

  Future<void> fetchSubscribe(BuildContext context) async {
    updateLoading();
    try {
      if (!isSubscribed) {
        final response =
            await apiClient.dio.post('/api/v1/subscribe/me/$summonerId');

        if (response.statusCode == 200) {
          setState(() {
            isSubscribed = true;
          });
        }
      } else {
        final response =
            await apiClient.dio.delete('/api/v1/subscribe/me/$summonerId');

        if (response.statusCode == 200) {
          setState(() {
            isSubscribed = false;
          });
        }
      }
    } catch (error) {
      print("SUBSCRIBE ERROR");
    }

    updateLoading();
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
        title: Text('Summoner Info'),
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
