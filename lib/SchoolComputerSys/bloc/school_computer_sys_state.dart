part of 'school_computer_sys_bloc.dart';

// 定义状态
abstract class SchoolComputerSysState extends Equatable {
  const SchoolComputerSysState();

  @override
  List<Object> get props => [];
}

class SchoolComputerInitialState extends SchoolComputerSysState {
  final List<ComputerRoom> computerRooms;

  const SchoolComputerInitialState({required this.computerRooms});
}

class SchoolComputerLoadingState extends SchoolComputerSysState {}

class SchoolComputerLoadedState extends SchoolComputerSysState {
  final List<ComputerRoom> computerRooms;
  final List<List<Computer?>> computers;
  final List<RoomReservation> roomReservations;

  const SchoolComputerLoadedState(
      this.computerRooms, this.computers, this.roomReservations);

  @override
  List<Object> get props => [computerRooms];
}

class SchoolComputerErrorState extends SchoolComputerSysState {
  final String error;

  const SchoolComputerErrorState(this.error);

  @override
  List<Object> get props => [error];
}
