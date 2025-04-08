import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xintai_school/SchoolComputerSys/Prase/SchoolComputerModel.dart';
import 'package:xintai_school/SchoolComputerSys/Prase/SchoolComputerParseManager.dart';
import 'package:xintai_school/Utils/XTScreenAdaptation.dart';

class SchoolComputerReservationPage extends StatefulWidget {
  final List<RoomReservation> roomReservations;
  final ComputerRoom computerRoom;

  const SchoolComputerReservationPage({
    super.key,
    required this.roomReservations,
    required this.computerRoom,
  });

  @override
  _SchoolComputerReservationPageState createState() =>
      _SchoolComputerReservationPageState();
}

class _SchoolComputerReservationPageState
    extends State<SchoolComputerReservationPage> {
  @override
  Widget build(BuildContext context) {
    XTScreenAdaptation.init(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
        title: GestureDetector(
          onTap: _onTitleTapped, // 监听点击
          child: Text('${widget.computerRoom.room} 机房预约'),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical, // 仅允许垂直滚动
        child: _buildSchedule(),
      ),
    );
  }

  Widget _buildSchedule() {
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
        // Header row with time slots as columns
        TableRow(
          children: [
            const TableCell(child: SizedBox()), // Empty cell for corner
            for (int type = 1; type < 4; type++)
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      _formatTimeSlot(type),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
        // Adding each day as a row
        for (int i = 0; i < 7; i++)
          TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text(weekdays[i])),
                ),
              ),
              for (int type = 1; type < 4; type++)
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: _buildReservationInfo(
                        widget.computerRoom,
                        now.add(Duration(days: i)),
                        type,
                        roomDayReservations,
                      ),
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
    RoomReservation? roomReservation =
        _getReservationInfo(date, type, roomDayReservations);

    if (roomReservation != null) {
      return Column(children: [
        Text(
          roomReservation.course,
          style: TextStyle(fontSize: 10.0.px),
          textAlign: TextAlign.left,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          roomReservation.className,
          style: TextStyle(fontSize: 10.0.px),
          textAlign: TextAlign.left,
        ),
        Text(
          roomReservation.teacher,
          style: TextStyle(fontSize: 10.0.px),
          textAlign: TextAlign.left,
        ),
      ]);
    } else {
      return InkWell(
        onTap: () {
          showBookDialog(computerRoom, date, type);
        },
        child: Container(
          width: 100.px, // 按钮宽度
          height: 60.px, // 按钮高度
          decoration: BoxDecoration(
            color: Colors.blue, // 按钮背景色
            borderRadius: BorderRadius.circular(8.px), // 按钮圆角
          ),
          child: Center(
            child: Text(
              '预约',
              style: TextStyle(fontSize: 14.px, color: Colors.white), // 文字样式
              textAlign: TextAlign.center, // 文字居中对齐
            ),
          ),
        ),
      );
    }
  }

  RoomReservation? _getReservationInfo(DateTime Date, int type,
      Map<String, List<RoomReservation>> roomDayReservations) {
    String formattedReservationDate = _formatDate(Date);

    if (roomDayReservations.containsKey(formattedReservationDate)) {
      List<RoomReservation> reservations =
          roomDayReservations[formattedReservationDate]!;
      for (var reservation in reservations) {
        if (reservation.type == type) {
          return reservation;
        }
      }
    }

    return null;
  }

  String _formatTimeSlot(int type) {
    switch (type) {
      case 1:
        return '一二';
      case 2:
        return '三四';
      case 3:
        return '五六';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    switch (date.weekday) {
      case 1:
        return '$month-$day\n周一';
      case 2:
        return '$month-$day\n周二';
      case 3:
        return '$month-$day\n周三';
      case 4:
        return '$month-$day\n周四';
      case 5:
        return '$month-$day\n周五';
      case 6:
        return '$month-$day\n周六';
      case 7:
        return '$month-$day\n周日';
      default:
        return '';
    }
  }

  int _titleTapCount = 5;
  void _onTitleTapped() {
    _titleTapCount--;
    if (_titleTapCount == -1) {
      _titleTapCount = 5;
    }
  }

  void showBookDialog(ComputerRoom computerRoom, DateTime date, int type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String teacherName = '';
        String course = '';
        String className = '';
        int dateNum = 1;

        return AlertDialog(
          title: Text('预约机房${computerRoom.room}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('日期:${_formatDate(date)} ${_formatTimeSlot(type)}节'),
              TextFormField(
                decoration: const InputDecoration(labelText: '教师名字'),
                onChanged: (value) {
                  teacherName = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '课程名称'),
                onChanged: (value) {
                  course = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '班级'),
                onChanged: (value) {
                  className = value;
                },
              ),
              if (_titleTapCount == 0)
                TextFormField(
                  decoration: const InputDecoration(labelText: '周数'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // 只允许输入数字
                  ],
                  onChanged: (value) {
                    setState(() {
                      dateNum =
                          int.tryParse(value) ?? 0; // 处理转换错误，确保 dateNum 为 int
                    });
                  },
                )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
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
              child: const Text('预约'),
            ),
            if (_titleTapCount == 0)
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
                        .bookMoreComputerRoom(computerRoom, date, type, course,
                            teacherName, className, dateNum)
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
                child: const Text('批量预约'),
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
            //         await SchoolComputerParseManager().bookMoreComputerRoom(
            //             computerRoom,
            //             date,
            //             type,
            //             course,
            //             teacherName,
            //             className,
            //             );
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
      title: const Text('预约帮助'),
      content: const SingleChildScrollView(
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
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
