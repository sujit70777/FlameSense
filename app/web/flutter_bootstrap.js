{{flutter_js}}
{{flutter_build_config}}
_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    const appRunner = await engineInitializer.initializeEngine();
    document.getElementById('fs-splash')?.remove();
    await appRunner.runApp();
  },
});
