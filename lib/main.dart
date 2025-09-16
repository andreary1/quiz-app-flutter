import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter/material.dart';
import 'package:projeto_perguntas/questionnaire.dart';
import 'result.dart';
import 'package:http/http.dart' as http;

main() => runApp(QuestionApp());

class _QuestionAppState extends State<QuestionApp> {
  var totalScore = 0;
  var selectedQuestion = 0;

  late Future<List<Map<String, Object>>> _futureQuestions;
  String? _selectedDifficulty;

  Future<List<Map<String, Object>>> getQuestions(String difficulty) async {
    final url = Uri.parse(
      'https://opentdb.com/api.php?amount=10&difficulty=$difficulty',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final questions = data['results'] as List;

      final unescape = HtmlUnescape();

      return questions.map<Map<String, Object>>((question) {
        final incorrectAnswers = (question['incorrect_answers'] as List)
            .cast<String>();
        final correctAnswer = question['correct_answer'] as String;

        final allAnswers = [...incorrectAnswers, correctAnswer]..shuffle();

        return {
          'Text': unescape.convert(question['question']),
          'Answers': allAnswers
              .map(
                (a) => {
                  'Text': unescape.convert(a),
                  'Score': a == correctAnswer ? 1 : 0,
                },
              )
              .toList(),
        };
      }).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }

  void _answer(int score) {
    if (hasMoreQuestions) {
      setState(() {
        selectedQuestion++;
        totalScore += score;
      });
    }

    print("Total Score: $totalScore");
  }

  void _selectDifficulty(String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
      _futureQuestions = getQuestions(difficulty);
      totalScore = 0;
      selectedQuestion = 0;
    });
  }

  void _reset() {
    setState(() {
      totalScore = 0;
      selectedQuestion = 0;
      _selectedDifficulty = null;
      _questions = [];
    });
  }

  List<Map<String, Object>> _questions = [];

  bool get hasMoreQuestions {
    return selectedQuestion < _questions.length;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Question App', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
        ),
        backgroundColor: const Color.fromARGB(255, 178, 212, 254),
        body: _selectedDifficulty == null
            ? _buildDifficultyMenu()
            : FutureBuilder<List<Map<String, Object>>>(
                future: _futureQuestions,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    _questions = snapshot.data!;
                    return hasMoreQuestions
                        ? Stack(
                            children: [
                              Questionnaire(
                                selectedQuestion: selectedQuestion,
                                questions: _questions,
                                answer: _answer,
                              ),
                              Positioned(
                                right: 16,
                                top: 16,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Score: $totalScore/10",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Result(totalScore, _reset);
                  } else {
                    return Center(child: Text('No questions found.'));
                  }
                },
              ),
      ),
    );
  }

  Widget _buildDifficultyMenu() {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 4,
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Choose your difficulty:', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _selectDifficulty('easy'),
            child: Text('Easy', textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _selectDifficulty('medium'),
            child: Text('Medium', textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _selectDifficulty('hard'),
            child: Text('Hard', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class QuestionApp extends StatefulWidget {
  const QuestionApp({super.key});

  @override
  _QuestionAppState createState() => _QuestionAppState();
}
