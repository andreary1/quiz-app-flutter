import 'package:flutter/material.dart';

class Result extends StatelessWidget {
  final int score;
  final void Function()? reset;

  Result(this.score, this.reset);

  String get phrase {
    if (score <= 3) {
      return "Total Score: ${score}/10. You can do better!";
    } else if (score <= 6) {
      return "Total Score: ${score}/10. You are getting better!";
    } else if (score <= 9) {
      return "Total Score: ${score}/10. You are an expert!";
    } else {
      return "Total Score: ${score}/10. You are a master!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: Text(phrase, style: TextStyle(fontSize: 24))),
        ElevatedButton(
          onPressed: reset,
          child: Text('Restart Quiz'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
