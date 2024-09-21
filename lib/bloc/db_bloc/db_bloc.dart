import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../models/app.dart';
import '../../services/db_services.dart';

part 'db_event.dart';
part 'db_state.dart';

class DbBloc extends Bloc<DbEvent, DbState> {
  late final DbServices dbServices;
  Iterable<App> apps = [];
  DbBloc() : super(DbInitial()) {
    on<DbInit>((event, emit) async {
      emit(DbInitializing());
      dbServices = DbServices();
      await dbServices.initDb();
      print("INITIALIZING!");
      emit(DbInitialized());
    });
    on<DbAddRecord>((event, emit) async {
      emit(DbAddingRecord());
      await dbServices.addRecord(event.app);
      emit(DbAddedRecord());
    });
    on<DbGetRecords>((event, emit) async {
      emit(DbGettingRecords());
      apps = await dbServices.getRecords();
      emit(DbGotRecords());
    });
  }

  @override
  void onChange(Change<DbState> change) {
    super.onChange(change);
    print(change);
  }
}
