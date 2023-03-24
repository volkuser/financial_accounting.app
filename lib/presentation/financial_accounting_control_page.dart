import 'package:flutter/material.dart';

import '../screen_arguments.dart';
import '../shared_preferences_control.dart';

class FinancialAccountingControlPage extends StatefulWidget {
  const FinancialAccountingControlPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FinancialAccountingControlPage();
}

class _FinancialAccountingControlPage
    extends State<FinancialAccountingControlPage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Accounting Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is financial accounting'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String refreshToken = args.refreshToken;
                SharedPreferencesControl.saveData(refreshToken);
                SharedPreferencesControl.loadData().then((String value) {
                  setState(() {
                    refreshToken = value;
                  });
                });

                Navigator.pushNamed(context, '/profile',
                    arguments: ScreenArguments(refreshToken));
              },
              child: const Text('Go to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
