import 'package:flutter/material.dart';

// نموذج سؤال الاختبار
class TestQuestion {
  final String id;
  final String questionText;
  final String? audioPath; // مسار الصوت (اختياري)
  final String? imagePath; // مسار الصورة (اختياري)
  final List<TestOption> options;
  final String correctAnswerId;
  final QuestionType type;

  const TestQuestion({
    required this.id,
    required this.questionText,
    this.audioPath,
    this.imagePath,
    required this.options,
    required this.correctAnswerId,
    required this.type,
  });
}

// نموذج خيار الإجابة
class TestOption {
  final String id;
  final String text;
  final String? imagePath;
  final String? emoji;

  const TestOption({
    required this.id,
    required this.text,
    this.imagePath,
    this.emoji,
  });
}

// أنواع الأسئلة
enum QuestionType {
  audioToImage, // سماع صوت واختيار صورة
  imageToText, // رؤية صورة واختيار نص
  textToImage, // قراءة نص واختيار صورة
  audioToText, // سماع صوت واختيار نص
}

// بيانات اختبارات مرحلة الأساسي
class BasicLevelTestsData {
  // اختبار الفواكه
  static final fruitsTest = [
    TestQuestion(
      id: 'fruit_1',
      questionText: 'أين هو التفاح؟',
      audioPath: 'audio/fruits/تفاح.mp3',
      options: [
        TestOption(
            id: 'تفاح',
            text: 'تفاح',
            imagePath: 'images/food/تفاح.jpg',
            emoji: '🍎'),
        TestOption(
            id: 'موز',
            text: 'موز',
            imagePath: 'images/food/موز.jpg',
            emoji: '🍌'),
        TestOption(
            id: 'برتقال',
            text: 'برتقال',
            imagePath: 'images/food/برتقال.jpg',
            emoji: '🍊'),
        TestOption(
            id: 'عنب',
            text: 'عنب',
            imagePath: 'images/food/عنب.jpg',
            emoji: '🍇'),
      ],
      correctAnswerId: 'تفاح',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'fruit_2',
      questionText: 'أين هو الموز؟',
      audioPath: 'audio/fruits/موز.mp3',
      options: [
        TestOption(
            id: 'تفاح',
            text: 'تفاح',
            imagePath: 'images/food/تفاح.jpg',
            emoji: '🍎'),
        TestOption(
            id: 'موز',
            text: 'موز',
            imagePath: 'images/food/موز.jpg',
            emoji: '🍌'),
        TestOption(
            id: 'مانجو',
            text: 'مانجو',
            imagePath: 'images/food/مانجو.jpg',
            emoji: '🥭'),
        TestOption(
            id: 'كيوي',
            text: 'كيوي',
            imagePath: 'images/food/كيوي.jpg',
            emoji: '🥝'),
      ],
      correctAnswerId: 'موز',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'fruit_3',
      questionText: 'أين هو البرتقال؟',
      audioPath: 'audio/fruits/برتقال.mp3',
      options: [
        TestOption(
            id: 'برتقال',
            text: 'برتقال',
            imagePath: 'images/food/برتقال.jpg',
            emoji: '🍊'),
        TestOption(
            id: 'ليمون',
            text: 'ليمون',
            imagePath: 'images/food/ليمون.jpg',
            emoji: '🍋'),
        TestOption(
            id: 'تفاح',
            text: 'تفاح',
            imagePath: 'images/food/تفاح.jpg',
            emoji: '🍎'),
        TestOption(
            id: 'رمان',
            text: 'رمان',
            imagePath: 'images/food/رمان.jpg',
            emoji: '🍎'),
      ],
      correctAnswerId: 'برتقال',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'fruit_4',
      questionText: 'أين هو العنب؟',
      audioPath: 'audio/fruits/عنب.mp3',
      options: [
        TestOption(
            id: 'فراولة',
            text: 'فراولة',
            imagePath: 'images/food/فراولة.jpg',
            emoji: '🍓'),
        TestOption(
            id: 'عنب',
            text: 'عنب',
            imagePath: 'images/food/عنب.jpg',
            emoji: '🍇'),
        TestOption(
            id: 'كرز',
            text: 'كرز',
            imagePath: 'images/food/كرز.jpg',
            emoji: '🍒'),
        TestOption(
            id: 'توت',
            text: 'توت',
            imagePath: 'images/food/توت.jpg',
            emoji: '🫐'),
      ],
      correctAnswerId: 'عنب',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'fruit_5',
      questionText: 'أين هي الفراولة؟',
      audioPath: 'audio/fruits/فراولة.mp3',
      options: [
        TestOption(
            id: 'فراولة',
            text: 'فراولة',
            imagePath: 'images/food/فراولة.jpg',
            emoji: '🍓'),
        TestOption(
            id: 'كرز',
            text: 'كرز',
            imagePath: 'images/food/كرز.jpg',
            emoji: '🍒'),
        TestOption(
            id: 'رمان',
            text: 'رمان',
            imagePath: 'images/food/رمان.jpg',
            emoji: '🍎'),
        TestOption(
            id: 'تفاح',
            text: 'تفاح',
            imagePath: 'images/food/تفاح.jpg',
            emoji: '🍎'),
      ],
      correctAnswerId: 'فراولة',
      type: QuestionType.audioToImage,
    ),
  ];

