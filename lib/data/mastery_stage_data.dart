/// أنواع التفاعل في صفحات القصة
enum InteractionType {
  /// أكمل الفراغ - اختر الكلمة الصحيحة
  fillInBlank,

  /// اختر الصورة الصحيحة
  chooseImage,

  /// انطق الكلمة
  pronounce,
}

/// صفحة واحدة من القصة
class StoryPage {
  final String text; // نص القصة (الفراغ يكون ___)
  final String imagePath; // صورة الصفحة الرئيسية
  final String? audioPath; // صوت الكلمة (اختياري)
  final InteractionType type; // نوع التفاعل
  final String correctAnswer; // الإجابة الصحيحة
  final List<String> options; // خيارات الكلمات
  final List<String>? optionImages; // مسارات صور الخيارات (لنوع chooseImage)

  const StoryPage({
    required this.text,
    required this.imagePath,
    this.audioPath,
    required this.type,
    required this.correctAnswer,
    required this.options,
    this.optionImages,
  });
}

/// قصة كاملة (درس واحد)
class StoryLesson {
  final String id;
  final String title;
  final String description;
  final String icon; // إيموجي
  final List<StoryPage> pages;
  final int order;

  const StoryLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.pages,
    required this.order,
  });
}

/// بيانات مرحلة المتقن - 6 قصص تفاعلية
class MasteryStageData {
  // ============================================
  // القصة 1: مغامرة في حديقة الحيوانات
  // ============================================
  static const story1 = StoryLesson(
    id: 'mastery_story_1',
    title: 'مغامرة في حديقة الحيوانات',
    description: 'سامي يزور حديقة الحيوانات مع عائلته',
    icon: '🐾',
    order: 1,
    pages: [
      StoryPage(
        text: 'ذهب سامي مع أبيه إلى حديقة الحيوانات.\nرأى ___ كبيراً وقوياً!',
        imagePath: 'assets/images/animals/أسد.jpg',
        type: InteractionType.fillInBlank,
        correctAnswer: 'أسد',
        options: ['أسد', 'قطة', 'كلب'],
      ),
      StoryPage(
        text: 'ثم شاهد حيواناً طويل الرقبة!\nإنه ___ الجميلة.',
        imagePath: 'assets/images/animals/زرافة.jpg',
        type: InteractionType.fillInBlank,
        correctAnswer: 'زرافة',
        options: ['زرافة', 'فيل', 'أرنب'],
      ),
      StoryPage(
        text: 'في البركة، رأى سامي ___ يسبح\nويقفز في الماء!',
        imagePath: 'assets/images/animals/دولفين.jpg',
        type: InteractionType.fillInBlank,
        correctAnswer: 'دولفين',
        options: ['دولفين', 'ثعبان', 'نملة'],
      ),
      StoryPage(
        text: 'سمع سامي صوتاً عالياً جداً!\nمن هذا الحيوان الكبير؟',
        imagePath: 'assets/images/animals/فيل.jpg',
        type: InteractionType.chooseImage,
        correctAnswer: 'فيل',
        options: ['فيل', 'أرنب', 'قطة'],
        optionImages: [
          'assets/images/animals/فيل.jpg',
          'assets/images/animals/أرنب.jpg',
          'assets/images/animals/قطة.jpg',
        ],
      ),
      StoryPage(
        text: 'في النهاية، رأى سامي ___ يطير\nعالياً في السماء!',
        imagePath: 'assets/images/animals/صقر.jpg',
        type: InteractionType.pronounce,
        correctAnswer: 'صقر',
        options: [],
      ),
    ],
  );

  // ============================================
  // القصة 2: يوم في المزرعة
  // ============================================
  static const story2 = StoryLesson(
    id: 'mastery_story_2',
    title: 'يوم في المزرعة',
    description: 'نورة تزور مزرعة جدها وتتعرف على الفواكه',
    icon: '🍎',
    order: 2,
    pages: [
      StoryPage(
        text: 'ذهبت نورة إلى مزرعة جدها.\nقطفت ___ أحمر من الشجرة.',
        imagePath: 'assets/images/food/تفاح.jpg',
        audioPath: 'assets/audio/fruits/تفاح.mp3',
        type: InteractionType.fillInBlank,
        correctAnswer: 'تفاح',
        options: ['تفاح', 'ليمون', 'خيار'],
      ),
      StoryPage(
        text: 'وجدت نورة ___ أصفر\nتحت الشجرة الكبيرة.',
        imagePath: 'assets/images/food/موز.jpg',
        audioPath: 'assets/audio/fruits/موز.mp3',
        type: InteractionType.fillInBlank,
        correctAnswer: 'موز',
        options: ['موز', 'جزر', 'عنب'],
      ),
      StoryPage(
        text: 'في الحقل، رأت نورة ___\nبرتقالي كبير ينمو في الأرض.',
        imagePath: 'assets/images/food/جزر.jpg',
        audioPath: 'assets/audio/vegetables/جزر.mp3',
        type: InteractionType.fillInBlank,
        correctAnswer: 'جزر',
        options: ['جزر', 'تفاح', 'بطيخ'],
      ),
      StoryPage(
        text: 'ما هي هذه الفاكهة الحمراء\nالصغيرة واللذيذة؟',
        imagePath: 'assets/images/food/فراولة.jpg',
        audioPath: 'assets/audio/fruits/فراولة.mp3',
        type: InteractionType.chooseImage,
        correctAnswer: 'فراولة',
        options: ['فراولة', 'عنب', 'ليمون'],
        optionImages: [
          'assets/images/food/فراولة.jpg',
          'assets/images/food/عنب.jpg',
          'assets/images/food/ليمون.jpg',
        ],
      ),
      StoryPage(
        text: 'ساعدت نورة جدها في جمع ___\nالأحمر من الحقل!',
        imagePath: 'assets/images/food/طماطم.jpg',
        audioPath: 'assets/audio/vegetables/طماطم.mp3',
        type: InteractionType.pronounce,
        correctAnswer: 'طماطم',
        options: [],
      ),
    ],
  );

