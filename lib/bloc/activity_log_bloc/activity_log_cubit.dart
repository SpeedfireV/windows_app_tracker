import 'package:bloc/bloc.dart';

class ActivityLogCubit extends Cubit<bool> {
  ActivityLogCubit() : super(true);
  void switchScrollToTheBottom() {
    emit(!state);
  }
}
