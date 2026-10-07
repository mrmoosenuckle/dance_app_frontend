import 'package:flutter/material.dart';

import '../children/child.dart';
import '../children/children_repository.dart';
import 'add_dance_page.dart';
import 'dance.dart';
import 'dances_repository.dart';

class DancesPage extends StatefulWidget {
  final Child child;
  final ChildrenRepository childrenRepository;
  final DancesRepository dancesRepository;

  const DancesPage({
    super.key,
    required this.child,
    required this.childrenRepository,
    required this.dancesRepository,
  });

  @override
  State<DancesPage> createState() => _DancesPageState();
}

class _DancesPageState extends State<DancesPage> {
  List<Dance> _dances = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _dances = await widget.dancesRepository.fetchDancesForChild(
        widget.child.id,
      );
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _add() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddDancePage(
          child: widget.child,
          childrenRepository: widget.childrenRepository,
          dancesRepository: widget.dancesRepository,
        ),
      ),
    );
    if (added == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dance added')));
      _load();
    }
  }

  Widget _buildList() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Column(
        children: [
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      );
    }
    if (_dances.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No current dances')),
      );
    }
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FixedColumnWidth(64),
      },
      border: TableBorder(
        horizontalInside: BorderSide(color: Theme.of(context).dividerColor),
      ),
      children: [
        _row(const ['Name', 'Category', 'Time'], header: true),
        for (final d in _dances)
          _row([d.name, d.category, d.formattedDuration]),
      ],
    );
  }

  TableRow _row(List<String> cells, {bool header = false}) {
    return TableRow(
      children: [
        for (final c in cells)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Text(
              c,
              style: header
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : null,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dances')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildList(),
            const SizedBox(height: 24),
            Center(
              child: FilledButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add),
                label: const Text('Add dance'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
