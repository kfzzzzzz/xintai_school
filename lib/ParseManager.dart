import "dart:io";

import "package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart";

class ParseManager {
  static final ParseManager _instance = ParseManager._internal();

  factory ParseManager() {
    return _instance;
  }

  ParseManager._internal();

  static const String _applicationId = 'kfzzzzzz.SimulateLocation';
  static const String _serverUrl = 'http://121.43.102.102:1337/parse';
  static const String _clientKey = 'kfzzzzzz.SimulateLocation';

  bool _initialized = false;

  Future<void> initializeParse() async {
    if (!_initialized) {
      await Parse().initialize(
        _applicationId,
        _serverUrl,
        clientKey: _clientKey,
        autoSendSessionId: true,
        debug: true,
        clientCreator: (
                {bool sendSessionId = true,
                SecurityContext? securityContext}) =>
            ParseDioClient(
                sendSessionId: sendSessionId, securityContext: securityContext),
      );
      _initialized = true;
    }
  }

  Future<String> currentUser() async {
    final currentUser = await ParseUser.currentUser();
    if (currentUser == null) {
      return "无用户";
    }
    return currentUser.username;
  }

  Future<void> loginUser(String username, String password) async {
    try {
      // 创建 ParseUser 对象并设置用户名和密码
      final ParseUser user = ParseUser(username, password, null);

      // 调用登录方法
      final ParseResponse response = await user.login();

      // 检查登录是否成功
      if (response.success) {
        // 登录成功
        print('Login successful!');
        // 这里可以做一些跳转到下一个页面等操作
      } else {
        // 登录失败，输出失败信息
        print('Login failed: ${response.error}');
      }
    } catch (e) {
      // 捕获异常
      print('Error occurred during login: $e');
    }
  }

  Future<void> logoutUser() async {
    try {
      // 等待 ParseUser.currentUser() 的返回结果
      final currentUser = await ParseUser.currentUser();

      // 调用登录方法
      final ParseResponse response = await currentUser.logout();

      // 检查登录是否成功
      if (response.success) {
        // 登录成功
        print('Logout successful!');
        // 这里可以做一些跳转到下一个页面等操作
      } else {
        // 登录失败，输出失败信息
        print('Logout failed: ${response.error}');
      }
    } catch (e) {
      // 捕获异常
      print('Error occurred during Logout: $e');
    }
  }

  static ParseManager get instance => _instance;
}
