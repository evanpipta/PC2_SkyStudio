// src/UI/types/preact.d.ts
declare module '/js/common/lib/preact.js' {
  export * from 'preact';
}

// SkyStudio ships its own private preact copy to avoid other mods overriding
// the shared /js/common/lib/preact.js. Type it the same as preact.
declare module '/SkyStudioPreact.js' {
  export * from 'preact';
}
