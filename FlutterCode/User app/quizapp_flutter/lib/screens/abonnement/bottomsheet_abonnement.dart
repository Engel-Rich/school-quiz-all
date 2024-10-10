import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class BottomsheetAbonnement extends StatefulWidget {
  const BottomsheetAbonnement({super.key});

  @override
  State<BottomsheetAbonnement> createState() => _BottomsheetAbonnementState();
}

class _BottomsheetAbonnementState extends State<BottomsheetAbonnement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          )),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              height: 5,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          15.width
        ],
      ),
    );
  }
}
