import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  TokenManager._internal();

  factory TokenManager() {
    return _instance;
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: "accessToken");
  }

  Future<void> setAccessToken(String accessToken) async {
    await _storage.write(key: "accessToken", value: accessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: "refreshToken");
  }

  Future<void> setRefreshToken(String refreshToken) async {
    await _storage.write(key: "refreshToken", value: refreshToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: "accessToken");
  }

  Future<String?> getFcmToken() async {
    return await _storage.read(key: "fcmToken");
  }

  Future<void> setFcmToken(String fcmToken) async {
    await _storage.write(key: "fcmToken", value: fcmToken);
  }

  Future<void> deleteFcmToken() async {
    await _storage.delete(key: "fcmToken");
  }
}
