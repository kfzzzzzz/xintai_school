import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:xintai_school/SchoolComputerSys/Prase/SchoolComputerModel.dart';

class SchoolComputerParseManager {
  static final SchoolComputerParseManager _instance =
      SchoolComputerParseManager._internal();
  factory SchoolComputerParseManager() {
    return _instance;
  }
  SchoolComputerParseManager._internal();
  static SchoolComputerParseManager get instance => _instance;

  //获取电脑房间List
  Future<List<ComputerRoom>> fetchComputerRoom() async {
    var apiResponse = await ComputerRoom().getAll();
    List<ComputerRoom> computerRooms = [];
    if (apiResponse.success) {
      for (var parseObject in apiResponse.result) {
        var computerRoom = ComputerRoom.clone()..fromJson(parseObject.toJson());
        computerRooms.add(computerRoom);
      }
    } else {
      print('Failed to fetch data: ${apiResponse.error!.message}');
    }
    return computerRooms;
  }

//获取某个房间的电脑List
  Future<List<List<Computer?>>> fetchComputer(ComputerRoom computerRoom) async {
    QueryBuilder<ParseObject> queryComputer =
        QueryBuilder<ParseObject>(Computer())
          ..whereEqualTo('Room', computerRoom);

    List<List<Computer?>> computersGrid = [];

    var apiResponse = await queryComputer.query();

    if (apiResponse.success) {
      for (var computerObject in apiResponse.result) {
        Computer computer = Computer.clone()..fromJson(computerObject.toJson());
        int row = computer.row - 1;
        int column = computer.column - 1;
        while (row >= computersGrid.length) {
          computersGrid.add([]);
        }
        while (column >= computersGrid[row].length) {
          computersGrid[row].add(null);
        }
        computersGrid[row][column] = computer;
      }
      int maxColumnLength = 0;
      for (var row in computersGrid) {
        maxColumnLength =
            row.length > maxColumnLength ? row.length : maxColumnLength;
      }
      for (var row in computersGrid) {
        while (row.length < maxColumnLength) {
          row.add(null);
        }
      }
    } else {
      print('Failed to fetch computers: ${apiResponse.error}');
    }
    return computersGrid;
  }

// 在某个房间增加电脑
  Future<void> addComputer(
      ComputerRoom computerRoom, int row, int column, bool state) async {
    // 创建一个新的计算机对象
    Computer computer = Computer();

    // 设置计算机的属性
    computer.state = state;
    computer.row = row;
    computer.column = column;

    if (row == 0 || column == 0) {
      return;
    }

    // 检查数据库中是否存在与新计算机对象的关联、行和列都不重叠的计算机对象
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(Computer())
          ..whereEqualTo('Row', row)
          ..whereEqualTo('Column', column)
          ..whereMatchesQuery(
              Computer.keyRoom,
              QueryBuilder<ParseObject>(ComputerRoom())
                ..whereEqualTo('objectId', computerRoom.objectId));
    var countResponse = await queryBuilder.count();

    int count = countResponse.result ?? 0;

    if (count > 0) {
      print('与新计算机对象的关联、行和列有重叠的计算机对象已存在于数据库中，无法添加');
      return;
    }
    computer.addRelation(Computer.keyRoom, [computerRoom]);

    try {
      await computer.save();
      print('计算机信息已成功保存到数据库');
    } catch (e) {
      print('保存计算机信息时出错：$e');
    }
  }

  Future<List<ComputerLog>> fetchComputerLog(Computer computer) async {
    QueryBuilder<ParseObject> queryComputerLog =
        QueryBuilder<ParseObject>(ComputerLog())
          ..whereEqualTo('Computer', computer);

    var apiResponse = await queryComputerLog.query();

    List<ComputerLog> computerLogs = [];
    if (apiResponse.success) {
      if (apiResponse.count == 0) {
      } else {
        for (var parseObject in apiResponse.result) {
          var computerlog = ComputerLog.clone()..fromJson(parseObject.toJson());
          computerLogs.add(computerlog);
        }
      }
    } else {
      print('Failed to fetch data: ${apiResponse.error!.message}');
    }
    return computerLogs;
  }

  Future<void> reportComputerLog(
      Computer computer, String teacher, String describe) async {
    ComputerLog computerLog = ComputerLog();
    computerLog.teacher = teacher;
    computerLog.describe = describe;
    computerLog.addRelation(ComputerLog.keyComputer, [computer]);
    try {
      await computerLog.save();
      print('上报信息已成功保存到数据库');
      computer.set('state', false);
      computer.update();
    } catch (e) {
      print('保存上报信息时出错：$e');
    }
  }

