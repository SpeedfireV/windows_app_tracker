import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../functions.dart';
import '../../models/app.dart';
import '../../services/db_services.dart';

part 'db_event.dart';
part 'db_state.dart';

class DbBloc extends Bloc<DbEvent, DbState> {
  late final DbServices dbServices;
  Iterable<App> apps = [];
  Iterable<App> latestApps = [];

  DbBloc() : super(DbInitial()) {
    on<DbInit>((event, emit) async {
      emit(DbInitializing());
      dbServices = DbServices();
      await dbServices.initDb();
      apps = await dbServices.getRecords();
      latestApps = await dbServices.getLatestRecords();
      print("INITIALIZING!");
      emit(DbInitialized());
    });
    on<DbAddRecord>((event, emit) async {
      emit(DbAddingRecord());
      final App? currentlyOpenApp = await trackActiveApp();
      if (currentlyOpenApp != null) {
        await dbServices.addRecord(currentlyOpenApp);
      }

      emit(DbAddedRecord());
    });
    on<DbGetRecords>((event, emit) async {
      emit(DbGettingRecords());
      apps = await dbServices.getRecords();
      latestApps = await dbServices.getLatestRecords();
      emit(DbGotRecords());
    });
  }

  @override
  void onChange(Change<DbState> change) {
    super.onChange(change);
    print(change);
  }
}
