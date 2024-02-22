part of 'school_computer_sys_bloc.dart';

// 定义事件
abstract class SchoolComputerSysEvent extends Equatable {
  const SchoolComputerSysEvent();

  @override
  List<Object> get props => [];
}

class SchoolComputerInitialEvent extends SchoolComputerSysEvent {}

class SchoolComputerLoadEvent extends SchoolComputerSysEvent {
  final ComputerRoom computerRoom;

  const SchoolComputerLoadEvent({required this.computerRoom});
}
