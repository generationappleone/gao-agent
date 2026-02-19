---
name: Electron / Tauri
description: Skill for building cross-platform desktop applications — covering Electron (Chromium-based) and Tauri (Rust-based) frameworks, IPC communication, native APIs, auto-updates, and packaging.
---

# Electron / Tauri Skill

## Overview
Electron and Tauri are frameworks for building cross-platform desktop applications using web technologies. Tauri is the modern, lighter alternative.

## Electron
**Reference**: [Electron Documentation](https://www.electronjs.org/docs)

### Main Process
```typescript
// main.ts
import { app, BrowserWindow, ipcMain } from "electron";
import path from "path";

let mainWindow: BrowserWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200, height: 800,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false, // ✅ Security: always false
    },
  });
  mainWindow.loadFile("index.html");
}

app.whenReady().then(createWindow);

// IPC handlers
ipcMain.handle("read-file", async (_, filePath: string) => {
  return fs.readFileSync(filePath, "utf-8");
});
```

### Preload (Context Bridge)
```typescript
// preload.ts
import { contextBridge, ipcRenderer } from "electron";

contextBridge.exposeInMainWorld("electronAPI", {
  readFile: (path: string) => ipcRenderer.invoke("read-file", path),
  onUpdate: (cb: (msg: string) => void) => ipcRenderer.on("update", (_, msg) => cb(msg)),
});
```

## Tauri (Recommended)
**Reference**: [Tauri Documentation](https://tauri.app/v2/guide/)

### Rust Backend
```rust
// src-tauri/src/main.rs
#[tauri::command]
async fn greet(name: &str) -> Result<String, String> {
    Ok(format!("Hello, {}!", name))
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet])
        .run(tauri::generate_context!())
        .expect("error running tauri");
}
```

### Frontend Invocation
```typescript
import { invoke } from "@tauri-apps/api/core";
const greeting = await invoke<string>("greet", { name: "World" });
```

## Comparison

| Feature | Electron | Tauri |
|---------|----------|-------|
| **Bundle size** | ~150MB | ~3-10MB |
| **Memory** | High (Chromium) | Low (system webview) |
| **Backend** | Node.js | Rust |
| **Language** | JavaScript | Rust + JS |
| **Auto-update** | electron-updater | Built-in |
| **Security** | contextBridge | Strong by default |

## Best Practices

| Practice | Description |
|----------|-------------|
| **Tauri for new projects** | Smaller, faster, more secure |
| **Context isolation** | Always `contextIsolation: true` in Electron |
| **No nodeIntegration** | Always `false` in renderer |
| **IPC** | All main↔renderer via IPC, never direct |
| **Auto-update** | Implement for production apps |
| **Code signing** | Sign for macOS/Windows distribution |
| **CSP headers** | Set Content-Security-Policy |
