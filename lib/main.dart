import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xintai_school/LoginPage/LoginPage.dart';
import 'package:xintai_school/ParseManager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ParseManager().initializeParse();
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '浙江公路技师学院路桥学院机房维护系统',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            body: LoginPage(),
            bottomNavigationBar: kIsWeb ? BottomBar() : null,
          );
        },
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Container(
        height: 50,
        alignment: Alignment.center,
        child: Text(
          'ICP备案号：闽ICP备2024036290号-1',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
