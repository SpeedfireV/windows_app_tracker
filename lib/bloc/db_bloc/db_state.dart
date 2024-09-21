part of 'db_bloc.dart';

@immutable
sealed class DbState {}

final class DbInitial extends DbState {}

final class DbInitializing extends DbState {}

final class DbInitialized extends DbState {}

final class DbAddingRecord extends DbState {}

final class DbAddedRecord extends DbState {}

final class DbGettingRecords extends DbState {}

final class DbGotRecords extends DbState {}
