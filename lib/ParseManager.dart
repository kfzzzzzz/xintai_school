import "package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart";
import "package:xintai_school/SchoolComputerSys/model/SchoolComputerModel.dart";

class ParseManager {
  static final ParseManager _instance = ParseManager._internal();

  factory ParseManager() {
    return _instance;
  }

  ParseManager._internal();

  static const String _applicationId = 'kfzzzzzz.SimulateLocation';
  static const String _serverUrl = 'http://121.43.102.102:1337/parse';
  static const String _clientKey = 'kfzzzzzz.SimulateLocation';

  bool _initialized = false;

  Future<void> initializeParse() async {
    if (!_initialized) {
      await Parse().initialize(
        _applicationId,
        _serverUrl,
        clientKey: _clientKey,
        autoSendSessionId: true,
        debug: true,
        registeredSubClassMap: <String, ParseObjectConstructor>{
          'computerRoom': () => ComputerRoom(),
          'computer': () => Computer()
        },
      );
      _initialized = true;
    }
  }

  Future<String> currentUser() async {
    final currentUser = await ParseUser.currentUser();
    if (currentUser == null) {
      return "无用户";
    }
    return currentUser.username;
  }

  Future<String> loginUser(String username, String password) async {
    try {
      final ParseUser user = ParseUser(username, password, null);

      final ParseResponse response = await user.login();

      if (response.success) {
        return 'Login successful!';
      } else {
        return 'Login failed: ${response.error?.message ?? 'Unknown error'}';
      }
    } catch (e) {
      return 'Error occurred during login: $e';
    }
  }

  Future<void> logoutUser() async {
    try {
      final currentUser = await ParseUser.currentUser();
      final ParseResponse response = await currentUser.logout();

      if (response.success) {
        print('Logout successful!');
      } else {
        print('Logout failed: ${response.error}');
      }
    } catch (e) {
      print('Error occurred during Logout: $e');
    }
  }

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
  Future<List<List<Computer?>>> fetchComputer(String computerRoom) async {
    QueryBuilder<ParseObject> queryComputerRoom =
        QueryBuilder<ParseObject>(ComputerRoom())
          ..whereEqualTo('Room', computerRoom);

    QueryBuilder<ParseObject> queryComputer =
        QueryBuilder<ParseObject>(Computer())
          ..whereMatchesQuery('Room', queryComputerRoom);

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

// 解析计数响应以获取实际计数值
    int count = countResponse.result ?? 0;

    if (count > 0) {
      print('与新计算机对象的关联、行和列有重叠的计算机对象已存在于数据库中，无法添加');
      return; // 如果有重叠的计算机对象，则直接返回，不执行保存操作
    }

    // 将计算机对象与房间对象建立关联
    computer.addRelation(Computer.keyRoom, [computerRoom]);

    // 保存计算机对象到数据库
    try {
      await computer.save(); // 保存对象
      print('计算机信息已成功保存到数据库');
    } catch (e) {
      print('保存计算机信息时出错：$e');
      // 可以在这里抛出异常或者处理错误信息
    }
  }

  static ParseManager get instance => _instance;
}
