import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gastos/data/models/chart_models/date_expenses.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/sqlite_manager.dart';
import 'package:gastos/logic/sorter.dart';
import 'package:gastos/presentation/widgets/charts/my_bar_chart.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:gastos/utils/date_formatter.dart';
import 'package:gastos/utils/my_text_styles.dart';

import 'package:provider/provider.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final users = context.read<UserProvider>().users;
    print('users $users');
    return ListView(
      children: [
        Text('Usuarios de la aplicación',
            textAlign: TextAlign.center, style: titleStyle(28.2)),
        ...users
            .map((e) => _UserInfoContainer(
                userName: e.name,
                fecha: MyDateFormatter.toFormat('dd/MM/yyyy', DateTime.now())))
            .toList(),
        const SizedBox(height: 20),
        CurrentWeekInfo()
      ],
    );
  }
}

class CurrentWeekInfo extends StatefulWidget {
  const CurrentWeekInfo({super.key});

  @override
  State<CurrentWeekInfo> createState() => _CurrentWeekInfoState();
}

class _CurrentWeekInfoState extends State<CurrentWeekInfo> {
  @override
  void initState() {
    super.initState();
  }

  List<BarChartGroupData> myData = [];
  double maxY = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Column(
      children: [
        Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            width: width * 0.7,
            height: size.height * 0.3,
            child: MyBarChart(
              data: myData,
              maxY: maxY + 100,
            )),
            //TODO: REFACTORIZAR EL ON PRESSED!
        ElevatedButton(
            onPressed: () async {
              final now = DateTime.now();
              //i.e 4
              //left = 4 - 1 = 3
              //rigth 7 - 4 = 3
              final weekDay = now.weekday;
              int pastDays = weekDay - 1;
              int futureDays = 7 - weekDay;
              DateTime firstDate = now;
              DateTime lastDate = now;
              if (pastDays != 0) {
                firstDate = firstDate.subtract(Duration(days: pastDays));
              }
              if (futureDays != 0) {
                lastDate = lastDate.add(Duration(days: futureDays));
              }
              List<String> fullDates = [];
              for (int i = 0; i < 7; i++) {
                final date = MyDateFormatter.toYYYYMMdd(
                    firstDate.add(Duration(days: i)));
                fullDates.add(date);
              }
              final initialDate =
                  DateTime(firstDate.year, firstDate.month, firstDate.day);
              final endDate =
                  DateTime(lastDate.year, lastDate.month, lastDate.day);
              //gastos comunes
              String sql =
                  'SELECT date(e.createdDate / 1000 , "unixepoch", "localtime") as "date",  SUM(price) as "price" '
                  'from expenses e '
                  'where deleted = 0 '
                  'AND isCommonExpense = 1 '
                  'AND ( createdDate > ${initialDate.millisecondsSinceEpoch} '
                  'AND createdDate < ${endDate.millisecondsSinceEpoch} ) '
                  'GROUP BY date '
                  '';

              List<Map<String, dynamic>> result = [
                ...await SqliteManager.instance.database.rawQuery(sql)
              ];

              //rellenamos los que no están
              for (final date in fullDates) {
                if (!result.any((element) => element['date'] == date)) {
                  result.add({'date': date, 'price': 0.0});
                }
              }
              print(result);
              print(result.length);
              List<BarChartGroupData> barcharData = [];
              for (final res in result) {
                final dateExpense = DateExpenses.fromMap(res);
                if (dateExpense.price > maxY) {
                  maxY = dateExpense.price.toDouble();
                }
                barcharData.add(dateExpense.generateBarcharData(_barsGradient));
              }
              setState(() {
                myData = barcharData..sort((a, b) => a.x.compareTo(b.x));
              });
            },
            child: const Text('load ultima semana')),
      ],
    );
  }

  LinearGradient get _barsGradient => const LinearGradient(
        colors: [
          Color(0xFF2196F3),
          Color(0xFF50E4FF),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );
}

class _UserInfoContainer extends StatefulWidget {
  const _UserInfoContainer({required this.userName, required this.fecha});

  final String userName;
  final String fecha;

  @override
  State<_UserInfoContainer> createState() => _UserInfoContainerState();
}

class _UserInfoContainerState extends State<_UserInfoContainer> {
  late ExpenseProvider expenseProvider;
  num? total = 0.0;
  Future<void> getTotal(String name) async {
    num mytotal = await expenseProvider.repository.sumUserExpenses(name);
    setState(() {
      total = mytotal;
    });
    print(total);
  }

  @override
  void initState() {
    super.initState();
    expenseProvider = context.read<ExpenseProvider>();
    getTotal(widget.userName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 5.5),
        width: width * 0.95,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre',
                    style:
                        textStyle(14.2).copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 5,
                ),
                Text(widget.userName, style: textStyle(14.2))
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Gastado',
                    style:
                        textStyle(14.2).copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 5,
                ),
                loadingOrWidget(
                    expenseProvider.loading,
                    Text(
                        '${total == null ? "0.00" : total!.toStringAsFixed(2)} €',
                        style: textStyle(14.2)))
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha',
                    style:
                        textStyle(14.2).copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 5,
                ),
                Text(widget.fecha, style: textStyle(14.2))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget loadingOrWidget(bool loading, Widget child) {
    if (loading) {
      return const CircularProgressIndicator();
    }
    return child;
  }
}
