

enum Month {
  enero(number: "01"),
  febrero(number: "02"),
  marzo(number: "03"),
  abril(number: "04"),
  mayo(number: "05"),
  junio(number: "06"),
  julio(number: "07"),
  agosto(number: "08"),
  septiembre(number: "09"),
  octubre(number: "10"),
  noviembre(number: "11"),
  diciembre(number: "12");

  const Month({required this.number});

  final String number;
}

const months = <Month>[
  Month.enero,
  Month.febrero,
  Month.marzo,
  Month.abril,
  Month.mayo,
  Month.junio,
  Month.julio,
  Month.agosto,
  Month.septiembre,
  Month.octubre,
  Month.noviembre,
  Month.diciembre
];

int days({required int month, required int year}) {
  switch (month) {
    case 1:
    case 3:
    case 5:
    case 7:
    case 8:
    case 10:
    case 12:
      return 31;
    case 4:
    case 6:
    case 11:
      return 30;
    default:
      bool isLeapYear = ((year % 4 == 0 && year % 100 == 0) || year % 400 == 0);
      return isLeapYear ? 29 : 28;
  }
}