  // اختبار الخضروات
  static final vegetablesTest = [
    TestQuestion(
      id: 'veg_1',
      questionText: 'أين هو الجزر؟',
      audioPath: 'audio/vegetables/جزر.mp3',
      options: [
        TestOption(id: 'جزر', text: 'جزر', emoji: '🥕'),
        TestOption(id: 'خيار', text: 'خيار', emoji: '🥒'),
        TestOption(id: 'طماطم', text: 'طماطم', emoji: '🍅'),
        TestOption(id: 'باذنجان', text: 'باذنجان', emoji: '🍆'),
      ],
      correctAnswerId: 'جزر',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'veg_2',
      questionText: 'أين هو الخيار؟',
      audioPath: 'audio/vegetables/خيار.mp3',
      options: [
        TestOption(id: 'جزر', text: 'جزر', emoji: '🥕'),
        TestOption(id: 'خيار', text: 'خيار', emoji: '🥒'),
        TestOption(id: 'بطاطا', text: 'بطاطا', emoji: '🥔'),
        TestOption(id: 'بصل', text: 'بصل', emoji: '🧅'),
      ],
      correctAnswerId: 'خيار',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'veg_3',
      questionText: 'أين هي البطاطا؟',
      audioPath: 'audio/vegetables/بطاطا.mp3',
      options: [
        TestOption(id: 'بطاطا', text: 'بطاطا', emoji: '🥔'),
        TestOption(id: 'باذنجان', text: 'باذنجان', emoji: '🍆'),
        TestOption(id: 'خس', text: 'خس', emoji: '🥬'),
        TestOption(id: 'ذرة', text: 'ذرة', emoji: '🌽'),
      ],
      correctAnswerId: 'بطاطا',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'veg_4',
      questionText: 'أين هو الباذنجان؟',
      audioPath: 'audio/vegetables/باذنجان.mp3',
      options: [
        TestOption(id: 'باذنجان', text: 'باذنجان', emoji: '🍆'),
        TestOption(id: 'طماطم', text: 'طماطم', emoji: '🍅'),
        TestOption(id: 'خيار', text: 'خيار', emoji: '🥒'),
        TestOption(id: 'بصل', text: 'بصل', emoji: '🧅'),
      ],
      correctAnswerId: 'باذنجان',
      type: QuestionType.audioToImage,
    ),
  ];

