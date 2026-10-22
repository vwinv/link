/// Messages envoyés par la page web vers Flutter via [JavaScriptChannel].
abstract final class PublicCardWebBridge {
  static const channelName = 'LinkApp';
  static const saveContact = 'save-contact';

  /// Pont WebView : mode plein écran + interception du bouton contact.
  static const injectScript = '''
(function () {
  if (window.__linkAppBridgeInstalled) return;
  window.__linkAppBridgeInstalled = true;

  document.documentElement.classList.add('embed');

  if (!window.LinkApp || !window.LinkApp.postMessage) return;

  var saveLink = document.querySelector('[data-save-contact]');
  if (saveLink) {
    saveLink.addEventListener('click', function (event) {
      event.preventDefault();
      event.stopImmediatePropagation();
      LinkApp.postMessage('${PublicCardWebBridge.saveContact}');
    }, true);
  }
})();
''';
}
