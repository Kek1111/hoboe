import 'package:flutter/material.dart';

BoxDecoration ayBoxDecoration(BuildContext context) {
  return BoxDecoration(
    border: Border.all(
      color: const Color.fromARGB(255, 43, 5, 34),
      width: 3,
    ), //Border.all
    borderRadius: BorderRadius.zero,
    boxShadow: const [
      BoxShadow(
        color: Colors.black,
        offset: Offset(
          3.0,
          3.0,
        ), //Offset
        blurRadius: 5.0,
        spreadRadius: 2.0,
      ), //BoxShadow
      BoxShadow(
        color: Color.fromARGB(255, 22, 3, 3),
        offset: Offset(0.0, 0.0),
        blurRadius: 0.0,
        spreadRadius: 0.0,
      ), //BoxShadow
    ],
  );
}
// class AyBoxDecoration extends BoxDecoration {

//   final Border _border = () {return Border.all(
//                   color:  const Color.fromARGB(255, 43, 5, 34),
//                   width: 3,
//                 );}();

//   AyBoxDecoration(
//   {
//     super.border = const _border()}
// )
// }

 