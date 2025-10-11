/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_URL?: string;
  readonly VITE_API_BASE_URL?: string;
  readonly VITE_APP_NAME?: string;
  // Add other VITE_ env variables as needed
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
