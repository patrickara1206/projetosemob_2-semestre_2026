const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const source = fs.readFileSync(path.join(__dirname, '../web/flutter_bootstrap.js'), 'utf8')
  .replace('{{flutter_js}}', '').replace('{{flutter_build_config}}', '');

async function run(registrations, fail = false) {
  const events = [];
  const context = {
    URL,
    document: { baseURI: 'http://localhost:8080/' },
    navigator: { serviceWorker: { getRegistrations: async () => {
      if (fail) throw new Error('Unavailable');
      return registrations;
    } } },
    window: { caches: true },
    caches: { delete: async name => { events.push(name); } },
    console: { warn: () => events.push('warning') },
    _flutter: { loader: { load: () => events.push('load') } },
  };
  await new vm.Script(source).runInNewContext(context);
  return events;
}

test('Previous Flutter worker is removed before loading current application', async () => {
  let removed = false;
  const events = await run([{
    scope: 'http://localhost:8080/',
    active: { scriptURL: 'http://localhost:8080/flutter_service_worker.js?v=old' },
    unregister: async () => { removed = true; },
  }]);
  assert.equal(removed, true);
  assert.deepEqual(events, ['flutter-app-cache', 'flutter-temp-cache', 'flutter-app-manifest', 'load']);
});

test('Workers from other scopes and applications are preserved', async () => {
  const forbidden = async () => { throw new Error('Must not remove another application'); };
  const events = await run([
    { scope: 'http://localhost:8080/other/', active: { scriptURL: 'http://localhost:8080/other/flutter_service_worker.js' }, unregister: forbidden },
    { scope: 'http://localhost:8080/', active: { scriptURL: 'http://localhost:8080/other-worker.js' }, unregister: forbidden },
  ]);
  assert.deepEqual(events, ['load']);
});

test('Application still loads if cache cleanup is unavailable', async () => {
  assert.deepEqual(await run([], true), ['warning', 'load']);
});

test('Main application bundle gets a fresh URL on each startup', async () => {
  const build = {mainJsPath: 'main.dart.js'};
  const context = {
    navigator: {},
    Date: {now: () => 123},
    _flutter: {buildConfig: {builds: [build]}, loader: {load: () => {}}},
  };
  await new vm.Script(source).runInNewContext(context);
  assert.equal(build.mainJsPath, 'main.dart.js?semob=123');
});
