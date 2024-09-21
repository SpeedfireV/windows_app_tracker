part of 'db_bloc.dart';

@immutable
sealed class DbEvent {}

final class DbInit extends DbEvent {}

final class DbAddRecord extends DbEvent {
  final App app;

  DbAddRecord(this.app);
}

final class DbGetRecords extends DbEvent {}
