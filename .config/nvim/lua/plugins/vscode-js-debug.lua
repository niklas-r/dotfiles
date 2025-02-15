return {
  'microsoft/vscode-js-debug',
  build = 'npm install --frozen-lockfile --legacy-peer-deps && git reset --hard HEAD && npx gulp vsDebugServerBundle && rm -rf ./out && mv -f dist out',
}
