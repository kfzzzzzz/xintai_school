import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xintai_school/SchoolComputerSys/Prase/SchoolComputerModel.dart';
import 'package:xintai_school/SchoolComputerSys/Prase/SchoolComputerParseManager.dart';

class SchoolComputerReservationPage extends StatefulWidget {
  final List<RoomReservation> roomReservations;
  final ComputerRoom computerRoom;

  SchoolComputerReservationPage({
    Key? key,
    required this.roomReservations,
    required this.computerRoom,
  }) : super(key: key);

  @override
  _SchoolComputerReservationPageState createState() =>
      _SchoolComputerReservationPageState();
}

class _SchoolComputerReservationPageState
    extends State<SchoolComputerReservationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help, color: Colors.grey),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _showManagerDialog();
                },
              );
            },
          ),
        ],
        title: Text('${widget.computerRoom.room} 机房预约'),
      ),
      body: _buildSchedule(),
    );
  }

  Widget _buildSchedule() {
    // DateTime now = DateTime.now().add(Duration(hours: 8)); // 东八区时
    DateTime now = DateTime.now();
    List<String> weekdays = [];
    Map<String, List<RoomReservation>> roomDayReservations = {};

    for (int i = 0; i < 7; i++) {
      DateTime date = now.add(Duration(days: i));
      String formattedDate = _formatDate(date);
      weekdays.add(formattedDate);
      roomDayReservations[formattedDate] = [];
    }

    //将预约信息填入对应的日期map中
    for (var roomReservation in widget.roomReservations) {
      DateTime reservationDate = roomReservation.startDate!;
      String formattedReservationDate = _formatDate(reservationDate);
      if (roomDayReservations.containsKey(formattedReservationDate)) {
        roomDayReservations[formattedReservationDate]?.add(roomReservation);
      }
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            TableCell(child: SizedBox()),
            for (var weekday in weekdays)
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      weekday,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
        for (int type = 1; type < 6; type++)
          TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text(_formatTimeSlot(type))),
                ),
              ),
              for (int i = 0; i < 7; i++)
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: _buildReservationInfo(
                          widget.computerRoom,
                          now.add(Duration(days: i)),
                          type,
                          roomDayReservations),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildReservationInfo(
    ComputerRoom computerRoom,
    DateTime date,
    int type,
    Map<String, List<RoomReservation>> roomDayReservations,
  ) {
    String reservationInfo =
        _getReservationInfo(date, type, roomDayReservations);

    if (reservationInfo.isNotEmpty) {
      return Center(
        child: Text(
          reservationInfo,
          style: TextStyle(fontSize: 10.0),
          textAlign: TextAlign.left,
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          showBookDialog(computerRoom, date, type);
        },
        child: Container(
          width: 100, // 按钮宽度
          height: 60, // 按钮高度
          decoration: BoxDecoration(
            color: Colors.blue, // 按钮背景色
            borderRadius: BorderRadius.circular(8), // 按钮圆角
          ),
          child: Center(
            child: Text(
              '预 \n约',
              style: TextStyle(fontSize: 14, color: Colors.white), // 文字样式
              textAlign: TextAlign.center, // 文字居中对齐
            ),
          ),
        ),
      );
    }
  }

  String _getReservationInfo(DateTime Date, int type,
      Map<String, List<RoomReservation>> roomDayReservations) {
    String formattedReservationDate = _formatDate(Date);

    if (roomDayReservations.containsKey(formattedReservationDate)) {
      List<RoomReservation> reservations =
          roomDayReservations[formattedReservationDate]!;
      for (var reservation in reservations) {
        if (reservation.type == type) {
          return "${reservation.course}\n ${reservation.className}${reservation.teacher}";
        }
      }
    }

    return "";
  }

  String _formatTimeSlot(int type) {
    switch (type) {
      case 1:
        return '一\n二';
      case 2:
        return '三\n四';
      case 3:
        return '中\n午';
      case 4:
        return '五\n六';
      case 5:
        return '课\n后';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    switch (date.weekday) {
      case 1:
        return '$month\n-$day\n周一';
      case 2:
        return '$month\n-$day\n周二';
      case 3:
        return '$month\n-$day\n周三';
      case 4:
        return '$month\n-$day\n周四';
      case 5:
        return '$month\n-$day\n周五';
      case 6:
        return '$month\n-$day\n周六';
      case 7:
        return '$month\n-$day\n周日';
      default:
        return '';
    }
  }

  void showBookDialog(ComputerRoom computerRoom, DateTime date, int type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String teacherName = '';
        String course = '';
        String className = '';

        return AlertDialog(
          title: Text('预约机房'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${computerRoom.room}机房'),
              Text('${_formatDate(date)} ${_formatTimeSlot(type)}'),
              TextFormField(
                decoration: InputDecoration(labelText: '教师名字'),
                onChanged: (value) {
                  teacherName = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '课程名称'),
                onChanged: (value) {
                  course = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '班级'),
                onChanged: (value) {
                  className = value;
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (teacherName == '' || className == '' || course == '') {
                  Fluttertoast.showToast(
                    msg: "请输入全部信息",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                } else {
                  await SchoolComputerParseManager()
                      .bookComputerRoom(computerRoom, date, type, course,
                          teacherName, className)
                      .then((value) {
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(
                      msg: "预约机房成功成功",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                  }).onError((error, stackTrace) {
                    Fluttertoast.showToast(
                      msg: "预约机房失败，请稍后再试或联系孔繁臻",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                  });
                }
                //退出预约界面
                Navigator.of(context).pop();
              },
              child: Text('预约'),
            ),
            // ElevatedButton(
            //   onPressed: () async {
            //     if (teacherName == '' || className == '' || course == '') {
            //       Fluttertoast.showToast(
            //         msg: "请输入全部信息",
            //         toastLength: Toast.LENGTH_SHORT,
            //         gravity: ToastGravity.CENTER,
            //       );
            //     } else {
            //       DateTime julyFifth = DateTime(DateTime.now().year, 7, 5);
            //       while (date.isBefore(julyFifth)) {
            //         await SchoolComputerParseManager().bookComputerRoom(
            //             computerRoom,
            //             date,
            //             type,
            //             course,
            //             teacherName,
            //             className);
            //         date = date.add(Duration(days: 7));
            //       }
            //       Navigator.of(context).pop();
            //       Fluttertoast.showToast(
            //         msg: "预约机房成功成功",
            //         toastLength: Toast.LENGTH_SHORT,
            //         gravity: ToastGravity.CENTER,
            //       );
            //     }
            //     //退出预约界面
            //     Navigator.of(context).pop();
            //   },
            //   child: Text('批量预约'),
            // ),
          ],
        );
      },
    );
  }

  _showManagerDialog() {
    return AlertDialog(
      title: Text('预约帮助'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
                '预约分五个时间段:\n一二 (8:40 - 10:10)\n三四 (10:30 - 12:00)\n中午 (12:00 - 14:00)\n五六 (14:00 - 15:30)\n课后 (15:30 - 16:30)')
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 关闭对话框
          },
          child: Text('关闭'),
        ),
      ],
    );
  }
}
