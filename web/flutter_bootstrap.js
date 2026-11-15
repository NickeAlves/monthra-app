{{flutter_js}}
{{flutter_build_config}}

// nginx writes a fresh CSP nonce on this script's tag for every response
// (index.html); the engine tags the styles and scripts it creates with it,
// so the CSP needs no 'unsafe-inline'. Without nginx (flutter run) the
// placeholder stays and no CSP applies.
const nonce = document.currentScript ? document.currentScript.nonce : undefined;

window.addEventListener(
  'flutter-first-frame',
  () => {
    const splash = document.getElementById('splash');
    if (splash) splash.remove();
  },
  { once: true },
);

_flutter.loader.load({ config: { nonce: nonce || undefined } });
