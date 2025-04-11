import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendReservationSuccess({
  required String teacher,
  required String computerRoom,
  required DateTime date,
  required int type,
}) async {
  const String url = 'https://www.kfzzzzzz.cn/reservation/success';

  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      "Teacher": teacher,
      "computerRoom": computerRoom,
      "date": date.toIso8601String(),
      "Type": type,
    }),
  );

  if (response.statusCode == 200) {
    print('发送成功: ${response.body}');
  } else {
    print('发送失败，状态码: ${response.statusCode}');
  }
}
