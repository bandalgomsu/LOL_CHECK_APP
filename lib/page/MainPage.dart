import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lolcheck/Constant.dart';
import 'package:lolcheck/page/SummonerDetailPage.dart';
import 'package:lolcheck/util/TokenManager.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _gameNameController = TextEditingController();
  final TextEditingController _tagLineController = TextEditingController();
  String? _errorMessage;

  Future<void> fetchGameData() async {
    final gameName = _gameNameController.text;
    final tagLine = _tagLineController.text;

    final url = Uri.parse('$baseUrl/api/v1/summoner').replace(queryParameters: {
      'gameName': gameName,
      'tagLine': tagLine,
    });

    try {
      final accessToken = await TokenManager().getAccessToken();

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data.toString());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SummonerDetailsPage(
              summonerName: data["gameName"],
              tagLine: data["tagLine"],
              recentGame: data?["updatedAt"].toString() ?? "x",
              summonerId: data["summonerId"].toString(),
            ),
          ),
        );

        // 성공적인 응답 시 에러 메시지 초기화
        setState(() {
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = '존재하지 않는 소환사입니다';
        });
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        _errorMessage = '오류가 발생했습니다: $error';
      });
      print('Error: $error');
    }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null) // 에러 메시지가 있을 경우 표시
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextField(
                controller: _gameNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Game Name',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _tagLineController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Tag Line',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  fetchGameData();
                },
                child: Text('Search'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
