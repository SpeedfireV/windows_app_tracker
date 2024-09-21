part of 'charts_bloc.dart';

@immutable
sealed class ChartsState {}

final class ChartsInitial extends ChartsState {}

final class ChartsDataLoading extends ChartsState {}

final class ChartsDataLoaded extends ChartsState {}
