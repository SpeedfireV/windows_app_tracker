import 'package:bloc/bloc.dart';

class ExpandedCubit extends Cubit<List<String>> {
  ExpandedCubit() : super([]);
  void addExpanded(String app) {
    List<String> newList = [];
    if (state.contains(app)) {
      newList.addAll(state.where((String currentApp) {
        return currentApp != app;
      }));
    } else {
      newList.addAll(state);
      newList.add(app);
    }
    emit(newList);
  }
}
