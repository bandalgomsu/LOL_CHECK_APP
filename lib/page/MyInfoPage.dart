import 'package:flutter/material.dart';
import 'package:lolcheck/main.dart';
import 'package:lolcheck/util/ApiClient.dart';

class MyInfoPage extends StatefulWidget {
  @override
  _MyInfoPageState createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage> {
  final ApiClient apiClient = ApiClient(navigatorKey.currentContext!);

  // 구독 중인 소환사 목록과 상태 관리 (예시 데이터)
  List<dynamic> subscribedSummoners = List.empty();

  @override
  void initState() {
    super.initState();
    fetchGetSubscribedSummoners();
  }

  Future<void> fetchUnSubscribe(BuildContext context, int summonerId) async {
    final response =
        await apiClient.dio.delete('/api/v1/subscribe/me/$summonerId');

    if (response.statusCode == 200) {
      fetchGetSubscribedSummoners();
      setState(() {});
    }
  }

  Future<void> fetchGetSubscribedSummoners() async {
    final response = await apiClient.dio.get('/api/v1/subscribe/me');

    if (response.statusCode == 200) {
      subscribedSummoners = await response.data;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Info"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "구독한 소환사",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: subscribedSummoners.length,
                  itemBuilder: (context, index) {
                    final summoner = subscribedSummoners[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(summoner["summonerGameName"] +
                            " #" +
                            summoner["summonerTagLine"]),
                        trailing: ElevatedButton(
                          onPressed: () =>
                              fetchUnSubscribe(context, summoner["summonerId"]),
                          child: Text("구독 취소"),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
