/// بيانات اختبار النطق - أسئلة صوتية مع صور

class PronunciationQuizQuestion {
  final String audioPath;
  final String correctAnswer; // اسم الصورة الصحيحة (بدون مسار)
  final String correctImagePath;
  final List<String> allOptions; // 4 صور للاختيار

  const PronunciationQuizQuestion({
    required this.audioPath,
    required this.correctAnswer,
    required this.correctImagePath,
    required this.allOptions,
  });
}

class PronunciationQuizData {
  /// جميع أسئلة اختبار النطق (فواكه وخضروات)
  static const List<PronunciationQuizQuestion> allQuestions = [
    // أسئلة الفواكه
    PronunciationQuizQuestion(
      audioPath: 'audio/questions/أين هو الإجاص.mp3',
      correctAnswer: 'إجاص',
      correctImagePath: 'images/food/إجاص.jpg',
      allOptions: [
        'images/food/إجاص.jpg',
        'images/food/تفاح.jpg',
        'images/food/برتقال.jpg',
        'images/food/موز.jpg',
      ],
    ),
    PronunciationQuizQuestion(
      audioPath: 'audio/questions/أين هو العنب.mp3',
      correctAnswer: 'عنب',
      correctImagePath: 'images/food/عنب.jpg',
      allOptions: [
        'images/food/عنب.jpg',
        'images/food/كرز.jpg',
        'images/food/فراولة.jpg',
        'images/food/رمان.jpg',
      ],
    ),
    PronunciationQuizQuestion(
      audioPath: 'audio/questions/أين هي الفراولة.mp3',
      correctAnswer: 'فراولة',
      correctImagePath: 'images/food/فراولة.jpg',
      allOptions: [
        'images/food/فراولة.jpg',
        'images/food/كرز.jpg',
        'images/food/عنب.jpg',
        'images/food/تفاح.jpg',
      ],
    ),
    PronunciationQuizQuestion(
      audioPath: 'audio/questions/أين هو البطيخ.mp3',
      correctAnswer: 'بطيخ',
      correctImagePath: 'images/food/بطيخ.jpg',
      allOptions: [
        'images/food/بطيخ.jpg',
        'images/food/أناناس.jpg',
        'images/food/مانجو.jpg',
        'images/food/برتقال.jpg',
      ],
    ),
    PronunciationQuizQuestion(
      audioPath: 'audio/questions/أين هو الرمان.mp3',
      correctAnswer: 'رمان',
      correctImagePath: 'images/food/رمان.jpg',
      allOptions: [
        'images/food/رمان.jpg',
        'images/food/تفاح.jpg',
        'images/food/خوخ.jpg',
        'images/food/عنب.jpg',
      ],
    ),

    // أسئلة الخضروات
    PronunciationQuizQuestion(
      audioPath: 'audio/questions/أين هو الباذنجان.mp3',
      correctAnswer: 'باذنجان',
      correctImagePath: 'images/food/باذنجان.jpg',
      allOptions: [
        'images/food/باذنجان.jpg',
        'images/food/خيار.jpg',
        'images/food/فلفل.jpg',
        'images/food/طماطم.jpg',
      ],
    ),
    PronunciationQuizQuestion(
      audioPath: 'audio/questions/أين هو البصل.mp3',
      correctAnswer: 'بصل',
      correctImagePath: 'images/food/بصل.jpg',
      allOptions: [
        'images/food/بصل.jpg',
        'images/food/بطاطا.jpg',
        'images/food/ذرة.jpg',
        'images/food/جزر.jpg',
      ],
    ),
    PronunciationQuizQuestion(
      audioPath: 'audio/questions/أين هو الجزر.mp3',
      correctAnswer: 'جزر',
      correctImagePath: 'images/food/جزر.jpg',
      allOptions: [
        'images/food/جزر.jpg',
        'images/food/بطاطا.jpg',
        'images/food/يقطين.jpg',
        'images/food/خس.jpg',
      ],
    ),
    PronunciationQuizQuestion(
      audioPath: 'audio/questions/أين هو الخيار.mp3',
      correctAnswer: 'خيار',
      correctImagePath: 'images/food/خيار.jpg',
      allOptions: [
        'images/food/خيار.jpg',
        'images/food/باذنجان.jpg',
        'images/food/فلفل.jpg',
        'images/food/خس.jpg',
      ],
    ),
    PronunciationQuizQuestion(
      audioPath: 'audio/questions/أين هي البازلاء.mp3',
      correctAnswer: 'بازلاء',
      correctImagePath: 'images/food/بازلاء.jpg',
      allOptions: [
        'images/food/بازلاء.jpg',
        'images/food/ذرة.jpg',
        'images/food/خس.jpg',
        'images/food/فلفل.jpg',
      ],
    ),
    PronunciationQuizQuestion(
      audioPath: 'audio/questions/أين هي البطاطا.mp3',
      correctAnswer: 'بطاطا',
      correctImagePath: 'images/food/بطاطا.jpg',
      allOptions: [
        'images/food/بطاطا.jpg',
        'images/food/بصل.jpg',
        'images/food/جزر.jpg',
        'images/food/يقطين.jpg',
      ],
    ),
  ];

  /// الحصول على أسئلة عشوائية للاختبار
  static List<PronunciationQuizQuestion> getRandomQuestions(int count) {
    final shuffled = List<PronunciationQuizQuestion>.from(allQuestions)..shuffle();
    return shuffled.take(count).toList();
  }

  /// الحصول على أسئلة الفواكه فقط
  static List<PronunciationQuizQuestion> getFruitQuestions() {
    return allQuestions.where((q) => 
      q.correctAnswer == 'إجاص' ||
      q.correctAnswer == 'عنب' ||
      q.correctAnswer == 'فراولة' ||
      q.correctAnswer == 'بطيخ' ||
      q.correctAnswer == 'رمان'
    ).toList();
  }

  /// الحصول على أسئلة الخضروات فقط
  static List<PronunciationQuizQuestion> getVegetableQuestions() {
    return allQuestions.where((q) => 
      q.correctAnswer == 'باذنجان' ||
      q.correctAnswer == 'بصل' ||
      q.correctAnswer == 'جزر' ||
      q.correctAnswer == 'خيار' ||
      q.correctAnswer == 'بازلاء' ||
      q.correctAnswer == 'بطاطا'
    ).toList();
  }
}
