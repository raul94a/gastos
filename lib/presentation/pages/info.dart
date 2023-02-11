import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gastos/data/models/chart_models/date_expenses.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/repository/chart_info_repository.dart';
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
    currentWeekDataByDate();
    super.initState();
  }

  void currentWeekDataByDate() async {
    final data = await ChartInfoRepository().currentWeekExpensesGroupedByDate();
    double mY = 0.0;
    List<BarChartGroupData> chartData = [];

    for (int i = 0; i < data.length; ++i) {
      chartData.add(data[i].generateBarcharData(_barsGradient));
      if (data[i].price > mY) {
        mY = data[i].price.toDouble();
      }
    }
    setState(() {
      myData = chartData;
      maxY = mY;
    });
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
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            width: width * 0.7,
            height: size.height * 0.3,
            child: MyBarChart(
              data: myData,
              maxY: maxY + 100,
            )),
      
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
