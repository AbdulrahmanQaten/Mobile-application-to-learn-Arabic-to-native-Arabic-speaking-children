/// بيانات اختبار النطق - عرض صور حيوانات والطفل ينطق اسمها

class PronunciationQuizQuestion {
  final String animalName;
  final String imagePath;

  const PronunciationQuizQuestion({
    required this.animalName,
    required this.imagePath,
  });
}

class PronunciationQuizData {
  /// جميع أسئلة اختبار النطق (حيوانات)
  static const List<PronunciationQuizQuestion> allQuestions = [
    PronunciationQuizQuestion(
      animalName: 'أسد',
      imagePath: 'images/animals/أسد.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'أرنب',
      imagePath: 'images/animals/أرنب.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'فيل',
      imagePath: 'images/animals/فيل.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'قطة',
      imagePath: 'images/animals/قطة.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'كلب',
      imagePath: 'images/animals/كلب.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'جمل',
      imagePath: 'images/animals/جمل.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'نمر',
      imagePath: 'images/animals/نمر.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'بقرة',
      imagePath: 'images/animals/بقرة.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'زرافة',
      imagePath: 'images/animals/زرافة.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'خروف',
      imagePath: 'images/animals/خروف.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'حمار',
      imagePath: 'images/animals/حمار.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'ديك',
      imagePath: 'images/animals/ديك.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'دجاجة',
      imagePath: 'images/animals/دجاجة.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'قرد',
      imagePath: 'images/animals/قرد.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'ذئب',
      imagePath: 'images/animals/ذئب.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'فأر',
      imagePath: 'images/animals/فأر.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'ضفدع',
      imagePath: 'images/animals/ضفدع.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'صقر',
      imagePath: 'images/animals/صقر.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'فهد',
      imagePath: 'images/animals/فهد.jpg',
    ),
    PronunciationQuizQuestion(
      animalName: 'بطريق',
      imagePath: 'images/animals/بطريق.jpg',
    ),
  ];

  /// الحصول على أسئلة عشوائية للاختبار
  static List<PronunciationQuizQuestion> getRandomQuestions(int count) {
    final shuffled = List<PronunciationQuizQuestion>.from(allQuestions)
      ..shuffle();
    return shuffled.take(count).toList();
  }
}
