import 'dart:html' as html;
import 'dart:ui' as ui;

class YouTubePlayerWeb {
  static void registerYouTubePlayer(String videoId) {
    // تسجيل عنصر HTML لـ YouTube
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'youtube-$videoId',
      (int viewId) {
        final iframe = html.IFrameElement()
          ..width = '100%'
          ..height = '100%'
          ..src =
              'https://www.youtube.com/embed/$videoId?autoplay=1&loop=1&playlist=$videoId&controls=1&modestbranding=1'
          ..style.border = 'none'
          ..allow =
              'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';

        return iframe;
      },
    );
  }
}
