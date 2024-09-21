import 'package:meta/meta.dart';

part 'charts_event.dart';
part 'charts_state.dart';

// class ChartsBloc extends Bloc<ChartsEvent, ChartsState> {
//   final DbBloc dbBloc;
//   List<PieChartSectionData> data = [];
//   ChartsBloc() : super(ChartsInitial()) {
//     on<ChartsLoadData>((event, emit) {
//       emit(ChartsDataLoading());
//       dbBloc.apps;
//       emit(ChartsDataLoaded());
//     });
//   }
// }
