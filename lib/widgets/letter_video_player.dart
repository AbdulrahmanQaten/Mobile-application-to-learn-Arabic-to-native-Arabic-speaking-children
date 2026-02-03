import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';

class LetterVideoPlayer extends StatefulWidget {
  final String letter;

  const LetterVideoPlayer({super.key, required this.letter});

  @override
  State<LetterVideoPlayer> createState() => _LetterVideoPlayerState();
}

class _LetterVideoPlayerState extends State<LetterVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // اختيار الصيغة حسب المنصة
      final extension = kIsWeb ? 'webm' : 'mp4';
      final folder = kIsWeb ? 'letters_web' : 'letters';
      final letterNumber = _getLetterNumber(widget.letter);

      // المسار الكامل مع أرقام الحروف
      final videoPath = 'assets/videos/$folder/$letterNumber.$extension';

      print('🎥 ═══════════════════════════════════════');
      print('🎥 محاولة تحميل الفيديو');
      print('🎥 المنصة: ${kIsWeb ? "الويب" : "الموبايل"}');
      print('🎥 الحرف: ${widget.letter}');
      print('🎥 رقم الحرف: $letterNumber');
      print('🎥 الصيغة: $extension');
      print('🎥 المسار الكامل: $videoPath');
      print('🎥 ═══════════════════════════════════════');

      _controller = VideoPlayerController.asset(videoPath);

      print('🎥 تم إنشاء Controller');

      await _controller!.initialize();

      print('✅ تم تهيئة الفيديو بنجاح!');
      print('🎥 الأبعاد: ${_controller!.value.size}');
      print('🎥 المدة: ${_controller!.value.duration}');

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });

        // تشغيل تلقائي
        _controller!.play();
        _controller!.setLooping(true);
        print('▶️ تم بدء التشغيل');
      }
    } catch (e, stackTrace) {
      print('❌ ═══════════════════════════════════════');
      print('❌ خطأ في تحميل الفيديو!');
      print('❌ الخطأ: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ ═══════════════════════════════════════');

      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  // تحويل الحرف إلى رقم (1-28)
  String _getLetterNumber(String letter) {
    final letterNumbers = {
      'ا': '1', // ألف
      'ب': '2', // باء
      'ت': '3', // تاء
      'ث': '4', // ثاء
      'ج': '5', // جيم
      'ح': '6', // حاء
      'خ': '7', // خاء
      'د': '8', // دال
      'ذ': '9', // ذال
      'ر': '10', // راء
      'ز': '11', // زين
      'س': '12', // سين
      'ش': '13', // شين
      'ص': '14', // صاد
      'ض': '15', // ضاد
      'ط': '16', // طاء
      'ظ': '17', // ظاء
      'ع': '18', // عين
      'غ': '19', // غين
      'ف': '20', // فاء
      'ق': '21', // قاف
      'ك': '22', // كاف
      'ل': '23', // لام
      'م': '24', // ميم
      'ن': '25', // نون
      'هـ': '26', // هاء
      'ه': '26', // هاء (نسخة بديلة)
      'و': '27', // واو
      'ي': '28', // ياء
    };

    return letterNumbers[letter] ?? '1';
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: AppTheme.successGreen.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle, color: AppTheme.successGreen, size: 28),
              SizedBox(width: 10),
              Text('فيديو رسم الحرف',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primarySkyBlue)),
            ],
          ),
          SizedBox(height: 15),
          if (_hasError)
            _buildErrorWidget()
          else if (!_isInitialized)
            _buildLoadingWidget()
          else
            _buildVideoWidget(),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primarySkyBlue),
            SizedBox(height: 10),
            Text('جاري تحميل الفيديو...',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined,
              size: 60, color: AppTheme.primarySkyBlue.withOpacity(0.5)),
          SizedBox(height: 15),
          Text(
            'فيديو رسم الحرف ${widget.letter}',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primarySkyBlue),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.lightSkyBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  'عذراً، حدث خطأ في تحميل الفيديو',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  kIsWeb
                      ? 'تأكد من وجود ملفات WebM في assets/videos/letters_web/'
                      : 'تأكد من وجود ملفات MP4 في assets/videos/letters/',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoWidget() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // زر التشغيل/الإيقاف
            IconButton(
              icon: Icon(
                _controller!.value.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                size: 50,
                color: AppTheme.primarySkyBlue,
              ),
              onPressed: () {
                setState(() {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                });
              },
            ),
            SizedBox(width: 20),
            // زر إعادة التشغيل
            IconButton(
              icon: Icon(Icons.replay, size: 40, color: AppTheme.successGreen),
              onPressed: () {
                _controller!.seekTo(Duration.zero);
                _controller!.play();
              },
            ),
          ],
        ),
        SizedBox(height: 10),
        // شريط التقدم
        VideoProgressIndicator(
          _controller!,
          allowScrubbing: true,
          colors: VideoProgressColors(
            playedColor: AppTheme.primarySkyBlue,
            bufferedColor: AppTheme.lightSkyBlue,
            backgroundColor: Colors.grey[300]!,
          ),
        ),
      ],
    );
  }
}
