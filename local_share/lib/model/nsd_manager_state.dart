import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nsd/nsd.dart';

part 'nsd_manager_state.freezed.dart';

@freezed
abstract class NsdManagerState with _$NsdManagerState {
  const factory NsdManagerState({
     @Default([]) List<Discovery> discoveries,
     @Default([]) List<Registration> registrations
  }) = _NsdManagerState;
}