  // اختبار الألوان
  static final colorsTest = [
    TestQuestion(
      id: 'color_1',
      questionText: 'ما هو اللون الأحمر؟',
      audioPath: 'audio/colors/أحمر.mp3',
      options: [
        TestOption(id: 'أحمر', text: 'أحمر', emoji: '🔴'),
        TestOption(id: 'أزرق', text: 'أزرق', emoji: '🔵'),
        TestOption(id: 'أخضر', text: 'أخضر', emoji: '🟢'),
        TestOption(id: 'أصفر', text: 'أصفر', emoji: '🟡'),
      ],
      correctAnswerId: 'أحمر',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'color_2',
      questionText: 'ما هو اللون الأزرق؟',
      audioPath: 'audio/colors/أزرق.mp3',
      options: [
        TestOption(id: 'أحمر', text: 'أحمر', emoji: '🔴'),
        TestOption(id: 'أزرق', text: 'أزرق', emoji: '🔵'),
        TestOption(id: 'أخضر', text: 'أخضر', emoji: '🟢'),
        TestOption(id: 'وردي', text: 'وردي', emoji: '🩷'),
      ],
      correctAnswerId: 'أزرق',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'color_3',
      questionText: 'ما هو اللون الأخضر؟',
      audioPath: 'audio/colors/أخضر.mp3',
      options: [
        TestOption(id: 'أخضر', text: 'أخضر', emoji: '🟢'),
        TestOption(id: 'أصفر', text: 'أصفر', emoji: '🟡'),
        TestOption(id: 'برتقالي', text: 'برتقالي', emoji: '🟠'),
        TestOption(id: 'بنفسجي', text: 'بنفسجي', emoji: '🟣'),
      ],
      correctAnswerId: 'أخضر',
      type: QuestionType.audioToImage,
    ),
  ];

  // اختبار المهن
  static final professionsTest = [
    TestQuestion(
      id: 'prof_1',
      questionText: 'أين هو الطبيب؟',
      audioPath: 'audio/professions/طبيب.mp3',
      options: [
        TestOption(id: 'طبيب', text: 'طبيب', emoji: '👨‍⚕️'),
        TestOption(id: 'معلم', text: 'معلم', emoji: '👨‍🏫'),
        TestOption(id: 'شرطي', text: 'شرطي', emoji: '👮'),
        TestOption(id: 'طيار', text: 'طيار', emoji: '👨‍✈️'),
      ],
      correctAnswerId: 'طبيب',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'prof_2',
      questionText: 'أين هو المعلم؟',
      audioPath: 'audio/professions/معلم.mp3',
      options: [
        TestOption(id: 'طبيب', text: 'طبيب', emoji: '👨‍⚕️'),
        TestOption(id: 'معلم', text: 'معلم', emoji: '👨‍🏫'),
        TestOption(id: 'خباز', text: 'خباز', emoji: '👨‍🍳'),
        TestOption(id: 'جزار', text: 'جزار', emoji: '🔪'),
      ],
      correctAnswerId: 'معلم',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'prof_3',
      questionText: 'أين هو الشرطي؟',
      audioPath: 'audio/professions/شرطي.mp3',
      options: [
        TestOption(id: 'شرطي', text: 'شرطي', emoji: '👮'),
        TestOption(id: 'جندي', text: 'جندي', emoji: '🪖'),
        TestOption(id: 'رجل إطفاء', text: 'رجل إطفاء', emoji: '🧑‍🚒'),
        TestOption(id: 'طيار', text: 'طيار', emoji: '👨‍✈️'),
      ],
      correctAnswerId: 'شرطي',
      type: QuestionType.audioToImage,
    ),
  ];

