import 'package:bloc/bloc.dart';

class SwitchAllCubit extends Cubit<bool> {
  SwitchAllCubit() : super(true);
  void switchSelection() {
    emit(!state);
  }
}
