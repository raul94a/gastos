import 'package:gastos/utils/date_formatter.dart';

class MySortter {
  int sortByWeek(String a, String b) {
    final splitBySpaceA = a.split(' ');
    final splitBySpaceB = b.split(' ');
    final int numA = int.parse(splitBySpaceA[1]);
    final int numB = int.parse(splitBySpaceB[1]);
    return numB.compareTo(numA);
  }

  int sortByMonth(String a, String b) {
    //Multiplication of the year by 12 is necessary for the correct sorting, as
    //a number should be generated with the year + month number, we must ensure that any
    //month of the highest year is on the top of the list
    // let's say: Enero 2022 (1 + 2022 = 2023) and Diciembre 2021 (12 + 2021 = 2032)
    // if we don't multiply the year by 12, the last one would be previous to the first one (2032 > 2022)
    // However after the multiplication...
    // 2022 * 12 + 1 = 24265
    // 2021 * 12 + 12 = 24264
    //Ej.
    // a => Septiembre de 2023
    // b => Diciembre de 2023
    // splitBySpaceA = ['Septiembre','de','2023']
    // splitBySpaceB = ['Diciembre, 'de', '2022']
    // numA = 9 + 2023 * 12
    // numB = 12 + 2022 * 12
    // numA > numB

    final splitBySpaceA = a.split(' ');
    final splitBySpaceB = b.split(' ');
    final int numA = MyDateFormatter.monthNumber(splitBySpaceA[0]) +
        int.parse(splitBySpaceA.last) * 12;
    final int numB = MyDateFormatter.monthNumber(splitBySpaceB[0]) +
        int.parse(splitBySpaceB.last) * 12;
    return numB.compareTo(numA);
  }
}
