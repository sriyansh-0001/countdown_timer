import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/timer_preset.dart';
import '../services/timer_service.dart';

/// Dialog allowing user to enter a custom countdown duration with input validation,
/// following Flutter Form & Validation principles (Lab Experiment 7).
class CustomTimerDialog extends StatefulWidget {
  final TimerService timerService;

  const CustomTimerDialog({super.key, required this.timerService});

  static Future<void> show(BuildContext context, TimerService timerService) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => CustomTimerDialog(timerService: timerService),
    );
  }

  @override
  State<CustomTimerDialog> createState() => _CustomTimerDialogState();
}

class _CustomTimerDialogState extends State<CustomTimerDialog> {
  final _formKey = GlobalKey<FormState>();

  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController(text: '25');
  final _secondsController = TextEditingController(text: '0');
  final _titleController = TextEditingController(text: 'Custom Focus');

  bool _saveAsPreset = false;

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
      final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
      final seconds = int.tryParse(_secondsController.text.trim()) ?? 0;

      final totalDuration = Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );

      if (totalDuration.inSeconds <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a duration greater than zero.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final title = _titleController.text.trim().isEmpty
          ? 'Custom Timer'
          : _titleController.text.trim();

      widget.timerService.setCustomDuration(totalDuration, title: title);

      if (_saveAsPreset) {
        final newPreset = TimerPreset(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          durationInSeconds: totalDuration.inSeconds,
          iconName: 'timer',
          isCustom: true,
        );
        widget.timerService.addCustomPreset(newPreset);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          const Text('Custom Duration'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set custom countdown hours, minutes, and seconds.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Session Name',
                  hintText: 'e.g. Study Sprint, Workout, Tea Timer',
                  prefixIcon: const Icon(Icons.label_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please provide a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Duration Inputs (Hours, Minutes, Seconds)
              Row(
                children: [
                  Expanded(
                    child: _buildDurationField(
                      controller: _hoursController,
                      label: 'Hours',
                      max: 23,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDurationField(
                      controller: _minutesController,
                      label: 'Minutes',
                      max: 59,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDurationField(
                      controller: _secondsController,
                      label: 'Seconds',
                      max: 59,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Save to presets checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _saveAsPreset,
                onChanged: (val) {
                  setState(() {
                    _saveAsPreset = val ?? false;
                  });
                },
                title: const Text('Save as reusable preset'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Set Timer'),
        ),
      ],
    );
  }

  Widget _buildDurationField({
    required TextEditingController controller,
    required String label,
    required int max,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Req';
        }
        final numVal = int.tryParse(val);
        if (numVal == null || numVal < 0 || numVal > max) {
          return '0-$max';
        }
        return null;
      },
    );
  }
}
