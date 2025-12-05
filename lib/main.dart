import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/theme.dart';
import 'ui/dashboard.dart';
import 'logic/automation_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AutomationController()),
      ],
      child: const PineValidatorApp(),
    ),
  );
}

class PineValidatorApp extends StatelessWidget {
  const PineValidatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pine Validator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const Dashboard(),
    );
  }
}
