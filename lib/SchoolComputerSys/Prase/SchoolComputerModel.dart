import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ComputerRoom extends ParseObject implements ParseCloneable {
  ComputerRoom() : super(_keyTableName);
  ComputerRoom.clone() : this();

  @override
  clone(Map map) =>
      ComputerRoom.clone()..fromJson(Map<String, dynamic>.from(map));

  static const String _keyTableName = 'computerRoom';
  static const String keyRoom = 'Room';
  static const String keyRow = 'Row';
  static const String keyColumn = 'Column';

  String get room => get<String>(keyRoom) ?? "";
  set room(String room) => set<String>(keyRoom, room);

  int get row => get<int>(keyRow) ?? 1;
  set row(int row) => set<int>(keyRow, row);

  int get column => get<int>(keyColumn) ?? 1;
  set column(int column) => set<int>(keyColumn, column);
}

class Computer extends ParseObject implements ParseCloneable {
  Computer() : super(_keyTableName);
  Computer.clone() : this();

  @override
  clone(Map map) => Computer.clone()..fromJson(Map<String, dynamic>.from(map));

  static const String _keyTableName = 'computer';
  static const String keyState = 'state';
  static const String keyRow = 'Row';
  static const String keyColumn = 'Column';
  static const String keyRoom = 'Room';

  bool get state => get<bool>(keyState) ?? false;
  set state(bool state) => set<bool>(keyState, state);

  int get row => get<int>(keyRow) ?? 1;
  set row(int row) => set<int>(keyRow, row);

  int get column => get<int>(keyColumn) ?? 1;
  set column(int column) => set<int>(keyColumn, column);

  // ParseRelation to ComputerRoom
  ParseRelation<ComputerRoom> get roomRelation =>
      getRelation<ComputerRoom>(keyRoom);
}

class ComputerLog extends ParseObject implements ParseCloneable {
  ComputerLog() : super(_keyTableName);
  ComputerLog.clone() : this();

  @override
  clone(Map map) =>
      ComputerLog.clone()..fromJson(Map<String, dynamic>.from(map));

  static const String _keyTableName = 'computerLog';
  static const String keyState = 'state';
  static const String keyTeacher = 'Teacher';
  static const String keyDescribe = 'Describe';
  static const String keyRepairDate = 'RepairDate';
  static const String keyComputer = 'Computer';

  bool get state => get<bool>(keyState) ?? false;
  set state(bool state) => set<bool>(keyState, state);

  String get teacher => get<String>(keyTeacher) ?? '';
  set teacher(String teacher) => set<String>(keyTeacher, teacher);

  String get describe => get<String>(keyDescribe) ?? '';
  set describe(String describe) => set<String>(keyDescribe, describe);

  DateTime? get repairDate => get<DateTime?>(keyRepairDate);
  set repairDate(DateTime? repairDate) =>
      set<DateTime?>(keyRepairDate, repairDate);

  ParseRelation<Computer> get computerRelation =>
      getRelation<Computer>(keyComputer);
}

class RoomReservation extends ParseObject implements ParseCloneable {
  RoomReservation() : super(_keyTableName);
  RoomReservation.clone() : this();

  @override
  RoomReservation clone(Map<String, dynamic> map) =>
      RoomReservation.clone()..fromJson(Map<String, dynamic>.from(map));

  static const String _keyTableName = 'roomReservation';
  static const String keyTeacher = 'Teacher';
  static const String keyStartDate = 'StartDate';
  static const String keyEndDate = 'EndDate';
  static const String keyComputerRoom = 'ComputerRoom';
  static const String keyCourse = 'Course';

  String get teacher => get<String>(keyTeacher) ?? '';
  set teacher(String teacher) => set<String>(keyTeacher, teacher);

  DateTime? get startDate => get<DateTime?>(keyStartDate);
  set startDate(DateTime? startDate) => set<DateTime?>(keyStartDate, startDate);

  DateTime? get endDate => get<DateTime?>(keyEndDate);
  set endDate(DateTime? endDate) => set<DateTime?>(keyEndDate, endDate);

  ParseRelation<ComputerRoom> get computerRoomRelation =>
      getRelation<ComputerRoom>(keyComputerRoom);

  String get course => get<String>(keyCourse) ?? '';
  set course(String course) => set<String>(keyCourse, course);
}
