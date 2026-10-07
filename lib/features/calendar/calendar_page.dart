import 'package:flutter/material.dart';

import '../children/child.dart';
import '../children/children_repository.dart';
import '../competitions/competitions_page.dart';
import '../competitions/competitions_repository.dart';
import '../dances/dances_page.dart';
import '../dances/dances_repository.dart';
import 'section_page.dart';

class CalendarPage extends StatelessWidget {
  final Child child;
  final ChildrenRepository childrenRepository;
  final DancesRepository dancesRepository;
  final CompetitionsRepository competitionsRepository;

  const CalendarPage({
    super.key,
    required this.child,
    required this.childrenRepository,
    required this.dancesRepository,
    required this.competitionsRepository,
  });

  void _open(BuildContext context, String title) {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => switch (title) {
          'Dances' => DancesPage(
            child: child,
            childrenRepository: childrenRepository,
            dancesRepository: dancesRepository,
          ),
          'Competitions' => CompetitionsPage(
            child: child,
            childrenRepository: childrenRepository,
            repository: competitionsRepository,
          ),
          _ => SectionPage(title: title),
        },
      ),
    );
  }

  void _switchChild(BuildContext context) {
    Navigator.pop(context); // close drawer
    Navigator.pop(context); // back to the landing page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(child.name)),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Close menu',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              for (final title in const ['Competitions', 'Dances', 'Costumes'])
                ListTile(
                  title: Text(title),
                  onTap: () => _open(context, title),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text('Switch Child'),
                onTap: () => _switchChild(context),
              ),
            ],
          ),
        ),
      ),
      body: CalendarDatePicker(
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        onDateChanged: (_) {},
      ),
    );
  }
}