  Future<void> fixComputer(Computer computer, ComputerLog computerLog) async {
    computerLog.state = true;
    computerLog.repairDate = DateTime.now();

    try {
      await computerLog.update();
      print('维修信息已上报');
      await fetchComputerLog(computer).then((value) {
        computer.state = true;
        for (ComputerLog log in value) {
          if (log.state == false) {
            computer.state = false;
          }
        }
        computer.update();
      });
    } catch (e) {
      print('维修信息上报时出错：$e');
    }
  }

//********预约********//
  Future<List<RoomReservation>> fetchRoomReservation(
      ComputerRoom computerRoom, DateTime date) async {
    DateTime endDate = date.add(Duration(days: 8));
    QueryBuilder<ParseObject> queryRoom =
        QueryBuilder<ParseObject>(RoomReservation())
          ..whereEqualTo('ComputerRoom', computerRoom)
          ..whereGreaterThan('StartDate', date)
          ..whereLessThan('StartDate', endDate);

    List<RoomReservation> roomReservations = [];

    var apiResponse = await queryRoom.query();

    if (apiResponse.success) {
      if (apiResponse.count == 0) {
      } else {
        for (var parseObject in apiResponse.result) {
          var roomReservation = RoomReservation.clone()
            ..fromJson(parseObject.toJson());
          roomReservations.add(roomReservation);
        }
      }
    } else {
      print('Failed to fetch data: ${apiResponse.error!.message}');
    }

    return roomReservations;
  }

  Future<void> bookComputerRoom(ComputerRoom computerRoom, DateTime date,
      int type, String course, String teacher, String className) async {
    RoomReservation roomReservation = RoomReservation();
    roomReservation.teacher = teacher;
    roomReservation.className = className;
    roomReservation.course = course;
    roomReservation
        .addRelation(RoomReservation.keyComputerRoom, [computerRoom]);
    roomReservation.type = type;
    switch (type) {
      case 1:
        roomReservation.startDate =
            DateTime(date.year, date.month, date.day, 8, 40);
        roomReservation.endDate =
            DateTime(date.year, date.month, date.day, 11, 10);
        break;
      case 2:
        roomReservation.startDate =
            DateTime(date.year, date.month, date.day, 10, 30);
        roomReservation.endDate =
            DateTime(date.year, date.month, date.day, 12, 00);
        break;
      case 3:
        roomReservation.startDate =
            DateTime(date.year, date.month, date.day, 12, 00);
        roomReservation.endDate =
            DateTime(date.year, date.month, date.day, 14, 00);
        break;
      case 4:
        roomReservation.startDate =
            DateTime(date.year, date.month, date.day, 14, 00);
        roomReservation.endDate =
            DateTime(date.year, date.month, date.day, 15, 30);
        break;
      case 5:
        roomReservation.startDate =
            DateTime(date.year, date.month, date.day, 15, 30);
        roomReservation.endDate =
            DateTime(date.year, date.month, date.day, 16, 30);
        break;
      default:
        break;
    }
    try {
      await roomReservation.save().then((value) {
        print('已成功预约机房');
      });
    } catch (e) {
      print('预约机房时出错：$e');
    }
  }

  //批量预约
  Future<void> bookMoreComputerRoom(ComputerRoom computerRoom, DateTime date,
      int type, String course, String teacher, String className) async {
    RoomReservation roomReservation = RoomReservation();
    roomReservation.teacher = teacher;
    roomReservation.className = className;
    roomReservation.course = course;
    roomReservation
        .addRelation(RoomReservation.keyComputerRoom, [computerRoom]);
    roomReservation.type = type;
    switch (type) {
      case 1:
        roomReservation.startDate =
            DateTime(date.year, date.month, date.day, 8, 40);
        roomReservation.endDate =
            DateTime(date.year, date.month, date.day, 11, 10);
        break;
      case 2:
        roomReservation.startDate =
            DateTime(date.year, date.month, date.day, 10, 30);
        roomReservation.endDate =
            DateTime(date.year, date.month, date.day, 12, 00);
        break;
      case 3:
        roomReservation.startDate =
            DateTime(date.year, date.month, date.day, 12, 00);
        roomReservation.endDate =
            DateTime(date.year, date.month, date.day, 14, 00);
        break;
      case 4:
        roomReservation.startDate =
            DateTime(date.year, date.month, date.day, 14, 00);
        roomReservation.endDate =
            DateTime(date.year, date.month, date.day, 15, 30);
        break;
      case 5:
        roomReservation.startDate =
            DateTime(date.year, date.month, date.day, 15, 30);
        roomReservation.endDate =
            DateTime(date.year, date.month, date.day, 16, 30);
        break;
      default:
        break;
    }
    try {
      await roomReservation.save().then((value) {
        print('已成功预约机房');
      });
    } catch (e) {
      print('预约机房时出错：$e');
    }
  }
}
