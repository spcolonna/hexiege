import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../i18n/i18n.dart';
import '../ui/theme/settings.dart';

/// Compra única que desbloquea la historia completa (desde la batalla 7 de
/// cada campaña y El Sello). Sin servidor: StoreKit / Play confirman la
/// compra y queda guardada en los ajustes; "Restaurar" la recupera.
class Purchases extends ChangeNotifier {
  Purchases._();
  static final instance = Purchases._();

  static const storyId = 'hexiege_story';

  ProductDetails? _story;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _busy = false;
  String? _error;

  /// Hay una compra o restauración en curso.
  bool get busy => _busy;

  /// Último error para mostrar (null = ninguno).
  String? get error => _error;

  /// Precio localizado de la tienda; mientras no carga, el de referencia.
  String get price => _story?.price ?? tr('store.priceFallback');

  Future<void> init() async {
    if (_sub != null) return;
    try {
      final iap = InAppPurchase.instance;
      _sub = iap.purchaseStream.listen(_onUpdates, onError: (Object e) => _fail('$e'));
      if (!await iap.isAvailable()) return;
      final r = await iap.queryProductDetails({storyId});
      _story = r.productDetails.where((p) => p.id == storyId).firstOrNull;
      notifyListeners();
    } catch (e) {
      debugPrint('Compras no disponibles: $e');
    }
  }

  Future<void> buy() async {
    _error = null;
    final story = _story;
    if (story == null) {
      // Puede que la tienda no haya respondido al arrancar: un reintento.
      await init().catchError((_) {});
      if (_story == null) return _fail(tr('store.unavailable'));
      return buy();
    }
    _setBusy(true);
    try {
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: story));
    } catch (e) {
      _fail(tr('store.unavailable'));
    }
  }

  Future<void> restore() async {
    _error = null;
    _setBusy(true);
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      _fail(tr('store.unavailable'));
    }
    // Si no había nada que restaurar, la tienda no avisa: se suelta solo.
    Timer(const Duration(seconds: 6), () => _setBusy(false));
  }

  Future<void> _onUpdates(List<PurchaseDetails> updates) async {
    for (final p in updates) {
      if (p.productID != storyId) continue;
      switch (p.status) {
        case PurchaseStatus.purchased || PurchaseStatus.restored:
          AppSettings.instance.storyUnlocked = true;
          _setBusy(false);
        case PurchaseStatus.error:
          _fail(p.error?.message ?? tr('store.unavailable'));
        case PurchaseStatus.canceled:
          _setBusy(false);
        case PurchaseStatus.pending:
          _setBusy(true);
      }
      if (p.pendingCompletePurchase) await InAppPurchase.instance.completePurchase(p);
    }
  }

  void _fail(String message) {
    _error = message;
    _busy = false;
    notifyListeners();
  }

  void _setBusy(bool v) {
    if (_busy == v) return;
    _busy = v;
    notifyListeners();
  }
}
