import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xintai_school/SchoolComputerSys/Prase/SchoolComputerModel.dart';
import 'package:xintai_school/SchoolComputerSys/Prase/SchoolComputerParseManager.dart';
import 'package:intl/intl.dart';

class SchoolComputerSettingPage extends StatefulWidget {
  final Computer computer;
  final String computerRoom;
  final List<ComputerLog> computerLogs;

  const SchoolComputerSettingPage(
      {super.key,
      required this.computer,
      required this.computerRoom,
      required this.computerLogs});
  @override
  _SchoolComputerSettingPageState createState() =>
      _SchoolComputerSettingPageState();
}

class _SchoolComputerSettingPageState extends State<SchoolComputerSettingPage> {
  @override
  Widget build(BuildContext context) {
    String room = widget.computerRoom;
    int row = widget.computer.row;
    int column = widget.computer.column;
    List<ComputerLog> computerLogs = widget.computerLogs;

    List<DataRow> dataRows = computerLogs.asMap().entries.map((entry) {
      int index = entry.key;
      ComputerLog log = entry.value;
      DateTime date = log.createdAt!;
      String reportDate = DateFormat('MM-dd').format(date);
      String? repairDate = log.repairDate != null
          ? DateFormat('MM-dd').format(log.repairDate!)
          : null;
      return DataRow.byIndex(
          index: index,
          cells: [
            DataCell(Text('${index + 1}')),
            DataCell(Text(reportDate)),
            DataCell(Text('${log.teacher}')),
            DataCell(Text('${log.describe}')),
            DataCell(Text('${log.state}')),
            DataCell(Text(repairDate ?? "")),
          ],
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('您是否确认已经维修该问题？'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // 关闭对话框并返回 false
                      },
                      child: Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true); // 关闭对话框并返回 true
                      },
                      child: Text('确认'),
                    ),
                  ],
                );
              },
            ).then((value) async {
              if (value != null && value) {
                await SchoolComputerParseManager()
                    .fixComputer(widget.computer, computerLogs[index])
                    .then((value) {
                  Fluttertoast.showToast(
                    msg: "已收到维修成功消息",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                }).onError((error, stackTrace) {
                  Fluttertoast.showToast(
                    msg: "维修信息上报失败",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                });
              } else {
                // 用户取消维修，执行相应的操作
                print('用户取消维修');
              }
            });
          });
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('房间:$room 第$row排 第$column列'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: DataTable2(
                columnSpacing: 5,
                horizontalMargin: 0,
                dataRowHeight: 160,
                columns: [
                  DataColumn2(label: Text('序号'), size: ColumnSize.S),
                  DataColumn2(
                    label: Text('上报时间'),
                  ),
                  DataColumn2(
                    label: Text('上报人'),
                  ),
                  DataColumn2(label: Text('问题描述'), size: ColumnSize.L),
                  DataColumn2(
                    label: Text('是否维修'),
                  ),
                  DataColumn2(
                    label: Text('维修日期'),
                  ),
                ],
                rows: dataRows,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String teacherName = '';
                    String problemDescription = '';

                    return AlertDialog(
                      title: Text('上报问题'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(labelText: '教师名字'),
                            onChanged: (value) {
                              teacherName = value;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: '问题描述'),
                            onChanged: (value) {
                              problemDescription = value;
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
                            if (teacherName == '' || problemDescription == '') {
                              Fluttertoast.showToast(
                                msg: "请输入教师名字及问题描述",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                              );
                            } else {
                              await SchoolComputerParseManager()
                                  .reportComputerLog(widget.computer,
                                      teacherName, problemDescription)
                                  .then((value) {
                                Navigator.of(context).pop();
                                Fluttertoast.showToast(
                                  msg: "上报问题成功",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                );
                              }).onError((error, stackTrace) {
                                Fluttertoast.showToast(
                                  msg: "上报问题失败，请稍后再试或联系孔繁臻",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                );
                              });
                            }
                          },
                          child: Text('上报'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('上报问题'),
            ),
          ],
        ),
      ),
    );
  }
}
