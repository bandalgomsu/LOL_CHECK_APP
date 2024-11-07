import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lolcheck/Constant.dart';
import 'package:lolcheck/page/LoginPage.dart';
import 'package:lolcheck/util/TokenManager.dart';

class ApiClient {
  final Dio dio = Dio();
  final BuildContext context;

  ApiClient(this.context) {
    dio.options.baseUrl = baseUrl;

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? accessToken = await getAccessToken();

        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }

        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401 &&
            error.requestOptions.uri.path != '/api/v1/auth/refresh') {
          await deleteAccessToken();
          bool success = await _refreshToken();

          if (success) {
            final retryRequest = await _retry(error.requestOptions);

            return handler.resolve(retryRequest);
          } else {
            _redirectToLogin();
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      final response = await dio.post('/api/v1/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        print("REFRESH SUCCESS!!!");
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];
        await saveAccessToken(newAccessToken);
        await saveRefreshToken(newRefreshToken);
        return true;
      }
    } catch (e) {
      print('토큰 갱신 실패: $e');
    }

    return false;
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return dio.request(
      requestOptions.path,
      options: options,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }

  void _redirectToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}

Future<String?> getAccessToken() async {
  return TokenManager().getAccessToken();
}

Future<void> deleteAccessToken() async {
  TokenManager().deleteAccessToken();
}

Future<String?> getRefreshToken() async {
  return TokenManager().getRefreshToken();
}

Future<void> saveAccessToken(String token) async {
  TokenManager().setAccessToken(token);
}

Future<void> saveRefreshToken(String token) async {
  TokenManager().setRefreshToken(token);
}