  // ============================================
  // القصة 3: رحلة في المدينة
  // ============================================
  static const story3 = StoryLesson(
    id: 'mastery_story_3',
    title: 'رحلة في المدينة',
    description: 'أحمد يركب وسائل النقل المختلفة',
    icon: '🚗',
    order: 3,
    pages: [
      StoryPage(
        text: 'ركب أحمد ___ من البيت\nإلى المدرسة مع أصدقائه.',
        imagePath: 'assets/images/transportation/باص.jpg',
        type: InteractionType.fillInBlank,
        correctAnswer: 'باص',
        options: ['باص', 'سفينة', 'دراجة نارية'],
      ),
      StoryPage(
        text: 'نظر أحمد إلى السماء.\nرأى ___ تطير عالياً!',
        imagePath: 'assets/images/transportation/طائرة.jpg',
        type: InteractionType.fillInBlank,
        correctAnswer: 'طائرة',
        options: ['طائرة', 'قطار', 'شاحنة'],
      ),
      StoryPage(
        text: 'عند الشاطئ، شاهد أحمد\n___ كبيرة تبحر في الماء.',
        imagePath: 'assets/images/transportation/سفينة.jpg',
        type: InteractionType.fillInBlank,
        correctAnswer: 'سفينة',
        options: ['سفينة', 'سيارة', 'باص'],
      ),
      StoryPage(
        text: 'أي وسيلة نقل تسير\nعلى السكة الحديد؟',
        imagePath: 'assets/images/transportation/قطار.jpg',
        type: InteractionType.chooseImage,
        correctAnswer: 'قطار',
        options: ['قطار', 'تاكسي', 'هيلوكبتر'],
        optionImages: [
          'assets/images/transportation/قطار.jpg',
          'assets/images/transportation/تاكسي.jpg',
          'assets/images/transportation/هيلوكبتر.jpg',
        ],
      ),
      StoryPage(
        text: 'عاد أحمد إلى البيت بـ ___\nمع أبيه. يا لها من رحلة!',
        imagePath: 'assets/images/transportation/سيارة.jpg',
        type: InteractionType.pronounce,
        correctAnswer: 'سيارة',
        options: [],
      ),
    ],
  );

  // ============================================
  // القصة 4: أبطال كل يوم
  // ============================================
  static const story4 = StoryLesson(
    id: 'mastery_story_4',
    title: 'أبطال كل يوم',
    description: 'ليلى تتعرف على المهن المختلفة',
    icon: '👨‍⚕️',
    order: 4,
    pages: [
      StoryPage(
        text: 'مرضت ليلى قليلاً.\nذهبت مع أمها إلى ___.',
        imagePath: 'assets/images/professions/دكتور.jpg',
        audioPath: 'assets/audio/professions/طبيب.mp3',
        type: InteractionType.fillInBlank,
        correctAnswer: 'دكتور',
        options: ['دكتور', 'مزارع', 'طباخ'],
      ),
      StoryPage(
        text: 'في المدرسة، يعلمها ___\nالحروف والأرقام كل يوم.',
        imagePath: 'assets/images/professions/معلم.jpg',
        audioPath: 'assets/audio/professions/معلم.mp3',
        type: InteractionType.fillInBlank,
        correctAnswer: 'معلم',
        options: ['معلم', 'شرطي', 'جزار'],
      ),
      StoryPage(
        text: 'عند الإشارة، ينظم المرور\n___ ليعبر الجميع بأمان.',
        imagePath: 'assets/images/professions/شرطي.jpg',
        audioPath: 'assets/audio/professions/شرطي.mp3',
        type: InteractionType.fillInBlank,
        correctAnswer: 'شرطي',
        options: ['شرطي', 'رسام', 'قبطان'],
      ),
      StoryPage(
        text: 'من يزرع لنا الطعام اللذيذ\nفي الحقل كل يوم؟',
        imagePath: 'assets/images/professions/مزارع.jpg',
        type: InteractionType.chooseImage,
        correctAnswer: 'مزارع',
        options: ['مزارع', 'محامي', 'رسام'],
        optionImages: [
          'assets/images/professions/مزارع.jpg',
          'assets/images/professions/محامي.jpg',
          'assets/images/professions/رسام.jpg',
        ],
      ),
      StoryPage(
        text: 'ومن يطبخ الطعام اللذيذ\nفي المطعم؟ إنه ___!',
        imagePath: 'assets/images/professions/طباخ.jpg',
        type: InteractionType.pronounce,
        correctAnswer: 'طباخ',
        options: [],
      ),
    ],
  );

