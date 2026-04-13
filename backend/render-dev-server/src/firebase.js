import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

export function initializeFirebase(config) {
  if (getApps().length === 0) {
    const options = {};
    if (config.firebaseServiceAccountJson) {
      options.credential = cert(config.firebaseServiceAccountJson);
    }
    if (config.firebaseProjectId) {
      options.projectId = config.firebaseProjectId;
    }
    if (!options.credential && !options.projectId) {
      console.warn(
        'Firebase initialized without explicit credentials; relying on ADC.',
      );
    }
    initializeApp(options);
  }

  return {
    auth: getAuth(),
    db: getFirestore(),
  };
}
