class PronunciationWord {
  final String word;
  final String audioPath;
  final String imagePath;
  final String category;

  const PronunciationWord({
    required this.word,
    required this.audioPath,
    required this.imagePath,
    required this.category,
  });
}

class PronunciationLevel {
  final String id;
  final String name;
  final String category;
  final List<PronunciationWord> words;

  const PronunciationLevel({
    required this.id,
    required this.name,
    required this.category,
    required this.words,
  });
}

class PronunciationLessonsData {
  // المستوى 1: الفواكه 🍎
  static const level1 = PronunciationLevel(
    id: 'pronunciation_1',
    name: 'الفواكه',
    category: 'فواكه',
    words: [
      PronunciationWord(
        word: 'تفاح',
        audioPath: 'audio/fruits/تفاح.mp3',
        imagePath: 'images/food/تفاح.jpg',
        category: 'فواكه',
      ),
      PronunciationWord(
        word: 'موز',
        audioPath: 'audio/fruits/موز.mp3',
        imagePath: 'images/food/موز.jpg',
        category: 'فواكه',
      ),
      PronunciationWord(
        word: 'برتقال',
        audioPath: 'audio/fruits/برتقال.mp3',
        imagePath: 'images/food/برتقال.jpg',
        category: 'فواكه',
      ),
      PronunciationWord(
        word: 'عنب',
        audioPath: 'audio/fruits/عنب.mp3',
        imagePath: 'images/food/عنب.jpg',
        category: 'فواكه',
      ),
      PronunciationWord(
        word: 'مانجو',
        audioPath: 'audio/fruits/مانجو.mp3',
        imagePath: 'images/food/مانجو.jpg',
        category: 'فواكه',
      ),
    ],
  );

  // المستوى 2: الألوان 🎨
  static const level2 = PronunciationLevel(
    id: 'pronunciation_2',
    name: 'الألوان',
    category: 'ألوان',
    words: [
      PronunciationWord(
        word: 'أحمر',
        audioPath: 'audio/colors/أحمر.mp3',
        imagePath: 'COLOR:0xFFFF0000', // دائرة حمراء
        category: 'ألوان',
      ),
      PronunciationWord(
        word: 'أزرق',
        audioPath: 'audio/colors/أزرق.mp3',
        imagePath: 'COLOR:0xFF2196F3', // دائرة زرقاء
        category: 'ألوان',
      ),
      PronunciationWord(
        word: 'أخضر',
        audioPath: 'audio/colors/أخضر.mp3',
        imagePath: 'COLOR:0xFF4CAF50', // دائرة خضراء
        category: 'ألوان',
      ),
      PronunciationWord(
        word: 'أصفر',
        audioPath: 'audio/colors/أصفر.mp3',
        imagePath: 'COLOR:0xFFFFEB3B', // دائرة صفراء
        category: 'ألوان',
      ),
      PronunciationWord(
        word: 'وردي',
        audioPath: 'audio/colors/وردي.mp3',
        imagePath: 'COLOR:0xFFFFB6C1', // دائرة وردية فاتحة
        category: 'ألوان',
      ),
    ],
  );

  // المستوى 3: المهن 👨‍⚕️
  static const level3 = PronunciationLevel(
    id: 'pronunciation_3',
    name: 'المهن',
    category: 'مهن',
    words: [
      PronunciationWord(
        word: 'طبيب',
        audioPath: 'audio/professions/طبيب.mp3',
        imagePath: 'EMOJI:👨‍⚕️',
        category: 'مهن',
      ),
      PronunciationWord(
        word: 'معلم',
        audioPath: 'audio/professions/معلم.mp3',
        imagePath: 'EMOJI:👨‍🏫',
        category: 'مهن',
      ),
      PronunciationWord(
        word: 'شرطي',
        audioPath: 'audio/professions/شرطي.mp3',
        imagePath: 'EMOJI:👮',
        category: 'مهن',
      ),
      PronunciationWord(
        word: 'طيار',
        audioPath: 'audio/professions/طيار.mp3',
        imagePath: 'EMOJI:👨‍✈️',
        category: 'مهن',
      ),
      PronunciationWord(
        word: 'خباز',
        audioPath: 'audio/professions/خباز.mp3',
        imagePath: 'EMOJI:👨‍🍳',
        category: 'مهن',
      ),
    ],
  );

  // المستوى 4: أعضاء الجسم 👁️
  static const level4 = PronunciationLevel(
    id: 'pronunciation_4',
    name: 'أعضاء الجسم',
    category: 'أعضاء الجسم',
    words: [
      PronunciationWord(
        word: 'عين',
        audioPath: 'audio/body_parts/العين.mp3',
        imagePath: 'images/body_parts/عين.jpg',
        category: 'أعضاء الجسم',
      ),
      PronunciationWord(
        word: 'أذن',
        audioPath: 'audio/body_parts/الأذن.mp3',
        imagePath: 'images/body_parts/أذن.jpg',
        category: 'أعضاء الجسم',
      ),
      PronunciationWord(
        word: 'أنف',
        audioPath: 'audio/body_parts/الأنف.mp3',
        imagePath: 'images/body_parts/أنف.jpg',
        category: 'أعضاء الجسم',
      ),
      PronunciationWord(
        word: 'يد',
        audioPath: 'audio/body_parts/اليد.mp3',
        imagePath: 'images/body_parts/يد.jpg',
        category: 'أعضاء الجسم',
      ),
      PronunciationWord(
        word: 'قدم',
        audioPath: 'audio/body_parts/الرجل.mp3',
        imagePath: 'images/body_parts/قدم.jpg',
        category: 'أعضاء الجسم',
      ),
    ],
  );

  // المستوى 5: العائلة 👨‍👩‍👧‍👦
  static const level5 = PronunciationLevel(
    id: 'pronunciation_5',
    name: 'العائلة',
    category: 'عائلة',
    words: [
      PronunciationWord(
        word: 'أب',
        audioPath: 'audio/family/أب.mp3',
        imagePath: 'EMOJI:👨',
        category: 'عائلة',
      ),
      PronunciationWord(
        word: 'أم',
        audioPath: 'audio/family/أم.mp3',
        imagePath: 'EMOJI:👩',
        category: 'عائلة',
      ),
      PronunciationWord(
        word: 'ابن',
        audioPath: 'audio/family/ابن.mp3',
        imagePath: 'EMOJI:👦',
        category: 'عائلة',
      ),
      PronunciationWord(
        word: 'بنت',
        audioPath: 'audio/family/بنت.mp3',
        imagePath: 'EMOJI:👧',
        category: 'عائلة',
      ),
      PronunciationWord(
        word: 'جد',
        audioPath: 'audio/family/جد.mp3',
        imagePath: 'EMOJI:👴',
        category: 'عائلة',
      ),
      PronunciationWord(
        word: 'جدة',
        audioPath: 'audio/family/جدة.mp3',
        imagePath: 'EMOJI:👵',
        category: 'عائلة',
      ),
    ],
  );

  // قائمة جميع المستويات
  static const allLevels = [
    level1,
    level2,
    level3,
    level4,
    level5,
  ];

  // الحصول على مستوى بواسطة ID
  static PronunciationLevel? getLevel(String id) {
    try {
      return allLevels.firstWhere((level) => level.id == id);
    } catch (e) {
      return null;
    }
  }
}
