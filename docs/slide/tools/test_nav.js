// Kiem tra phim dieu huong cua Slides_NhomX.html bang Node (DOM gia lap toi thieu).
// Chay: node docs/slide/tools/test_nav.js
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const html = fs.readFileSync(path.join(__dirname, '..', 'Slides_NhomX.html'), 'utf8');
const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)];
const code = scripts[scripts.length - 1][1];

function classList() {
  const set = new Set();
  return {
    contains: (c) => set.has(c),
    toggle: (c, on) => (on ? set.add(c) : set.delete(c)),
    add: (c) => set.add(c),
  };
}
const style = () => ({ setProperty() {} });

function load() {
  const slides = Array.from({ length: 5 }, () => ({ classList: classList(), style: style(), appendChild() {} }));
  const handlers = {};
  const calls = { fullscreen: 0 };
  const location = { hash: '', pathname: '/s.html', search: '' };
  const ctx = {
    document: {
      querySelectorAll: (sel) => (sel === '.slide' ? slides : []),
      createElement: () => ({ style: style() }),
      documentElement: { style: style(), requestFullscreen: () => { calls.fullscreen++; return Promise.reject(new Error('no')); } },
      fullscreenElement: null,
      body: { classList: classList(), setAttribute() {} },
      fonts: { ready: Promise.resolve() },
    },
    location,
    history: { replaceState: (a, b, url) => { location.hash = url.slice(url.indexOf('#')); } },
    addEventListener: (t, f) => { handlers[t] = f; },
    removeEventListener() {},
    innerWidth: 1280, innerHeight: 720,
    URLSearchParams, Math, parseInt, isNaN, Array, RegExp,
  };
  vm.runInNewContext(code, ctx);
  const active = () => slides.findIndex((s) => s.classList.contains('active')) + 1;
  const press = (key, mods = {}) => {
    let prevented = false;
    handlers.keydown(Object.assign({ key, preventDefault: () => { prevented = true; } }, mods));
    return prevented;
  };
  return { active, press, calls };
}

let fail = 0;
function check(name, got, want) {
  const ok = JSON.stringify(got) === JSON.stringify(want);
  if (!ok) fail++;
  console.log(`${ok ? 'PASS' : 'FAIL'} ${name}: got ${JSON.stringify(got)}, want ${JSON.stringify(want)}`);
}

{ const t = load(); t.press('ArrowRight'); t.press(' '); check('ArrowRight, Space tien 2 slide', t.active(), 3); }
{ const t = load(); t.press('End'); t.press(' ', { shiftKey: true }); check('Shift+Space lui 1 slide', t.active(), 4); }
{ const t = load(); t.press('ArrowRight'); const p = t.press('ArrowLeft', { altKey: true });
  check('Alt+ArrowLeft khong doi slide, khong chan Back', [t.active(), p], [2, false]); }
{ const t = load(); t.press('f', { ctrlKey: true }); t.press('F', { metaKey: true });
  check('Ctrl+F / Cmd+F khong bat toan man hinh', t.calls.fullscreen, 0); }
{ const t = load(); t.press('f'); check('F bat toan man hinh', t.calls.fullscreen, 1); }

process.on('unhandledRejection', (e) => { fail++; console.log('FAIL requestFullscreen bi tu choi ma khong duoc bat loi:', e.message); });
setTimeout(() => { console.log(fail ? `FAIL: ${fail} loi` : 'OK: dieu huong'); process.exit(fail ? 1 : 0); }, 50);
