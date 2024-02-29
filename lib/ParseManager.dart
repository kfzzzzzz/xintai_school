import "package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart";
import 'package:xintai_school/SchoolComputerSys/Prase/SchoolComputerModel.dart';

class ParseManager {
  static final ParseManager _instance = ParseManager._internal();

  factory ParseManager() {
    return _instance;
  }

  ParseManager._internal();

  static const String _applicationId = 'kfzzzzzz.SimulateLocation';
  static const String _serverUrl = 'http://kfzzzzzz.cn:1337/parse';
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
        registeredSubClassMap: <String, ParseObjectConstructor>{
          'computerRoom': () => ComputerRoom(),
          'computer': () => Computer()
        },
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

  Future<String> loginUser(String username, String password) async {
    try {
      final ParseUser user = ParseUser(username, password, null);

      final ParseResponse response = await user.login();

      if (response.success) {
        return 'Login successful!';
      } else {
        return 'Login failed: ${response.error?.message ?? 'Unknown error'}';
      }
    } catch (e) {
      return 'Error occurred during login: $e';
    }
  }

  Future<void> logoutUser() async {
    try {
      final currentUser = await ParseUser.currentUser();
      final ParseResponse response = await currentUser.logout();

      if (response.success) {
        print('Logout successful!');
      } else {
        print('Logout failed: ${response.error}');
      }
    } catch (e) {
      print('Error occurred during Logout: $e');
    }
  }

  Future<String> registerUser(
      String name, String password, String email) async {
    try {
      final ParseUser user = ParseUser(name, password, email);

      final ParseResponse response = await user.signUp();

      if (response.success) {
        return 'signUp successful!';
      } else {
        return 'signUp failed: ${response.error?.message ?? 'Unknown error'}';
      }
    } catch (e) {
      return 'Error occurred during signUp: $e';
    }
  }

  static ParseManager get instance => _instance;
}
