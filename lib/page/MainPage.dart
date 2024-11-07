import 'package:flutter/material.dart';
import 'package:lolcheck/page/MyInfoPage.dart';
import 'package:lolcheck/page/SummonerDetailPage.dart';
import 'package:lolcheck/util/ApiClient.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _gameNameController = TextEditingController();
  final TextEditingController _tagLineController = TextEditingController();

  String? _errorMessage;

  Future<void> fetchGameData(BuildContext context) async {
    final gameName = _gameNameController.text;
    final tagLine = _tagLineController.text;
    final ApiClient apiClient = ApiClient(context);

    final response =
        await apiClient.dio.get('/api/v1/summoner', queryParameters: {
      'gameName': gameName,
      'tagLine': tagLine,
    });

    if (response.statusCode == 200) {
      final data = response.data;

      Navigator.push(
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LOL CHECK'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // '내 정보' 페이지로 이동하는 코드
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyInfoPage(),
                ),
              );
            },
          ),
        ],
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
                  fetchGameData(context);
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
