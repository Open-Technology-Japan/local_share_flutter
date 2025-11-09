import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter_provider.g.dart';

// Provider for storing measurements
@riverpod
class Counter extends _$Counter {
  @override
  int build() {
    return 0;
  }
  void increment() {
    state = state + 1;
  }
}