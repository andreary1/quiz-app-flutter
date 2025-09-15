import 'package:flutter/material.dart';
import 'package:projeto_perguntas/answer.dart';
import 'package:projeto_perguntas/question.dart';

class Questionnaire extends StatelessWidget {
  final int selectedQuestion;
  final List<Map<String, Object>> questions;
  final void Function(int) answer;

  Questionnaire({
    required this.selectedQuestion,
    required this.questions,
    required this.answer,
  });

  bool get hasMoreQuestions {
    return selectedQuestion < questions.length;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, Object>>? answers =
        (hasMoreQuestions
                ? questions[selectedQuestion]['Answers']
                      as List<Map<String, Object>>
                : [])
            .cast<Map<String, Object>>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Question(questions[selectedQuestion]['Text'].toString()),
          ...answers
              .map(
                (answer) => Answer(
                  answer['Text'].toString(),
                  () => this.answer(answer['Score'] as int),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
