import 'package:flutter/material.dart';
import 'package:gastos/data/models/user.dart';
import 'package:gastos/presentation/widgets/info/charts/month_expenses_chart_by_day.dart';
import 'package:gastos/presentation/widgets/info/charts/week_expenses_chart_by_day.dart';
import 'package:gastos/presentation/widgets/info/charts/year_expenses_chart_by_month.dart';
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.5 + 180,
              child: Stack(
                //  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///start usuarios de la app card
                  _AppUsersInfo(users: users),
                  //fin usuarios de la app card
                  // const SizedBox(height: 20),
                  Positioned(
                    top: 170,
                    child: Container(
                      height: size.height * 0.5,
                      width: width,
                      decoration: BoxDecoration(
                          
                          color: Colors.indigo.shade100,
                          borderRadius: const BorderRadius.only(
                             
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      padding: const EdgeInsets.all(10),
                      child: Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Title(
                                color: Colors.white,
                                child: Text(
                                  'Gastos comunes ${DateTime.now().year}',
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                          const _ExpensesChartsRow(),
                        ],
                      ),
                    ),
                  ),
                  // const SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Title(
                        color: Colors.white,
                        child: Text(
                          'Gastos personales ${DateTime.now().year}',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        )),
                  ),
                  const _ExpensesChartsRow(
                    individual: true,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}

class _AppUsersInfo extends StatelessWidget {
  const _AppUsersInfo({
    super.key,
    required this.users,
  });

  final List<AppUser> users;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Container(
        width: width,
        height: 200,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.indigo,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15))),
        child: test());
  }

  Widget test() {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('Nombre',
            style: textStyle(14.2).copyWith(fontWeight: FontWeight.bold)),
        Text('Total Gastado',
            style: textStyle(14.2).copyWith(fontWeight: FontWeight.bold)),
        Text('Fecha',
            style: textStyle(14.2).copyWith(fontWeight: FontWeight.bold)),
      ],
    );
    ;
    return Wrap(
      children: [
        Text('Usuarios de la aplicación',
            style: titleStyle(25.2).copyWith(color: Colors.white)),
        Container(
          margin: EdgeInsets.only(top: 5),
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.lightBlue.shade200,
          ),
          child: Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.spaceAround,
            children: [
              row,
              ...users
                  .map((e) => _UserInfoContainer(
                      userName: e.name,
                      fecha: MyDateFormatter.toFormat(
                          'dd/MM/yyyy', DateTime.now())))
                  .toList(),
            ],
          ),
        )
      ],
    );
  }
}

class _ExpensesChartsRow extends StatelessWidget {
  const _ExpensesChartsRow({super.key, this.individual = false});
  final bool individual;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // const SizedBox(
          //   height: 5,
          // ),
          //card gastos semana actual
          SizedBox(
              width: width,
              child: CurrentWeekInfo(
                individual: individual,
              )),
          //fin card gasto semana actual
          // const SizedBox(
          //   height: 7,
          // ),
          SizedBox(
              width: width,
              child: CurrentMonthInfo(
                individual: individual,
              )),

          SizedBox(
              width: width,
              child: CurrentYearInfo(
                individual: individual,
              )),
          //fin card year
        ],
      ),
    );
  }
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

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.userName, style: textStyle(14.2)),
        loadingOrWidget(
            expenseProvider.loading,
            Text('${total == null ? "0.00" : total!.toStringAsFixed(2)} €',
                style: textStyle(14.2))),
        Text(widget.fecha, style: textStyle(14.2))
      ],
    );
    final data = DataRow(cells: [
      DataCell(
        Text(widget.userName, style: textStyle(14.2)),
      ),
      DataCell(
        loadingOrWidget(
            expenseProvider.loading,
            Text('${total == null ? "0.00" : total!.toStringAsFixed(2)} €',
                style: textStyle(14.2))),
      ),
      DataCell(Text(widget.fecha, style: textStyle(14.2)))
    ]);

    final table  = TableRow(children: [
      Text(widget.userName, style: textStyle(14.2)),
      loadingOrWidget(
          expenseProvider.loading,
          Text('${total == null ? "0.00" : total!.toStringAsFixed(2)} €',
              style: textStyle(14.2))),
      Text(widget.fecha, style: textStyle(14.2))
    ]);
    final t = Table(children: [table], defaultColumnWidth: FixedColumnWidth(120),);
    return true
        ? t
        : Center(
            child: Container(
              margin: const EdgeInsets.only(top: 5.5),
              width: width * 0.95,
              child: true
                  ? row
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nombre',
                                style: textStyle(14.2)
                                    .copyWith(fontWeight: FontWeight.bold)),
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
                                style: textStyle(14.2)
                                    .copyWith(fontWeight: FontWeight.bold)),
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
                                style: textStyle(14.2)
                                    .copyWith(fontWeight: FontWeight.bold)),
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
