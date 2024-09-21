part of 'db_bloc.dart';

@immutable
sealed class DbEvent {}

final class DbInit extends DbEvent {}

final class DbAddRecord extends DbEvent {}

final class DbGetRecords extends DbEvent {}
