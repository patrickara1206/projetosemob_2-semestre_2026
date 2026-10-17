{{flutter_js}}
{{flutter_build_config}}

(async function () {
  // Remove somente o worker e os caches gerados pelo Flutter desta aplicação.
  try {
    if ('serviceWorker' in navigator) {
      const base = new URL(document.baseURI);
      const workerPath = new URL('flutter_service_worker.js', base).pathname;
      const registrations = await navigator.serviceWorker.getRegistrations();
      let previousFlutterWorker = false;
      for (const registration of registrations) {
        const worker = registration.active || registration.waiting || registration.installing;
        if (registration.scope === base.href && worker && new URL(worker.scriptURL).pathname === workerPath) {
          await registration.unregister();
          previousFlutterWorker = true;
        }
      }
      if (previousFlutterWorker && 'caches' in window) {
        await Promise.all(['flutter-app-cache', 'flutter-temp-cache', 'flutter-app-manifest']
          .map(name => caches.delete(name)));
      }
    }
  } catch (error) {
    console.warn('Não foi possível limpar o cache anterior do Flutter.', error);
  }
  for (const build of _flutter.buildConfig?.builds || []) {
    if (build.mainJsPath) {
      build.mainJsPath += (build.mainJsPath.includes('?') ? '&' : '?') + 'semob=' + Date.now();
    }
  }
  // Sem serviceWorkerSettings: cada execução usa os arquivos atuais do servidor.
  _flutter.loader.load();
})();
