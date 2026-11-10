/// Messages envoyés par la page web vers Flutter via [JavaScriptChannel].
abstract final class PublicCardWebBridge {
  static const channelName = 'LinkApp';
  static const saveContact = 'save-contact';
  static const previewLink = 'preview-link';

  /// Pont WebView : mode plein écran + interception du bouton contact.
  /// [asGuestPreview] : ne pas forcer `embed` (même vue qu’un visiteur web)
  /// et bloquer les liens avec un message « partagez pour vos visiteurs ».
  static String injectScript({bool asGuestPreview = false}) => '''
(function () {
  if (window.__linkAppBridgeInstalled) return;
  window.__linkAppBridgeInstalled = true;

  ${asGuestPreview ? '' : "document.documentElement.classList.add('embed');"}

  if (!window.LinkApp || !window.LinkApp.postMessage) return;

  ${asGuestPreview ? _previewLinkInterceptScript : _saveContactInterceptScript}
})();
''';

  static const _saveContactInterceptScript = '''
  var saveLink = document.querySelector('[data-save-contact]');
  if (saveLink) {
    saveLink.addEventListener('click', function (event) {
      event.preventDefault();
      event.stopImmediatePropagation();
      LinkApp.postMessage('$saveContact');
    }, true);
  }
''';

  static const _previewLinkInterceptScript = '''
  document.addEventListener('click', function (event) {
    var el = event.target && event.target.closest
      ? event.target.closest('a, [data-share-card], [data-save-contact], [data-download-app], [data-portfolio-click]')
      : null;
    if (!el) return;
    if (el.closest && el.closest('[data-guest-lead-form]')) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    LinkApp.postMessage('$previewLink');
  }, true);
''';

  /// Intercepte les liens du portfolio en aperçu propriétaire.
  static String injectPortfolioPreviewScript() => '''
(function () {
  if (window.__linkPortfolioPreviewInstalled) return;
  window.__linkPortfolioPreviewInstalled = true;
  if (!window.LinkApp || !window.LinkApp.postMessage) return;
  document.addEventListener('click', function (event) {
    var el = event.target && event.target.closest
      ? event.target.closest('a')
      : null;
    if (!el) return;
    if (el.closest && el.closest('[data-guest-lead-form]')) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    LinkApp.postMessage('$previewLink');
  }, true);
})();
''';
}
