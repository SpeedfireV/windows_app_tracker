import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'selected_data_state.dart';

class SelectedDataCubit extends Cubit<SelectedDataState> {
  SelectedDataCubit() : super(SelectedDataInitial());
}
