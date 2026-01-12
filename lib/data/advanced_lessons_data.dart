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
  // المستوى 1: الحروف (أ - ج)
  static const lesson1 = AdvancedLesson(
    id: 'advanced_1',
    name: 'الحروف الأولى',
    description: 'تعلم كتابة الحروف الأولى',
    letters: ['ا', 'ب', 'ت', 'ث', 'ج'],
    order: 1,
  );

  // المستوى 2: الحروف (ح - ر)
  static const lesson2 = AdvancedLesson(
    id: 'advanced_2',
    name: 'حروف جديدة',
    description: 'تعلم كتابة حروف جديدة',
    letters: ['ح', 'خ', 'د', 'ذ', 'ر'],
    order: 2,
  );

  // المستوى 3: الحروف (ز - ض)
  static const lesson3 = AdvancedLesson(
    id: 'advanced_3',
    name: 'المزيد من الحروف',
    description: 'تعلم كتابة المزيد من الحروف',
    letters: ['ز', 'س', 'ش', 'ص', 'ض'],
    order: 3,
  );

  // المستوى 4: الحروف (ط - ف)
  static const lesson4 = AdvancedLesson(
    id: 'advanced_4',
    name: 'حروف مميزة',
    description: 'تعلم كتابة حروف مميزة',
    letters: ['ط', 'ظ', 'ع', 'غ', 'ف'],
    order: 4,
  );

  // المستوى 5: الحروف (ق - ن)
  static const lesson5 = AdvancedLesson(
    id: 'advanced_5',
    name: 'نواصل التعلم',
    description: 'تعلم كتابة حروف جديدة',
    letters: ['ق', 'ك', 'ل', 'م', 'ن'],
    order: 5,
  );

  // المستوى 6: الحروف الأخيرة (هـ - ي)
  static const lesson6 = AdvancedLesson(
    id: 'advanced_6',
    name: 'إكمال الأبجدية',
    description: 'تعلم كتابة آخر الحروف',
    letters: ['هـ', 'و', 'ي'],
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