  // اختبار أعضاء الجسم
  static final bodyPartsTest = [
    TestQuestion(
      id: 'body_1',
      questionText: 'أين هي العين؟',
      audioPath: 'audio/body_parts/العين.mp3',
      options: [
        TestOption(
            id: 'عين',
            text: 'عين',
            imagePath: 'images/body_parts/عين.jpg',
            emoji: '👁️'),
        TestOption(
            id: 'أذن',
            text: 'أذن',
            imagePath: 'images/body_parts/أذن.jpg',
            emoji: '👂'),
        TestOption(
            id: 'أنف',
            text: 'أنف',
            imagePath: 'images/body_parts/أنف.jpg',
            emoji: '👃'),
        TestOption(
            id: 'يد',
            text: 'يد',
            imagePath: 'images/body_parts/يد.jpg',
            emoji: '✋'),
      ],
      correctAnswerId: 'عين',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'body_2',
      questionText: 'أين هي الأذن؟',
      audioPath: 'audio/body_parts/الأذن.mp3',
      options: [
        TestOption(
            id: 'عين',
            text: 'عين',
            imagePath: 'images/body_parts/عين.jpg',
            emoji: '👁️'),
        TestOption(
            id: 'أذن',
            text: 'أذن',
            imagePath: 'images/body_parts/أذن.jpg',
            emoji: '👂'),
        TestOption(
            id: 'قدم',
            text: 'قدم',
            imagePath: 'images/body_parts/قدم.jpg',
            emoji: '🦶'),
        TestOption(
            id: 'يد',
            text: 'يد',
            imagePath: 'images/body_parts/يد.jpg',
            emoji: '✋'),
      ],
      correctAnswerId: 'أذن',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'body_3',
      questionText: 'أين هو الأنف؟',
      audioPath: 'audio/body_parts/الأنف.mp3',
      options: [
        TestOption(
            id: 'أنف',
            text: 'أنف',
            imagePath: 'images/body_parts/أنف.jpg',
            emoji: '👃'),
        TestOption(
            id: 'عين',
            text: 'عين',
            imagePath: 'images/body_parts/عين.jpg',
            emoji: '👁️'),
        TestOption(
            id: 'أذن',
            text: 'أذن',
            imagePath: 'images/body_parts/أذن.jpg',
            emoji: '👂'),
        TestOption(
            id: 'يد',
            text: 'يد',
            imagePath: 'images/body_parts/يد.jpg',
            emoji: '✋'),
      ],
      correctAnswerId: 'أنف',
      type: QuestionType.audioToImage,
    ),
  ];

  // اختبار العائلة
  static final familyTest = [
    TestQuestion(
      id: 'family_1',
      questionText: 'أين هو الأب؟',
      audioPath: 'audio/family/أب.mp3',
      options: [
        TestOption(id: 'أب', text: 'أب', emoji: '👨'),
        TestOption(id: 'أم', text: 'أم', emoji: '👩'),
        TestOption(id: 'ابن', text: 'ابن', emoji: '👦'),
        TestOption(id: 'بنت', text: 'بنت', emoji: '👧'),
      ],
      correctAnswerId: 'أب',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'family_2',
      questionText: 'أين هي الأم؟',
      audioPath: 'audio/family/أم.mp3',
      options: [
        TestOption(id: 'أب', text: 'أب', emoji: '👨'),
        TestOption(id: 'أم', text: 'أم', emoji: '👩'),
        TestOption(id: 'جد', text: 'جد', emoji: '👴'),
        TestOption(id: 'جدة', text: 'جدة', emoji: '👵'),
      ],
      correctAnswerId: 'أم',
      type: QuestionType.audioToImage,
    ),
    TestQuestion(
      id: 'family_3',
      questionText: 'أين هو الجد؟',
      audioPath: 'audio/family/جد.mp3',
      options: [
        TestOption(id: 'جد', text: 'جد', emoji: '👴'),
        TestOption(id: 'جدة', text: 'جدة', emoji: '👵'),
        TestOption(id: 'أب', text: 'أب', emoji: '👨'),
        TestOption(id: 'ابن', text: 'ابن', emoji: '👦'),
      ],
      correctAnswerId: 'جد',
      type: QuestionType.audioToImage,
    ),
  ];

  // الحصول على اختبار حسب المستوى
  static List<TestQuestion> getTestForLevel(String levelId) {
    switch (levelId) {
      case 'pronunciation_1': // الفواكه
        return fruitsTest;
      case 'pronunciation_2': // الألوان
        return colorsTest;
      case 'pronunciation_3': // المهن
        return professionsTest;
      case 'pronunciation_4': // أعضاء الجسم
        return bodyPartsTest;
      case 'pronunciation_5': // العائلة
        return familyTest;
      default:
        return [];
    }
  }
}
