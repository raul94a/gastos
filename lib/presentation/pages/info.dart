import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:gastos/data/repository/chart_info_repository.dart';
import 'package:gastos/presentation/widgets/charts/chart_card_wrapper.dart';

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
        const CurrentWeekInfo(),
        const CurrentMonthInfo(),
        const CurrentYearInfo()
      ],
    );
  }
}

class CurrentYearInfo extends StatefulWidget {
  const CurrentYearInfo({super.key});

  @override
  State<CurrentYearInfo> createState() => _CurrentYearInfoState();
}

class _CurrentYearInfoState extends State<CurrentYearInfo> {
  @override
  void initState() {
    currentMonthDataByDate();
    super.initState();
  }

  void currentMonthDataByDate() async {
    final data =
        await ChartInfoRepository().currentYearExpensesGroupedByMonth();
    double mY = 0.0;
    List<BarChartGroupData> chartData = [];
    //first it needed to know the yMax for drawing the background of the chart bars
    for (int i = 0; i < data.length; ++i) {
      if (data[i].price > mY) {
        mY = data[i].price.toDouble();
      }
    }

    for (int i = 0; i < data.length; ++i) {
      chartData.add(data[i]
          .generateBarcharDataWeekDay(gradient: _barsGradient, maxY: mY));
    }
    setState(() {
      myData = chartData..sort((a, b) => a.x.compareTo(b.x));
      maxY = mY;
    });
  }

  List<BarChartGroupData> myData = [];
  double maxY = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return ChartCard(
      child: Container(
        padding: const EdgeInsets.all(15),
        //decoration: BoxDecoration( borderRadius: BorderRadius.circular(10), color: Colors.indigo),
        height: size.height * 0.3,
        margin: const EdgeInsets.all(4),
        child: MyBarChart(
          barChartType: BarChartType.yearMonth,
          data: myData,
          maxY: maxY + 100,
          xAxisTextStyle: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          yAxisTextStyle: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class CurrentMonthInfo extends StatefulWidget {
  const CurrentMonthInfo({super.key});

  @override
  State<CurrentMonthInfo> createState() => _CurrentMonthInfoState();
}

class _CurrentMonthInfoState extends State<CurrentMonthInfo> {
  @override
  void initState() {
    currentMonthDataByDate();
    super.initState();
  }

  void currentMonthDataByDate() async {
    final data =
        await ChartInfoRepository().currentMonthExpensesGroupedByDate();
    double mY = 0.0;
    List<BarChartGroupData> chartData = [];

    //first it needed to know the yMax for drawing the background of the chart bars
    for (int i = 0; i < data.length; ++i) {
      if (data[i].price > mY) {
        mY = data[i].price.toDouble();
      }
    }
    //then, we can create the list of bars
    for (int i = 0; i < data.length; ++i) {
      chartData.add(data[i]
          .generateBarcharDataMonthDay(gradient: _barsGradient, maxY: mY));
    }

    setState(() {
      myData = chartData..sort((a, b) => a.x.compareTo(b.x));
      maxY = mY;
    });
  }

  List<BarChartGroupData> myData = [];
  double maxY = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return ChartCard(
      child: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(4),
          height: size.height * 0.3,
          child: MyBarChart(
            barChartType: BarChartType.monthDay,
            data: myData,
            maxY: maxY + 50,
            xAxisTextStyle: TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            yAxisTextStyle: TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          )),
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
    //first it needed to know the yMax for drawing the background of the chart bars
    for (int i = 0; i < data.length; ++i) {
      if (data[i].price > mY) {
        mY = data[i].price.toDouble();
      }
    }
    for (int i = 0; i < data.length; ++i) {
      chartData.add(data[i]
          .generateBarcharDataWeekDay(gradient: _barsGradient, maxY: mY ));
    }
    setState(() {
      myData = chartData..sort((a, b) => a.x.compareTo(b.x));
      maxY = mY;
    });
  }

  List<BarChartGroupData> myData = [];
  double maxY = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Row(
      children: [
        ChartCard(
          child: Container(
              padding: const EdgeInsets.all(5),
              width: width * 0.7,
              height: size.height * 0.3,
              child: MyBarChart(
                barChartType: BarChartType.weekDay,
                data: myData,
                maxY: maxY + 100,
                xAxisTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                yAxisTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              )),
        ),
      ],
    );
  }
}

LinearGradient get _barsGradient => const LinearGradient(
      colors: [
        Color(0xFF2196F3),
        Color(0xFF50E4FF),
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

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
