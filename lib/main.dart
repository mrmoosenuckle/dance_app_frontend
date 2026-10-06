import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/phone_frame.dart';
import 'features/children/children_repository.dart';
import 'features/children/landing_page.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient();
    return MaterialApp(
      title: 'Dance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      builder: (context, child) => PhoneFrame(child: child!),
      home: LandingPage(repository: ChildrenRepository(api)),
    );
  }
}
