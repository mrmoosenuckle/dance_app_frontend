import 'package:flutter/material.dart';

import '../children/child.dart';
import '../children/children_repository.dart';
import 'competitions_repository.dart';

class AddCompetitionPage extends StatefulWidget {
  final Child child;
  final ChildrenRepository childrenRepository;
  final CompetitionsRepository repository;

  const AddCompetitionPage({
    super.key,
    required this.child,
    required this.childrenRepository,
    required this.repository,
  });

  @override
  State<AddCompetitionPage> createState() => _AddCompetitionPageState();
}

class _AddCompetitionPageState extends State<AddCompetitionPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _venue = TextEditingController();
  List<Child> _children = [];
  late final Set<String> _selectedIds = {widget.child.id};
  DateTime? _date;
  TimeOfDay? _time;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final children = await widget.childrenRepository.fetchChildren();
      if (mounted) setState(() => _children = children);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _venue.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    if (_date == null || _time == null) {
      setState(() => _error = 'Choose a date and time');
      return;
    }
    if (_selectedIds.isEmpty) {
      setState(() => _error = 'Select at least one child');
      return;
    }
    if (!valid || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.repository.addCompetition(
        name: _name.text.trim(),
        date: DateTime(
          _date!.year,
          _date!.month,
          _date!.day,
          _time!.hour,
          _time!.minute,
        ),
        venue: _venue.text.trim(),
        childIds: _selectedIds.toList(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _submitting = false;
        });
      }
    }
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add competition')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _venue,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Venue Address',
                  border: OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _date == null ? 'Choose date' : loc.formatFullDate(_date!),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.access_time),
                label: Text(
                  _time == null ? 'Choose time' : loc.formatTimeOfDay(_time!),
                ),
              ),
              const SizedBox(height: 16),
              Text('Children', style: theme.textTheme.titleMedium),
              for (final c in _children)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(c.name),
                  value: _selectedIds.contains(c.id),
                  onChanged: (checked) => setState(
                    () => checked == true
                        ? _selectedIds.add(c.id)
                        : _selectedIds.remove(c.id),
                  ),
                ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: Text(_submitting ? 'Saving...' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