  // ============================================
  // القصة 5: كنوز الطبيعة
  // ============================================
  static const story5 = StoryLesson(
    id: 'mastery_story_5',
    title: 'كنوز الطبيعة',
    description: 'عمر يستكشف الطبيعة الجميلة',
    icon: '🌳',
    order: 5,
    pages: [
      StoryPage(
        text: 'في الصباح الباكر، أشرقت\n___ في السماء وأنارت الدنيا.',
        imagePath: 'assets/images/nature/شمس.jpg',
        type: InteractionType.fillInBlank,
        correctAnswer: 'شمس',
        options: ['شمس', 'قمر', 'مطر'],
      ),
      StoryPage(
        text: 'وفي الليل، ظهر ___\nجميل ومضيء في السماء.',
        imagePath: 'assets/images/nature/قمر.jpg',
        type: InteractionType.fillInBlank,
        correctAnswer: 'قمر',
        options: ['قمر', 'شمس', 'شاطئ'],
      ),
      StoryPage(
        text: 'جلس عمر تحت ___ كبيرة\nولعب مع أصدقائه.',
        imagePath: 'assets/images/nature/شجرة.jpg',
        type: InteractionType.fillInBlank,
        correctAnswer: 'شجرة',
        options: ['شجرة', 'أرض', 'شلال'],
      ),
      StoryPage(
        text: 'ماذا ينزل من السماء\nفي فصل الشتاء؟',
        imagePath: 'assets/images/nature/مطر.jpg',
        type: InteractionType.chooseImage,
        correctAnswer: 'مطر',
        options: ['مطر', 'شمس', 'شاطئ'],
        optionImages: [
          'assets/images/nature/مطر.jpg',
          'assets/images/nature/شمس.jpg',
          'assets/images/nature/شاطئ.jpg',
        ],
      ),
      StoryPage(
        text: 'ذهب عمر إلى ___ ليسبح\nويلعب في الرمل. يا للمتعة!',
        imagePath: 'assets/images/nature/شاطئ.jpg',
        type: InteractionType.pronounce,
        correctAnswer: 'شاطئ',
        options: [],
      ),
    ],
  );

  // ============================================
  // القصة 6: مغامرة في المنزل
  // ============================================
  static const story6 = StoryLesson(
    id: 'mastery_story_6',
    title: 'مغامرة في المنزل',
    description: 'مريم تستكشف أشياء في منزلها',
    icon: '🏠',
    order: 6,
    pages: [
      StoryPage(
        text: 'عادت مريم من المدرسة.\nفتحت ___ ودخلت البيت.',
        imagePath: 'assets/images/objects/باب.jpg',
        type: InteractionType.fillInBlank,
        correctAnswer: 'باب',
        options: ['باب', 'نافذة', 'مظلة'],
      ),
      StoryPage(
        text: 'جلست مريم على ___\nوأخرجت واجباتها.',
        imagePath: 'assets/images/objects/كرسي.jpg',
        type: InteractionType.fillInBlank,
        correctAnswer: 'كرسي',
        options: ['كرسي', 'سرير', 'طاولة'],
      ),
      StoryPage(
        text: 'أخذت مريم ___ وبدأت\nتقرأ قصة جميلة.',
        imagePath: 'assets/images/objects/كتاب.jpg',
        type: InteractionType.fillInBlank,
        correctAnswer: 'كتاب',
        options: ['كتاب', 'مقص', 'قبعة'],
      ),
      StoryPage(
        text: 'ما الذي تنظر فيه مريم\nكل صباح قبل المدرسة؟',
        imagePath: 'assets/images/objects/مرآة.jpg',
        type: InteractionType.chooseImage,
        correctAnswer: 'مرآة',
        options: ['مرآة', 'ساعة حائط', 'كاميرا'],
        optionImages: [
          'assets/images/objects/مرآة.jpg',
          'assets/images/objects/ساعة حائط.jpg',
          'assets/images/objects/كاميرا.jpg',
        ],
      ),
      StoryPage(
        text: 'قبل النوم، أطفأت مريم ___\nوقالت: تصبحون على خير!',
        imagePath: 'assets/images/objects/لمبة.jpg',
        type: InteractionType.pronounce,
        correctAnswer: 'لمبة',
        options: [],
      ),
    ],
  );

  /// جميع القصص
  static const allStories = [
    story1,
    story2,
    story3,
    story4,
    story5,
    story6,
  ];

  /// الحصول على قصة بواسطة ID
  static StoryLesson? getStory(String id) {
    try {
      return allStories.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
