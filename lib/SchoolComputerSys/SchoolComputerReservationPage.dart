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
    DateTime now = DateTime.now().add(Duration(hours: 8)); // 东八区时
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
                      child: Text(_getReservationInfo(
                          now.add(Duration(days: i)),
                          type,
                          roomDayReservations)),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  String _getReservationInfo(DateTime Date, int type,
      Map<String, List<RoomReservation>> roomDayReservations) {
    String formattedReservationDate = _formatDate(Date);

    if (roomDayReservations.containsKey(formattedReservationDate)) {
      List<RoomReservation> reservations =
          roomDayReservations[formattedReservationDate]!;
      for (var reservation in reservations) {
        if (reservation.type == type) {
          return "${reservation.course} \n ${reservation.className} ${reservation.teacher}";
        }
      }
    }

    return "";
  }

  String _formatTimeSlot(int type) {
    switch (type) {
      case 1:
        return '一二 (8:40 - 10:10)';
      case 2:
        return '三四 (10:30 - 12:00)';
      case 3:
        return '中午 (12:00 - 14:00)';
      case 4:
        return '五六 (14:00 - 15:30)';
      case 5:
        return '课后 (15:30 - 16:30)';
      default:
        return '';
    }
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
