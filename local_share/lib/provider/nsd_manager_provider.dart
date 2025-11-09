import 'dart:convert';
import 'dart:typed_data';

import 'package:local_share/model/nsd_manager_state.dart';
import 'package:nsd/nsd.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nsd_manager_provider.g.dart';

// Provider for storing measurements
@riverpod
class NSDManager extends _$NSDManager {
  final int port = 56360;
  final String serviceTypeDiscover = '_http._tcp';
  final String serviceTypeRegister = '_http._tcp';
  final utf8encoder = Utf8Encoder();

  @override
  NsdManagerState build() {
    return NsdManagerState();
  }

  Future<void> addDiscovery() async {
    final discovery = await startDiscovery(serviceTypeDiscover);
    List<Discovery> newDiscoveries = [...state.discoveries];
    newDiscoveries.add(discovery);
    state = state.copyWith(discoveries: newDiscoveries);
  }

  Future<void> dismissDiscovery(Discovery discovery) async {
    final newDiscoveries = [...state.discoveries];
    newDiscoveries.remove(discovery);
    state = state.copyWith(discoveries: newDiscoveries);
    await stopDiscovery(discovery);
  }

  Future<void> addRegistration() async {
    final service = Service(
        name: 'Some Service',
        type: serviceTypeRegister,
        port: port,
        txt: _createTxt());
    final registration = await register(service);
    final newRegistrations = [...state.registrations];
    newRegistrations.add(registration);
    state = state.copyWith(registrations: newRegistrations);
  }

  Future<void> dismissRegistration(Registration registration) async {
    final newRegistrations = [...state.registrations];
    newRegistrations.remove(registration);
    state = state.copyWith(registrations: newRegistrations);
    await unregister(registration);
  }

  /// Creates a txt attribute object that showcases the most common use cases.
  Map<String, Uint8List?> _createTxt() {
    return <String, Uint8List?>{
      'a-string': utf8encoder.convert('κόσμε'),
      'a-blank': Uint8List(0),
      'a-null': null,
    };
  }
}