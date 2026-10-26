import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../config.dart';
import '../i18n/i18n.dart';
import '../ui/theme/settings.dart';

/// Resultado del desafío del día para compartir, al estilo Wordle: cuántos
/// turnos usó y la racha, sin revelar la posición.
class DailyShare {
  /// Texto a compartir. [day] es el número de día de `Daily`.
  static String text({required int day, required int used, required int turns, required int streak}) {
    final hexes = [for (var i = 0; i < turns; i++) i < used ? '⬢' : '⬡'].join();
    return [
      tr('share.daily', {'n': day + 1}),
      '$hexes  ${tr('share.closedIn', {'used': used, 'turns': turns})}',
      if (streak > 1) '🔥 ${trN('daily.streak', streak)}',
      if (kShareUrl.isNotEmpty) kShareUrl,
    ].join('\n');
  }

  /// Abre la hoja de compartir del sistema. En iPad necesita un origen.
  static Future<void> share(BuildContext context, String text) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
    try {
      await SharePlus.instance.share(ShareParams(text: text, sharePositionOrigin: origin));
    } catch (e) {
      debugPrint('DailyShare: $e');
    }
  }
}

/// Pide una reseña en la tienda una sola vez, después de un buen momento (el
/// primer jefe vencido). La tienda decide si de verdad muestra la ventana.
class StoreReview {
  static Future<void> maybeAsk() async {
    final s = AppSettings.instance;
    if (s.reviewAsked) return;
    s.reviewAsked = true;
    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) await review.requestReview();
    } catch (e) {
      debugPrint('StoreReview: $e');
    }
  }
}
