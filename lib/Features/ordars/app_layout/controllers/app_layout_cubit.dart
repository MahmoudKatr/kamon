import 'package:flutter_bloc/flutter_bloc.dart';

/// AppLayoutCubit
class AppLayoutCubit extends Cubit<int> {
  /// AppLayoutCubit constructor
  AppLayoutCubit() : super(0);

  /// changeIndex
  void changeIndex(int index) {
    emit(index);
  }
}
