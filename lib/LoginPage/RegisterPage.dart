import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xintai_school/ParseManager.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册页面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: const InputDecoration(
                labelText: '教师名字',
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: const InputDecoration(
                labelText: '邮箱地址',
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              decoration: const InputDecoration(
                labelText: '密码',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _register();
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      // 如果任一字段为空，显示提示并聚焦到相应的文本框
      String message = '请填写全部信息';
      if (name.isEmpty) {
        message = '名称不能为空';
        FocusScope.of(context).requestFocus(_nameFocusNode);
      } else if (email.isEmpty) {
        message = '邮箱不能为空';
        FocusScope.of(context).requestFocus(_emailFocusNode);
      } else if (password.isEmpty) {
        message = '密码不能为空';
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }

    await ParseManager().registerUser(name, password, email).then((value) {
      Fluttertoast.showToast(
        msg: value,
        gravity: ToastGravity.CENTER,
      );
    });

    // 注册成功后可以导航到其他页面，这里只是打印注册信息
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => HomePage()),
    // );
  }
}
