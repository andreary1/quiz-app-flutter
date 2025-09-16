import 'package:flutter/material.dart';

class Answer extends StatelessWidget {
  final String answerText;
  final void Function()? onSelect;

  const Answer(this.answerText, this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        onPressed: onSelect,
        child: Text(answerText),
      ),
    );
  }
}
