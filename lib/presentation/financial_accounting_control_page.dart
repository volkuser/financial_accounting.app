import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../model/finance_record.dart';
import '../screen_arguments.dart';
import '../shared_preferences_control.dart';

class FinancialAccountingControlPage extends StatefulWidget {
  const FinancialAccountingControlPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FinancialAccountingControlPageState();
}

class _FinancialAccountingControlPageState
    extends State<FinancialAccountingControlPage> {
  final _formKey = GlobalKey<FormState>();
  final _record = FinanceRecord();

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
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Transaction Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter transaction number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _record.transactionNumber = int.parse(value!);
                    },
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Transaction Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter transaction name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _record.transactionName = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) {
                      _record.description = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter category';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _record.category = value!;
                    },
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Transaction Date'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter transaction date';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _record.transactionDate = DateTime.parse(value!);
                    },
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Transaction Amount'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter transaction amount';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _record.transactionAmount = double.parse(value!);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Add'),
                      ),
                      ElevatedButton(
                        onPressed: _update,
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<FinanceRecord>>(
                future: _getRecords(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final records = snapshot.data!;
                    return ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return ListTile(
                          title: Text(record.transactionName ?? ''),
                          subtitle:
                              Text(record.transactionDate?.toString() ?? ''),
                          trailing:
                              Text(record.transactionAmount?.toString() ?? ''),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final context = _formKey.currentContext!;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adding record...')),
      );

      /* final query = Query<FinanceRecord>(context)..values = _record;

      await query.insert();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record added.')),
      ); */

      setState(() {
        _formKey.currentState!.reset();
      });
    }
  }

  void _update() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final context = _formKey.currentContext!;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updating record...')),
      );

      /* final query = Query<FinanceRecord>(context)
        ..values = _record
        ..where((r) => r.id).equalTo(_record.id);

      await query.updateOne();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record updated.')),
      ); */

      setState(() {
        _formKey.currentState!.reset();
      });
    }
  }

  Future<List<FinanceRecord>> _getRecords() async {
    final response = await http
        .get(Uri.parse('http://localhost:8888/finance-record'), headers: {
      'Content-Type': 'application/json',
    });
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    return parsed
        .map<FinanceRecord>((json) => FinanceRecord.fromJson(json))
        .toList();
  }
}
