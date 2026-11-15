// Renders the Turnstile widget with the settings in the query string and
// reports to the app: through the webview's MonthraTurnstile channel on a
// device, or postMessage to the parent (same origin only) in the web app.
// Messages: {source: "monthra-turnstile", type, token?, code?} with type
// ready | token | expired | error | unsupported. Nothing comes back in: the
// app resets the widget by loading the page again.
(function () {
  'use strict';

  var SOURCE = 'monthra-turnstile';
  var params = new URLSearchParams(window.location.search);

  // Every setting is checked against a closed format before use.
  function read(name, pattern) {
    var value = params.get(name);
    return value !== null && pattern.test(value) ? value : null;
  }

  var config = {
    sitekey: read('sitekey', /^[0-9A-Za-z_-]{1,64}$/),
    action: read('action', /^(login|register)$/),
    theme: read('theme', /^(light|dark)$/),
    language: read('lang', /^(pt-BR|es-ES|en-US)$/),
    size: read('size', /^(flexible|compact)$/),
    background: read('bg', /^[0-9A-Fa-f]{6}$/)
  };

  function post(message) {
    message.source = SOURCE;
    var channel = window.MonthraTurnstile;
    if (channel && typeof channel.postMessage === 'function') {
      channel.postMessage(JSON.stringify(message));
    } else if (window.parent !== window) {
      // Only this origin receives it: the app frames the page from itself.
      window.parent.postMessage(message, window.location.origin);
    }
  }

  var root = document.documentElement;
  if (config.theme) {
    root.style.colorScheme = config.theme;
  }
  if (config.background) {
    root.style.backgroundColor = '#' + config.background;
  }
  if (config.language) {
    root.lang = config.language;
  }

  // Called by api.js once loaded (render=explicit&onload=...).
  window.monthraTurnstileLoaded = function () {
    if (!config.sitekey || !config.action || !config.theme || !config.language || !config.size) {
      post({ type: 'error', code: 'config' });
      return;
    }
    var container = document.getElementById('widget');
    if (config.size === 'flexible') {
      container.className = 'flexible';
    }
    window.turnstile.render(container, {
      sitekey: config.sitekey,
      action: config.action,
      theme: config.theme,
      language: config.language.toLowerCase(),
      size: config.size,
      'response-field': false,
      'refresh-expired': 'auto',
      'feedback-enabled': false,
      callback: function (token) {
        post({ type: 'token', token: token });
      },
      'expired-callback': function () {
        post({ type: 'expired' });
      },
      'timeout-callback': function () {
        post({ type: 'expired' });
      },
      'error-callback': function (code) {
        post({ type: 'error', code: String(code).slice(0, 32) });
        // Handled: the widget keeps its own retry loop (retry: auto).
        return true;
      },
      'unsupported-callback': function () {
        post({ type: 'unsupported' });
      }
    });
    post({ type: 'ready' });
  };

  // api.js could not load (offline, blocked): tell the app instead of
  // leaving it waiting.
  window.addEventListener(
    'error',
    function (event) {
      var target = event.target;
      if (target && target.tagName === 'SCRIPT' && !window.turnstile) {
        post({ type: 'error', code: 'load' });
      }
    },
    true
  );
})();
