import 'package:flutter/material.dart';

class DoubleMaterialButton extends StatelessWidget {
  const DoubleMaterialButton(
      {super.key,
      required this.leftSelected,
      required this.onPressedLeft,
      required this.onPressedRight,
      required this.leftText,
      required this.rightText});
  final bool leftSelected;
  final VoidCallback onPressedLeft, onPressedRight;
  final String leftText, rightText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 5.0),
          width: 140,
          height: 40,
          child: MaterialButton(
            padding: const EdgeInsets.all(5),
            color: leftSelected
                ? Color.fromARGB(235, 35, 39, 61)
                : Color.fromARGB(255, 182, 194, 252),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20))),
            onPressed: () {
              if (leftSelected) {
                return;
              }
              onPressedLeft();
            },
            child: Text(
              leftText,
              style: TextStyle(
                  color: leftSelected ? Colors.white : Colors.black,
                  fontSize: 16),
            ),
          ),
        ),
        SizedBox(
          width: 140,
          height: 40,
          child: MaterialButton(
            color: !leftSelected
                ? Color.fromARGB(235, 35, 39, 61)
                : Color.fromARGB(255, 182, 194, 252),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            onPressed: () async {
              if (!leftSelected) {
                return;
              }
              onPressedRight();
            },
            child: Text(
              rightText,
              style: TextStyle(
                  color: !leftSelected ? Colors.white : Colors.black,
                  fontSize: 16),
            ),
          ),
        )
      ],
    );
  }
}
