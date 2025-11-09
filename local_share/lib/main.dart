import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:local_share/provider/nsd_manager_provider.dart';
import 'package:nsd/nsd.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(nSDManagerProvider.notifier);
    final discoveries = ref.watch(nSDManagerProvider.select( (selector) => selector.discoveries ));
    final registrations = ref.watch(nSDManagerProvider.select((selector) => selector.registrations));

    useEffect(() {
      enableLogging(LogTopic.calls);
      return null;
    },[]);

    return MaterialApp(
      home: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          spacing: 10,
          spaceBetweenChildren: 5,
          children: [
            SpeedDialChild(
              elevation: 2,
              child: const Icon(Icons.wifi_tethering),
              label: 'Register Service',
              onTap: () async => notifier.addRegistration(),
            ),
            SpeedDialChild(
              elevation: 2,
              child: const Icon(Icons.wifi_outlined),
              label: 'Start Discovery',
              onTap: () async => notifier.addDiscovery(),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: ScrollController(),
                itemBuilder: (context, index) {
                  final notifier = ref.read(nSDManagerProvider.notifier);
                  final registrations = ref.watch(nSDManagerProvider.select( (selector) => selector.registrations ));
                  final registration = registrations.elementAt(index);
                  return Dismissible(
                      key: ValueKey(registration.id),
                      onDismissed: (_) async => notifier.dismissRegistration(registration),
                      child: RegistrationWidget(registration: registration));
                },
                itemCount:  registrations.length,
              ),
            ),
            const Divider(
              height: 20,
              thickness: 4,
              indent: 0,
              endIndent: 0,
              color: Colors.blue,
            ),
            Expanded(
              child: ListView.builder(
                controller: ScrollController(),
                itemBuilder: (context, index) {
                  final notifier = ref.read(nSDManagerProvider.notifier);
                  final discoveries = ref.watch(nSDManagerProvider.select( (selector) => selector.discoveries ));
                  final discovery = discoveries.elementAt(index);
                  return Dismissible(
                      key: ValueKey(discovery.id),
                      onDismissed: (_) async => notifier.dismissDiscovery(discovery),
                      child: DiscoveryWidget(id: discovery.id));
                },
                itemCount: discoveries.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscoveryWidget extends ConsumerWidget {
  const DiscoveryWidget({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoveries = ref.watch(nSDManagerProvider.select( (selector) => selector.discoveries ));
    final discovery = discoveries.firstWhere((discovery) => discovery.id == id);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListTile(
              leading: const Icon(Icons.wifi_outlined),
              title: Text('Discovery ${shorten(discovery.id)}')),
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: DataTable(
                  headingRowHeight: 24,
                  dataRowMinHeight: 24,
                  dataRowMaxHeight: 24,
                  dataTextStyle: const TextStyle(color: Colors.black, fontSize: 12),
                  columnSpacing: 8,
                  horizontalMargin: 0,
                  headingTextStyle: const TextStyle(
                      color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600),
                  columns: <DataColumn>[
                    buildDataColumn('Name'),
                    buildDataColumn('Type'),
                    buildDataColumn('Host'),
                    buildDataColumn('Port'),
                  ],
                  rows: buildDataRows(discovery),
                ),
              ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }

  DataColumn buildDataColumn(String name) {
    return DataColumn(
      label: Text(
        name,
      ),
    );
  }

  List<DataRow> buildDataRows(Discovery discovery) {
    return discovery.services
        .map((e) => DataRow(
      cells: <DataCell>[
        DataCell(Text(e.name ?? 'unknown')),
        DataCell(Text(e.type ?? 'unknown')),
        DataCell(Text(e.host ?? 'unknown')),
        DataCell(Text(e.port != null ? '${e.port}' : 'unknown'))
      ],
    ))
        .toList();
  }
}

class RegistrationWidget extends ConsumerWidget {

  const RegistrationWidget({super.key, required this.registration});

  final Registration registration;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = registration.service;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.wifi_tethering),
            title: Text('Registration ${shorten(registration.id)}'),
            subtitle: Text(
              'Name: ${service.name} ▪️ '
                  'Type: ${service.type} ▪️ '
                  'Host: ${service.host} ▪️ '
                  'Port: ${service.port}',
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}

/// Shortens the id for display on-screen.
String shorten(String? id) {
  return id?.toString().substring(0, 4) ?? 'unknown';
}