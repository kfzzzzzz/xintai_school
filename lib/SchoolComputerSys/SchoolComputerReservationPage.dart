import 'package:flutter/material.dart';
import 'package:xintai_school/SchoolComputerSys/Prase/SchoolComputerModel.dart';

class SchoolComputerReservationPage extends StatefulWidget {
  final List<RoomReservation> roomReservations;
  final ComputerRoom computerRoom;

  const SchoolComputerReservationPage(
      {super.key, required this.roomReservations, required this.computerRoom});

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
        title: Text('${widget.computerRoom.room} 机房预约'),
      ),
      body: _buildSchedule(),
    );
  }

  Widget _buildSchedule() {
    DateTime now = DateTime.now().add(Duration(hours: 8)); // 东八区时间

    List<String> timeSlots = [
      '一二 (8:40 - 10:10)',
      '三四 (10:30 - 12:00)',
      '中午 (12:00 - 14:00)',
      '五六 (14:00 - 15:30)',
      '课后 (15:30 - 16:30)',
    ];

    List<String> weekdays = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = now.add(Duration(days: i));
      weekdays.add(_formatDate(date));
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
        for (var slot in timeSlots)
          TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text(slot)),
                ),
              ),
              for (int i = 0; i < 7; i++)
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(_getReservationInfo(i + 1, slot)),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  String _getReservationInfo(int weekday, String timeSlot) {
    return " ";
  }

  String _formatDate(DateTime date) {
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    switch (date.weekday) {
      case 1:
        return '$month-$day 周一';
      case 2:
        return '$month-$day 周二';
      case 3:
        return '$month-$day 周三';
      case 4:
        return '$month-$day 周四';
      case 5:
        return '$month-$day 周五';
      case 6:
        return '$month-$day 周六';
      case 7:
        return '$month-$day 周日';
      default:
        return '';
    }
  }
}
