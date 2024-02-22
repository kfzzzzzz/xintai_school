import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:xintai_school/ParseManager.dart';
import 'package:xintai_school/SchoolComputerSys/model/SchoolComputerModel.dart';

part 'school_computer_sys_event.dart';
part 'school_computer_sys_state.dart';

class SchoolComputerSysBloc
    extends Bloc<SchoolComputerSysEvent, SchoolComputerSysState> {
  late List<ComputerRoom> computerRooms;
  SchoolComputerSysBloc()
      : super(const SchoolComputerInitialState(computerRooms: [])) {
    on<SchoolComputerInitialEvent>((event, emit) async {
      emit(SchoolComputerLoadingState());
      await ParseManager().fetchComputerRoom().then((value) async {
        computerRooms = value;
        if (value == []) {
          emit(const SchoolComputerErrorState("数据为空1"));
        } else {
          emit(SchoolComputerInitialState(computerRooms: computerRooms));
          try {
            final computers =
                await ParseManager().fetchComputer(value.first.room);
            emit(SchoolComputerLoadedState(computerRooms, computers));
          } catch (error) {
            emit(SchoolComputerErrorState("错误1:$error"));
          }
        }
      }).onError((error, stackTrace) {
        emit(SchoolComputerErrorState("错误2:$error"));
      });
    });
    on<SchoolComputerLoadEvent>((event, emit) async {
      emit(SchoolComputerLoadingState());
      await ParseManager().fetchComputer(event.computerRoom.room).then((value) {
        if (value.isEmpty) {
          emit(const SchoolComputerErrorState("数据为空2"));
        } else {
          emit(SchoolComputerLoadedState(computerRooms, value));
        }
      }).onError((error, stackTrace) {
        emit(SchoolComputerErrorState("错误3:$error"));
      });
    });
  }
}
