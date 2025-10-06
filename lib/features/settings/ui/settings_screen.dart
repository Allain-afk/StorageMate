import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool suggestApks = true;
  int rareDays = 90;
  int minHashKb = 256;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Suggest deleting APKs'),
            value: suggestApks,
            onChanged: (v) => setState(() => suggestApks = v),
          ),
          ListTile(
            title: const Text('Rarely used threshold (days)'),
            subtitle: Text('$rareDays days'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final v = await showDialog<int>(
                context: context,
                builder: (ctx) => _NumberPickerDialog(initial: rareDays, title: 'Rare threshold (days)'),
              );
              if (v != null) setState(() => rareDays = v);
            },
          ),
          ListTile(
            title: const Text('Min file size to hash (KB)'),
            subtitle: Text('$minHashKb KB'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final v = await showDialog<int>(
                context: context,
                builder: (ctx) => _NumberPickerDialog(initial: minHashKb, title: 'Min hash size (KB)'),
              );
              if (v != null) setState(() => minHashKb = v);
            },
          ),
        ],
      ),
    );
  }
}

class _NumberPickerDialog extends StatefulWidget {
  const _NumberPickerDialog({required this.initial, required this.title});
  final int initial;
  final String title;
  @override
  State<_NumberPickerDialog> createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<_NumberPickerDialog> {
  late int value;
  @override
  void initState() { super.initState(); value = widget.initial; }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Row(children: [
        IconButton(onPressed: () => setState(() => value = value - 1), icon: const Icon(Icons.remove_circle_outline)),
        Expanded(child: Center(child: Text('$value'))),
        IconButton(onPressed: () => setState(() => value = value + 1), icon: const Icon(Icons.add_circle_outline)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, value), child: const Text('Save')),
      ],
    );
  }
}


