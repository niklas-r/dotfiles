return {
  'microsoft/vscode-js-debug',
  build = 'npm install --frozen-lockfile --legacy-peer-deps && git reset --hard HEAD && npx gulp vsDebugServerBundle && mv dist out',
}
