import 'package:dispute/dispute.dart';
import 'package:flutter/material.dart';
import 'package:nostr_wrapper/nostr.dart';
import 'package:plugin_interface/plugin_interface.dart';
const _includeDispute = bool.fromEnvironment(
  'INCLUDE_DISPUTE',
  defaultValue: true,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await NostrDatabase.open('tmp_hardcoded_key');

  final plugins = <AppPlugin>[
    if (_includeDispute) DisputePlugin(db: db),
  ];

  for (final plugin in plugins) {
    await plugin.initialize();
  }

  runApp(ShellApp(plugins: plugins));
}

class ShellApp extends StatelessWidget {
  const ShellApp({required this.plugins, super.key});

  final List<AppPlugin> plugins;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dispute',
      home: plugins.isEmpty
          ? const Scaffold(
              body: Center(child: Text('No plugins loaded')),
            )
          : _ShellHome(plugins: plugins),
    );
  }
}

class _ShellHome extends StatefulWidget {
  const _ShellHome({required this.plugins});

  final List<AppPlugin> plugins;

  @override
  State<_ShellHome> createState() => _ShellHomeState();
}

class _ShellHomeState extends State<_ShellHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.plugins[_currentIndex].buildHome(context),
      bottomNavigationBar: widget.plugins.length > 1
          ? NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              destinations: widget.plugins
                  .map(
                    (plugin) => NavigationDestination(
                      icon: Icon(plugin.icon),
                      label: plugin.name,
                    ),
                  )
                  .toList(),
            )
          : null,
    );
  }
}
