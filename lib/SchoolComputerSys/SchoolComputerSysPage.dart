import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xintai_school/ParseManager.dart';
import 'package:xintai_school/SchoolComputerSys/Prase/SchoolComputerParseManager.dart';
import 'package:xintai_school/SchoolComputerSys/SchoolComputerReservationPage.dart';
import 'package:xintai_school/SchoolComputerSys/SchoolComputerSettingPage.dart';
import 'package:xintai_school/SchoolComputerSys/Prase/SchoolComputerModel.dart';

import 'bloc/school_computer_sys_bloc.dart';

class SchoolComputerSysPage extends StatefulWidget {
  const SchoolComputerSysPage({super.key});

  @override
  _SchoolComputerSysPageState createState() => _SchoolComputerSysPageState();
}

class _SchoolComputerSysPageState extends State<SchoolComputerSysPage> {
  final SchoolComputerSysBloc _bloc = SchoolComputerSysBloc();
  late ComputerRoom _selectComputerRoom;

  @override
  void initState() {
    super.initState();
    _bloc.add(SchoolComputerInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('路桥学院机房情况'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help, color: Colors.grey),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _buildHelpDialog(context);
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SchoolComputerSysBloc, SchoolComputerSysState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is SchoolComputerInitialState) {
            if (state.computerRooms.isNotEmpty) {
              _selectComputerRoom = state.computerRooms.first;
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SchoolComputerLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SchoolComputerLoadedState) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropDownButton(state.computerRooms),
                      ),
                      _buildComputerAddDelete(_selectComputerRoom),
                    ],
                  ),
                  _buildComputerRoomDetail(
                      state.computers, state.roomReservations),
                  Expanded(
                    child: _buildComputerContent(
                        state.computers, _selectComputerRoom.room),
                  ),
                ]);
          } else if (state is SchoolComputerErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error),
                  ElevatedButton(
                    onPressed: () {
                      _bloc.add(SchoolComputerInitialEvent()); // 这里替换为你的事件
                    },
                    child: const Text('刷新'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('未知状态'),
            );
          }
        },
      ),
    );
  }

  Widget _buildDropDownButton(List<ComputerRoom> computerRooms) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: DropdownButton<ComputerRoom>(
        value: _selectComputerRoom,
        onChanged: (ComputerRoom? newValue) {
          _selectComputerRoom = newValue!;
          _bloc.add(SchoolComputerLoadEvent(computerRoom: newValue));
        },
        alignment: Alignment.center,
        items: computerRooms
            .map<DropdownMenuItem<ComputerRoom>>((ComputerRoom room) {
          return DropdownMenuItem<ComputerRoom>(
            value: room,
            alignment: Alignment.center,
            child: Text(room.room),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComputerRoomDetail(
      List<List<Computer?>> computers, List<RoomReservation> roomReservations) {
    List<int> computerRoomComputerDetail = countComputers(computers);
    List<String> computerRoomTeacherDetail =
        computerRoomTeacher(roomReservations);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '电脑总数: ${computerRoomComputerDetail[0]}台',
              style:
                  const TextStyle(color: Colors.black, height: 2, fontSize: 20),
            ),
            Text(
              '故障数量: ${computerRoomComputerDetail[1]}台',
              style:
                  const TextStyle(color: Colors.red, height: 2, fontSize: 20),
            ),
            Text(
              '可用数量: ${computerRoomComputerDetail[2]}台',
              style:
                  const TextStyle(color: Colors.green, height: 2, fontSize: 20),
            ),
          ],
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SchoolComputerReservationPage(
                          roomReservations: roomReservations,
                          computerRoom: _selectComputerRoom)),
                ).then((value) {
                  _bloc.add(SchoolComputerLoadEvent(
                      computerRoom: _selectComputerRoom));
                });
              },
              child: const Text('预约教室'),
            ),
            Text(
              '当前课程: ${computerRoomTeacherDetail[1]}',
              style:
                  const TextStyle(color: Colors.black, height: 2, fontSize: 20),
            ),
            Text(
              '当前教师: ${computerRoomTeacherDetail[0]}',
              style:
                  const TextStyle(color: Colors.black, height: 2, fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComputerContent(
      List<List<Computer?>> computers, String computerRoom) {
    int rowCount = computers.length;
    int columnCount = computers.isEmpty ? 0 : computers[0].length;

    return GridView.builder(
      itemCount: (rowCount + 1) * (columnCount + 1),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount + 1,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        int rowIndex = index ~/ (columnCount + 1);
        int colIndex = index % (columnCount + 1);

        if (rowIndex == 0 || colIndex == 0) {
          String text;
          if (rowIndex == 0 && colIndex == 0) {
            text = '';
          } else if (rowIndex == 0) {
            text = '$colIndex列';
          } else {
            text = '$rowIndex排';
          }
          return Container(
            alignment: Alignment.center,
            color: Colors.grey[300],
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        } else {
          Computer? computer = computers[rowIndex - 1][colIndex - 1];
          IconData iconData;
          Color iconColor;

          if (computer == null) {
            iconData = Icons.do_not_disturb;
            iconColor = Colors.black;

            return Container(
              alignment: Alignment.center,
              child: Icon(
                iconData,
                color: iconColor,
              ),
            );
          } else {
            iconData = Icons.personal_video;
            iconColor = computer.state == true ? Colors.green : Colors.red;
          }

          return Material(
            elevation: 4.0, // 设置阴影的高度，这里设置为4.0，您可以根据需要调整
            borderRadius: BorderRadius.circular(8.0), // 设置边框圆角
            child: InkWell(
              onLongPress: () async {
                await SchoolComputerParseManager()
                    .fetchComputerLog(computer)
                    .then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SchoolComputerSettingPage(
                            computer: computer,
                            computerRoom: computerRoom,
                            computerLogs: value)),
                  ).then((value) {
                    _bloc.add(SchoolComputerLoadEvent(
                        computerRoom: _selectComputerRoom));
                  });
                });
              },
              child: Icon(
                iconData,
                color: iconColor,
              ),
            ),
          );
        }
      },
    );
  }

  //增删电脑的弹窗
  Widget _buildComputerAddDelete(ComputerRoom computerRoom) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            await ParseManager().currentUser().then((value) {
              if (value == 'kfzzzzzz') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    int row = 0; // 用于存储填写的行号
                    int column = 0; // 用于存储填写的列号

                    return AlertDialog(
                      title: const Text("管理弹窗"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: const InputDecoration(labelText: '行'),
                            onChanged: (value) {
                              row = int.tryParse(value) ?? 0; // 解析行号并存储
                            },
                          ),
                          TextField(
                            decoration: const InputDecoration(labelText: '列'),
                            onChanged: (value) {
                              column = int.tryParse(value) ?? 0; // 解析列号并存储
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            try {
                              await SchoolComputerParseManager()
                                  .addComputer(computerRoom, row, column, true);
                              Fluttertoast.showToast(
                                msg: "添加计算机成功",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                              );
                              _bloc.add(SchoolComputerLoadEvent(
                                  computerRoom: computerRoom));
                            } catch (e) {
                              Fluttertoast.showToast(
                                msg: "添加计算机失败: $e",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                              );
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text("提交"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("关闭"),
                        ),
                      ],
                    );
                  },
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("管理弹窗"),
                      content: const Text("请联系管理员孔繁臻"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("关闭"),
                        ),
                      ],
                    );
                  },
                );
              }
            });
          },
          child: const Text("增删电脑"),
        ),
      ],
    );
  }

// 帮助弹窗
  Widget _buildHelpDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('使用帮助'),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('1.方向：前方为讲台方向（第一排为教室讲台前排，第八列为右侧靠门列）'),
            Text('2.上报：长按对应的电脑图标，进入上报页面'),
            Text('3.状态：绿色机器代表可用，红色代表存在故障未解决'),
            Text('4.预约：预约教室按钮，可进行往后一周时间的预约'),
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

  //计算机数目计算
  List<int> countComputers(List<List<Computer?>> computers) {
    int totalCount = 0;
    int falseCount = 0;
    for (List<Computer?> sublist in computers) {
      totalCount += sublist.where((computer) => computer != null).length;
      falseCount +=
          sublist.where((computer) => computer?.state == false).length;
    }
    int trueCount = totalCount - falseCount;

    return [totalCount, falseCount, trueCount];
  }

  //当前教师计算
  List<String> computerRoomTeacher(List<RoomReservation> roomReservations) {
    DateTime now = DateTime.now().toUtc();

    for (var reservation in roomReservations) {
      if (now.isAfter(reservation.startDate!) &&
          now.isBefore(reservation.endDate!)) {
        return [reservation.teacher, reservation.course];
      }
    }
    return ['无', '空闲'];
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }
}
