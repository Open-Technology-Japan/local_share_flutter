import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nsd/nsd.dart';

part 'nsd_manager_state.freezed.dart';

const int ephemeralPort = 49152;

@freezed
abstract class NsdManagerState with _$NsdManagerState {
  const factory NsdManagerState({
     @Default("") String updateChecker,
     @Default(ephemeralPort) int port,
     @Default([]) List<Discovery> discoveries,
     @Default([]) List<Registration> registrations
  }) = _NsdManagerState;
}