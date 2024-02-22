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
