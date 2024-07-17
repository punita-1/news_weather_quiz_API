import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

Opentdb welcomeFromJson(String str) => Opentdb.fromJson(json.decode(str));

String welcomeToJson(Opentdb data) => json.encode(data.toJson());

class Opentdb {
  int responseCode;
  List<Result> results;

  Opentdb({
    required this.responseCode,
    required this.results,
  });

  factory Opentdb.fromJson(Map<String, dynamic> json) => Opentdb(
    responseCode: json["response_code"],
    results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "response_code": responseCode,
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
  };
}

class Result {
  Type type;
  Difficulty difficulty;
  String category;
  String question;
  String correctAnswer;
  List<String> incorrectAnswers;

  Result({
    required this.type,
    required this.difficulty,
    required this.category,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    type: typeValues.map[json["type"]]!,
    difficulty: difficultyValues.map[json["difficulty"]]!,
    category: json["category"],
    question: json["question"],
    correctAnswer: json["correct_answer"],
    incorrectAnswers: List<String>.from(json["incorrect_answers"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "type": typeValues.reverse[type],
    "difficulty": difficultyValues.reverse[difficulty],
    "category": category,
    "question": question,
    "correct_answer": correctAnswer,
    "incorrect_answers": List<dynamic>.from(incorrectAnswers.map((x) => x)),
  };
}

enum Difficulty {
  MEDIUM
}

final difficultyValues = EnumValues({
  "medium": Difficulty.MEDIUM
});

enum Type {
  MULTIPLE
}

final typeValues = EnumValues({
  "multiple": Type.MULTIPLE
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

Future<Opentdb> fetchQuiz() async {
  final response = await http.get(Uri.parse('https://opentdb.com/api.php?amount=10&difficulty=medium&type=multiple'));

  if (response.statusCode == 200) {
    return Opentdb.fromJson(jsonDecode(response.body)as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load Quiz');
  }
}

class Quiz extends StatefulWidget {
  @override
  _QuizState createState() => _QuizState();
}
class _QuizState extends State<Quiz> {
late Future<Opentdb> futureQuiz;

@override
void initState() {
  super.initState();
  futureQuiz = fetchQuiz();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Quiz'),
    ),
    body: FutureBuilder<Opentdb>(
      future: futureQuiz,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
          return Center(child: Text('No questions found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.results.length,
            itemBuilder: (context, index) {
              var question = snapshot.data!.results[index];
              return Card(
                margin: EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(question.question),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: ${question.category}'),
                      Text('Difficulty: ${question.difficulty.toString().split('.').last}'),
                      SizedBox(height: 10),
                      Text('Correct Answer: ${question.correctAnswer}'),
                      Text('Incorrect Answers: ${question.incorrectAnswers.join(', ')}'),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    ),
  );
}
}