import 'package:bloc/bloc.dart';

class ExpandedCubit extends Cubit<String?> {
  ExpandedCubit() : super(null);

  void closeExpanded() {
    emit(null);
  }

  void addExpanded(String app) {
    emit(app);
  }
}
