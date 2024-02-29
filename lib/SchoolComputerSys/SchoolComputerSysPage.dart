import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:xintai_school/ParseManager.dart';
import 'package:xintai_school/SchoolComputerSys/Prase/SchoolComputerParseManager.dart';
import 'package:xintai_school/SchoolComputerSys/SchoolComputerSettingPage.dart';
import 'package:xintai_school/SchoolComputerSys/Prase/SchoolComputerModel.dart';

import 'bloc/school_computer_sys_bloc.dart';

class SchoolComputerSysPage extends StatefulWidget {
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
        title: const Text('路桥学院电脑状况登记'),
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
                  Center(
                    child: Lottie.asset(
                        'assets/blackboard.json', // 替换为您的Lottie动画文件路径
                        fit: BoxFit.contain,
                        height: 150),
                  ),
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
                    child: Text('刷新'),
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
      padding: EdgeInsets.all(20.0),
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

        // For headers
        if (rowIndex == 0 || colIndex == 0) {
          String text;
          if (rowIndex == 0 && colIndex == 0) {
            text = '';
          } else if (rowIndex == 0) {
            text = '${colIndex}列';
          } else {
            text = '${rowIndex}排';
          }
          return Container(
            alignment: Alignment.center,
            color: Colors.grey[300],
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
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
                      title: Text("管理弹窗"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: InputDecoration(labelText: '行'),
                            onChanged: (value) {
                              row = int.tryParse(value) ?? 0; // 解析行号并存储
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: '列'),
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
                          child: Text("提交"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("关闭"),
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
                      title: Text("管理弹窗"),
                      content: Text("请联系管理员孔繁臻"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("关闭"),
                        ),
                      ],
                    );
                  },
                );
              }
            });
          },
          child: Text("增删电脑"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }
}
