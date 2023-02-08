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
