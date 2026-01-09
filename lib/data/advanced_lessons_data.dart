class AdvancedLesson {
  final String id;
  final String name;
  final String description;
  final List<String> letters; // الحروف المطلوب كتابتها
  final int order;

  const AdvancedLesson({
    required this.id,
    required this.name,
    required this.description,
    required this.letters,
    required this.order,
  });
}

class AdvancedLessonsData {
  // المستوى 1: الحروف البسيطة (بدون نقاط)
  static const lesson1 = AdvancedLesson(
    id: 'advanced_1',
    name: 'الحروف البسيطة',
    description: 'تعلم كتابة الحروف بدون نقاط',
    letters: ['ا', 'د', 'ذ', 'ر', 'ز', 'و'],
    order: 1,
  );

  // المستوى 2: الحروف بنقطة واحدة
  static const lesson2 = AdvancedLesson(
    id: 'advanced_2',
    name: 'الحروف بنقطة',
    description: 'تعلم كتابة الحروف التي لها نقطة واحدة',
    letters: ['ن', 'ج', 'خ', 'ز'],
    order: 2,
  );

  // المستوى 3: الحروف بنقطتين
  static const lesson3 = AdvancedLesson(
    id: 'advanced_3',
    name: 'الحروف بنقطتين',
    description: 'تعلم كتابة الحروف التي لها نقطتان',
    letters: ['ب', 'ت', 'ث', 'ي'],
    order: 3,
  );

  // المستوى 4: الحروف المتشابهة (س، ش، ص، ض)
  static const lesson4 = AdvancedLesson(
    id: 'advanced_4',
    name: 'الحروف المتشابهة 1',
    description: 'تعلم كتابة الحروف المتشابهة',
    letters: ['س', 'ش', 'ص', 'ض'],
    order: 4,
  );

  // المستوى 5: الحروف المتشابهة (ط، ظ، ع، غ)
  static const lesson5 = AdvancedLesson(
    id: 'advanced_5',
    name: 'الحروف المتشابهة 2',
    description: 'تعلم كتابة الحروف المتشابهة',
    letters: ['ط', 'ظ', 'ع', 'غ'],
    order: 5,
  );

  // المستوى 6: باقي الحروف
  static const lesson6 = AdvancedLesson(
    id: 'advanced_6',
    name: 'الحروف المتبقية',
    description: 'تعلم كتابة باقي الحروف',
    letters: ['ف', 'ق', 'ك', 'ل', 'م', 'هـ', 'ح'],
    order: 6,
  );

  static const allLessons = [
    lesson1,
    lesson2,
    lesson3,
    lesson4,
    lesson5,
    lesson6,
  ];

  static AdvancedLesson? getLesson(String id) {
    try {
      return allLessons.firstWhere((lesson) => lesson.id == id);
    } catch (e) {
      return null;
    }
  }

  // الحصول على اسم الحرف
  static String getLetterName(String letter) {
    const letterNames = {
      'ا': 'ألف',
      'ب': 'باء',
      'ت': 'تاء',
      'ث': 'ثاء',
      'ج': 'جيم',
      'ح': 'حاء',
      'خ': 'خاء',
      'د': 'دال',
      'ذ': 'ذال',
      'ر': 'راء',
      'ز': 'زاي',
      'س': 'سين',
      'ش': 'شين',
      'ص': 'صاد',
      'ض': 'ضاد',
      'ط': 'طاء',
      'ظ': 'ظاء',
      'ع': 'عين',
      'غ': 'غين',
      'ف': 'فاء',
      'ق': 'قاف',
      'ك': 'كاف',
      'ل': 'لام',
      'م': 'ميم',
      'ن': 'نون',
      'هـ': 'هاء',
      'و': 'واو',
      'ي': 'ياء',
    };
    return letterNames[letter] ?? letter;
  }
}
