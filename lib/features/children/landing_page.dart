import 'package:flutter/material.dart';

import '../calendar/calendar_page.dart';
import 'child.dart';
import '../competitions/competitions_repository.dart';
import '../dances/dances_repository.dart';
import 'children_repository.dart';

class LandingPage extends StatefulWidget {
  final ChildrenRepository repository;
  final DancesRepository dancesRepository;
  final CompetitionsRepository competitionsRepository;
  const LandingPage({
    super.key,
    required this.repository,
    required this.dancesRepository,
    required this.competitionsRepository,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _controller = TextEditingController();
  List<Child> _children = [];
  bool _adding = false;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _children = await widget.repository.fetchChildren();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.repository.addChild(name);
      _children = await widget.repository.fetchChildren();
      _controller.clear();
      _adding = false;
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _submitting = false);
  }

  Future<bool> _confirmDelete(Child child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete child?'),
        content: Text('Are you sure you want to delete ${child.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _delete(Child child) async {
    if (!await _confirmDelete(child)) return;
    setState(() => _error = null);
    try {
      await widget.repository.deleteChild(child.id);
      _children = _children.where((c) => c.id != child.id).toList();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: _buildBody(context)),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return const CircularProgressIndicator();

    if (_children.isNotEmpty && !_adding) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final child in _children)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CalendarPage(
                          child: child,
                          childrenRepository: widget.repository,
                          dancesRepository: widget.dancesRepository,
                          competitionsRepository: widget.competitionsRepository,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        child.name,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Delete ${child.name}',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(child),
                ),
              ],
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => setState(() => _adding = true),
            child: const Text('Add another child'),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "What's your child's name?",
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _controller,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(_submitting ? 'Saving...' : 'Submit'),
        ),
        if (_children.isNotEmpty)
          TextButton(
            onPressed: () => setState(() {
              _adding = false;
              _error = null;
              _controller.clear();
            }),
            child: const Text('Cancel'),
          )
        else
          TextButton(onPressed: _load, child: const Text('Retry')),
      ],
    );
  }
}
