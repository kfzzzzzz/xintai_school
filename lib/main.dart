import 'package:flutter/material.dart';
import 'package:xintai_school/ParseManager.dart';
import 'SchoolComputerSys/SchoolComputerSysPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ParseManager().initializeParse();
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '浙江公路技师学院路桥学院机房维护系统',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // 配置路由
      routes: {
        '/': (context) => const SchoolComputerSysPage(), // /abc 路由
      },
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Container(
        height: 50,
        alignment: Alignment.center,
        child: const Text(
          'ICP备案号：闽ICP备2024036290号-1',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
