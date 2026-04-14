import { createApp } from './app.js';
import { readConfig } from './config.js';
import { initializeFirebase } from './firebase.js';

const config = readConfig();
const firebase = initializeFirebase(config);
const app = createApp({
  config,
  ...firebase,
});

app.listen(config.port, () => {
  console.log(`render-dev-server listening on ${config.port}`);
});
