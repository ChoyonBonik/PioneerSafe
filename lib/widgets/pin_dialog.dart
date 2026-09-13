import 'package:flutter/material.dart';

Future<String?> showPinSetupDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const PinSetupDialog(),
  );
}

class PinSetupDialog extends StatefulWidget {
  const PinSetupDialog({super.key});
  @override
  State<PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<PinSetupDialog> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;

  void _submit() {
    if (_pinController.text.isEmpty || _pinController.text.length < 4) {
      setState(() => _error = 'PIN must be at least 4 digits');
      return;
    }
    if (_pinController.text != _confirmController.text) {
      setState(() => _error = 'PINs do not match');
      return;
    }
    Navigator.pop(context, _pinController.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Custom PIN'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 8,
            decoration: const InputDecoration(labelText: 'New PIN'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 8,
            decoration: const InputDecoration(labelText: 'Confirm PIN'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ]
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _submit, 
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save')
        ),
      ],
    );
  }
}
