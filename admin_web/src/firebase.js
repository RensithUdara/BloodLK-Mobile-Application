import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getFunctions } from 'firebase/functions';
import { getMessaging, isSupported } from 'firebase/messaging';

const firebaseConfig = {
  apiKey: 'AIzaSyCFV1TPYFZuyJ3mnh1PBfpnRfeCSpDkjHo',
  authDomain: 'bloodlk-mobile-app.firebaseapp.com',
  projectId: 'bloodlk-mobile-app',
  storageBucket: 'bloodlk-mobile-app.firebasestorage.app',
  messagingSenderId: '620602740253',
  appId: '1:620602740253:web:94e4b1688159633f4680f4',
  measurementId: 'G-Z1GVJTG11Q',
};

export const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export const functions = getFunctions(app);
export const messagingPromise = isSupported().then((supported) =>
  supported ? getMessaging(app) : null,
);
