import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'theme.dart';
import 'models/expense.dart';
import 'widgets/transaction_list.dart';
// import 'widgets/chart.dart';
import 'widgets/add_transaction.dart';
import 'widgets/no_transaction_image.dart';

void main() => runApp(PersonalExpenses());

class PersonalExpenses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: HomeScreen(title: 'Personal Expenses'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> txList = <Expense>[];
  bool showChart = false;

  Future<Database> _getDatabase() async {
    Database database = await openDatabase(
      join(await getDatabasesPath(), 'expenses.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'title TEXT, amount REAL, date TEXT)',
        );
      },
      version: 1,
    );

    return database;
  }

  Future<List<Expense>> _getTransactions() async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> transactions = await db.rawQuery(
      'SELECT * FROM expenses',
    );

    return List.generate(transactions.length, (index) {
      return Expense(
        id: transactions[index]['id'],
        title: transactions[index]['title'],
        amount: transactions[index]['amount'],
        date: DateTime.parse(transactions[index]['date']),
      );
    }).toList();
  }

  Future<void> _loadTransactions() async {
    List<Expense> getTxList = await _getTransactions();

    setState(() => txList = getTxList);
  }

  Future<void> _addNewTx(String title, double amount, DateTime date) async {
    Database db = await _getDatabase();

    await db.transaction((txn) async {
      await txn.rawInsert(
        'INSERT INTO expenses (title, amount, date) VALUES (?, ?, ?)',
        [title, amount, date.toString()],
      );
    });

    _loadTransactions();
  }

  void _startAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => AddTransaction(_addNewTx),
    );
  }

  Future<void> _deleteTransaction(int id) async {
    Database db = await _getDatabase();
    db.rawDelete('DELETE FROM expenses WHERE id = ?', [id]);

    _loadTransactions();
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool isLandscape = mediaQuery.orientation == Orientation.landscape;

    AppBar appBar = AppBar(
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _startAddTransaction(context),
        ),
      ],
    );

    double bodySize = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;

    List<Widget> _buildPortrait() {
      return <Widget>[
        // Container(
        //   height: bodySize * 0.3 - 20,
        //   child: Chart(txList),
        // ),
        Container(
          height: bodySize * 0.7 + 20,
          child: txList.isEmpty
              ? NoTransactionImage(isLandscape)
              : TransactionList(txList, _deleteTransaction),
        ),
      ];
    }

    List<Widget> _buildLandscape() {
      return <Widget>[
        Container(
          height: bodySize * 0.1 + 10,
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Show Chart',
                style: Theme.of(context).textTheme.headline5,
              ),
              Switch.adaptive(
                value: showChart,
                onChanged: (value) => setState(() => showChart = value),
              ),
            ],
          ),
        ),
        // showChart
        //     ? Container(
        //         height: bodySize * 0.8 - 10,
        //         child: Chart(txList),
        //       )
        //     : Container(
        //         height: bodySize * 0.9 - 10,
        //         child: txList.isEmpty
        //             ? NoTransactionImage(isLandscape)
        //             : TransactionList(txList, _deleteTransaction),
        //       ),
      ];
    }

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: <Widget>[
          if (!isLandscape) ..._buildPortrait(),
          if (isLandscape) ..._buildLandscape(),
        ],
      ),
    );
  }
}
