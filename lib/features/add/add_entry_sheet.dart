import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/jaap/jaap_providers.dart';
import '../../core/jaap/mantras.dart';
import '../../l10n/generated/app_localizations.dart';
import '../shared/mantra_label.dart';

Future<void> showAddEntrySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _AddEntrySheet(),
  );
}

class _AddEntrySheet extends ConsumerStatefulWidget {
  const _AddEntrySheet();
  @override
  ConsumerState<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends ConsumerState<_AddEntrySheet> {
  int _rounds = 1;
  Mantra _mantra = Mantra.navkar;
  DateTime _date = DateTime.now();
  final _obsCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      final svc = ref.read(jaapServiceProvider);
      await svc.addSession(
        count: _rounds * 108,
        mantra: _mantra,
        date: _date,
        observation: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).entryAdded)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final insets = MediaQuery.of(context).viewInsets;
    final dateLabel =
        '${_date.year.toString().padLeft(4, '0')}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + insets.bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.manualEntry,
                style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              l.manualEntrySubtitle,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Rounds stepper
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.rounds.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              letterSpacing: 1.2,
                            )),
                        const SizedBox(height: 4),
                        Text('$_rounds',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            )),
                        Text(l.roundsHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            )),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () =>
                            setState(() => _rounds = (_rounds + 1).clamp(1, 999)),
                        icon: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      IconButton.filledTonal(
                        onPressed: () =>
                            setState(() => _rounds = (_rounds - 1).clamp(1, 999)),
                        icon: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Date
            InputDecorator(
              decoration: InputDecoration(
                labelText: l.dateOfSadhana,
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit_calendar_outlined),
                  onPressed: _pickDate,
                ),
              ),
              child: Text(dateLabel),
            ),
            const SizedBox(height: 16),
            // Mantra chips
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(l.focus.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  )),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Mantra.values
                  .map((m) => ChoiceChip(
                        label: Text(mantraLabel(m, l)),
                        selected: _mantra == m,
                        onSelected: (_) => setState(() => _mantra = m),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _obsCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l.observationOptional,
                hintText: l.observationHint,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _busy ? null : _submit,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_circle_outline),
              label: Text(l.addToHistory),
            ),
          ],
        ),
      ),
    );
  }
}
