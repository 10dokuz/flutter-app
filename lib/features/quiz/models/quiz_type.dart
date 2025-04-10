import 'package:flutterquiz/utils/constants/string_labels.dart';

enum QuizTypes {
  dailyQuiz,
  contest,
  groupPlay,
  practiceSection,
  oneVsOneBattle,
  funAndLearn,
  trueAndFalse,
  SelfTest,
  guessTheWord,
  quizZone,
  bookmarkQuiz,
  mathZone,
  listenandAnswer,
  exam,
  randomBattle,
  multiMatch,
}

QuizTypes getQuizTypeEnumFromTitle(String? title) {
  if (title == 'contest') {
    return QuizTypes.contest;
  } else if (title == 'dailyQuiz') {
    return QuizTypes.dailyQuiz;
  } else if (title == 'groupPlay') {
    return QuizTypes.groupPlay;
  } else if (title == 'battleQuiz') {
    return QuizTypes.oneVsOneBattle;
  } else if (title == 'funAndLearn') {
    return QuizTypes.funAndLearn;
  } else if (title == 'guessTheWord') {
    return QuizTypes.guessTheWord;
  } else if (title == 'trueAndFalse') {
    return QuizTypes.trueAndFalse;
  } else if (title == 'SelfTest') {
    return QuizTypes.SelfTest;
  } else if (title == 'quizZone') {
    return QuizTypes.quizZone;
  } else if (title == mathZoneKey) {
    return QuizTypes.mathZone;
  } else if (title == listenandAnswerKey) {
    return QuizTypes.listenandAnswer;
  } else if (title == examKey) {
    return QuizTypes.exam;
  }

  return QuizTypes.practiceSection;
}
