import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket/web_socket.dart';

import '../../presentation/relay_view.dart';
import '../../presentation/wizard_bloc.dart';
import '../../presentation/wizard_event.dart';
import '../validators.dart';

class RelaysStep extends StatefulWidget {
  const RelaysStep({super.key});

  @override
  State<RelaysStep> createState() => _RelaysStepState();
}

class _RelaysStepState extends State<RelaysStep> {
  final _formKey = GlobalKey<FormState>();
  final _relayController = TextEditingController();
  final _relays = <RelayView>[];
  bool _isValidating = false;
  String? _connectionError;

  static final _defaults = [Uri.parse('wss://nos.lol')];

  @override
  void dispose() {
    _relayController.dispose();
    super.dispose();
  }

  Future<bool> _connect(Uri uri) async {
    try {
      final ws = await WebSocket.connect(
        uri,
      ).timeout(const Duration(seconds: 5));
      await ws.close();
      return true;
    } on Exception {
      return false;
    }
  }

  Future<void> _addRelay() async {
    setState(() => _connectionError = null);
    if (!_formKey.currentState!.validate()) return;

    final uri = Uri.parse(_relayController.text.trim());
    setState(() => _isValidating = true);

    final ok = await _connect(uri);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _relays.add(RelayView(url: uri, read: true, write: true));
        _relayController.clear();
        _formKey.currentState!.reset();
        _isValidating = false;
      });
    } else {
      setState(() {
        _connectionError = 'Could not connect to relay';
        _isValidating = false;
      });
    }
  }

  Future<void> _addDefaultRelays() async {
    setState(() => _isValidating = true);

    final results = await Future.wait(
      _defaults.map((uri) async => (uri: uri, ok: await _connect(uri))),
    );
    if (!mounted) return;

    final reachable = results.where((r) => r.ok).map((r) => r.uri).toList();
    final failed = results.where((r) => !r.ok).length;

    setState(() {
      _relays.addAll(
        reachable.map((uri) => RelayView(url: uri, read: true, write: true)),
      );
      _connectionError = failed > 0
          ? '$failed default relay(s) unreachable and skipped'
          : null;
      _isValidating = false;
    });
  }

  void _removeRelay(int index) {
    setState(() => _relays.removeAt(index));
  }

  void _toggleRead(int index) {
    setState(() {
      final r = _relays[index];
      _relays[index] = RelayView(url: r.url, read: !r.read, write: r.write);
    });
  }

  void _toggleWrite(int index) {
    setState(() {
      final r = _relays[index];
      _relays[index] = RelayView(url: r.url, read: r.read, write: !r.write);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_relays.isEmpty) ...[
            const Text('Add relays or use defaults:'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _isValidating ? null : _addDefaultRelays,
              child: const Text('Use default relays'),
            ),
            const SizedBox(height: 16),
          ],
          for (var i = 0; i < _relays.length; i++)
            ListTile(
              dense: true,
              title: Text(_relays[i].url.toString()),
              subtitle: Row(
                children: [
                  FilterChip(
                    label: const Text('Read'),
                    selected: _relays[i].read,
                    onSelected: (_) => _toggleRead(i),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Write'),
                    selected: _relays[i].write,
                    onSelected: (_) => _toggleWrite(i),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _removeRelay(i),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _relayController,
                  decoration: InputDecoration(
                    labelText: 'wss://...',
                    border: const OutlineInputBorder(),
                    errorText: _connectionError,
                  ),
                  validator: Validators.relayUrl,
                  onChanged: (_) => setState(() => _connectionError = null),
                  onFieldSubmitted: (_) => _addRelay(),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _isValidating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        onPressed: _addRelay,
                        icon: const Icon(Icons.add),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _relays.isEmpty || _isValidating
                ? null
                : () {
                    context.read<WizardBloc>().add(
                      RelaysSelected(relays: List.unmodifiable(_relays)),
                    );
                  },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
