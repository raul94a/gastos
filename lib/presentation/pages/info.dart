import 'package:flutter/material.dart';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///start usuarios de la app card
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    children: [
                      Text('Usuarios de la aplicación',
                          style: titleStyle(25.2)),
                      ...users
                          .map((e) => _UserInfoContainer(
                              userName: e.name,
                              fecha: MyDateFormatter.toFormat(
                                  'dd/MM/yyyy', DateTime.now())))
                          .toList(),
                    ],
                  ),
                ),
              ),
            ),
            //fin usuarios de la app card
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Title(
                  color: Colors.white,
                  child: Text(
                    'Gastos comunes ${DateTime.now().year}',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  )),
            ),
            const SizedBox(
              height: 5,
            ),
            //card gastos semana actual
            Card(
              elevation: 6,
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Gastos de la semana actual',
                        style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: const CurrentWeekInfo(),
                  ),
                ],
              ),
            ),
            //fin card gasto semana actual
            const SizedBox(
              height: 7,
            ),
            Card(
              elevation: 6,
              child: Wrap(
                children: const [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Gastos del mes actual',
                        style: TextStyle(fontSize: 24)),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  CurrentMonthInfo(),
                ],
              ),
            ),
            const SizedBox(
              height: 7,
            ),
            Card(
              child: Wrap(
                children: const [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Gastos del año actual',
                        style: TextStyle(fontSize: 24)),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  CurrentYearInfo()
                ],
              ),
            ),
            //fin card year
            const SizedBox(height: 50,)
          ],
        ),
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
