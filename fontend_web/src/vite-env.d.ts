interface ImportMetaEnv {
  // Vite environment flags (injected by Vite at build/dev time)
  readonly DEV: boolean;
  readonly PROD: boolean;

  // Application-specific env vars
  readonly VITE_API_URL?: string;
  readonly VITE_API_BASE_URL?: string;
  readonly VITE_APP_NAME?: string;

}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
