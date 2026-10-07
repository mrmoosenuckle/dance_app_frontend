import 'package:flutter/material.dart';

import '../children/child.dart';
import '../children/children_repository.dart';
import 'dances_repository.dart';

class AddDancePage extends StatefulWidget {
  final Child child;
  final ChildrenRepository childrenRepository;
  final DancesRepository dancesRepository;

  const AddDancePage({
    super.key,
    required this.child,
    required this.childrenRepository,
    required this.dancesRepository,
  });

  @override
  State<AddDancePage> createState() => _AddDancePageState();
}

class _AddDancePageState extends State<AddDancePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _duration = TextEditingController();
  List<Child> _children = [];
  late final Set<String> _selectedIds = {widget.child.id};
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _loadChildren() async {
    try {
      final children = await widget.childrenRepository.fetchChildren();
      if (mounted) setState(() => _children = children);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    if (_selectedIds.isEmpty) {
      setState(() => _error = 'Select at least one child');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.dancesRepository.addDance(
        name: _name.text.trim(),
        category: _category.text.trim(),
        durationSeconds: int.parse(_duration.text.trim()),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add dance')),
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
                controller: _category,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _duration,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (seconds)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = int.tryParse(v?.trim() ?? '');
                  return n == null || n <= 0 ? 'Enter a whole number' : null;
                },
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
                const SizedBox(height: 8),
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
