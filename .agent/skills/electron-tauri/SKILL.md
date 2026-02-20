---
name: Electron / Tauri
description: Skill for building cross-platform desktop applications — covering Electron (Chromium-based) and Tauri (Rust-based) frameworks, IPC communication, native APIs, auto-updates, and packaging.
---

# Electron / Tauri Skill

## Overview
Electron and Tauri are frameworks for building cross-platform desktop applications using web technologies. Electron bundles Chromium + Node.js (larger but more mature), while Tauri uses the system webview + Rust backend (smaller, more secure, faster).

**References**:
- [Electron Documentation](https://www.electronjs.org/docs)
- [Tauri Documentation](https://tauri.app/start/)

---

## When to Choose

| Feature | Electron | Tauri |
|---------|----------|-------|
| **Bundle size** | ~150MB+ | ~3-10MB |
| **Memory usage** | High (Chromium) | Low (system webview) |
| **Backend** | Node.js (JavaScript) | Rust |
| **Webview** | Bundled Chromium | System (WebView2/WebKit) |
| **Maturity** | Very mature, huge ecosystem | Growing, production-ready |
| **Node.js access** | Full | Via Rust commands |
| **Best for** | Complex apps, Node.js ecosystem | Lightweight, performance-critical |

---

## Tauri (Recommended for New Projects)

### Setup
```bash
npm create tauri-app@latest myapp
cd myapp
npm install
npm run tauri dev
```

### Project Structure
```
myapp/
├── src/                          # Frontend (React/Vue/Svelte)
│   ├── App.tsx
│   ├── main.tsx
│   └── lib/
│       └── tauri.ts             # Tauri API wrappers
├── src-tauri/                    # Rust backend
│   ├── src/
│   │   ├── main.rs              # Entry point
│   │   ├── lib.rs               # Commands
│   │   └── db.rs                # Database logic
│   ├── Cargo.toml
│   ├── tauri.conf.json          # App configuration
│   └── icons/
├── package.json
└── vite.config.ts
```

### Tauri Commands (Rust → Frontend)
```rust
// src-tauri/src/lib.rs
use serde::{Deserialize, Serialize};
use tauri::Manager;

#[derive(Debug, Serialize, Deserialize)]
pub struct User {
    pub id: String,
    pub name: String,
    pub email: String,
}

#[tauri::command]
async fn get_users(db: tauri::State<'_, Database>) -> Result<Vec<User>, String> {
    db.get_all_users().await.map_err(|e| e.to_string())
}

#[tauri::command]
async fn create_user(name: String, email: String, db: tauri::State<'_, Database>) -> Result<User, String> {
    db.create_user(&name, &email).await.map_err(|e| e.to_string())
}

#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! Welcome to Tauri.", name)
}

pub fn run() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![get_users, create_user, greet])
        .setup(|app| {
            let db = Database::new("myapp.db")?;
            app.manage(db);
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### Frontend — Invoke Commands
```typescript
// src/lib/tauri.ts
import { invoke } from '@tauri-apps/api/core';

interface User {
  id: string;
  name: string;
  email: string;
}

export async function getUsers(): Promise<User[]> {
  return invoke('get_users');
}

export async function createUser(name: string, email: string): Promise<User> {
  return invoke('create_user', { name, email });
}

// Usage in React
function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);

  useEffect(() => {
    getUsers().then(setUsers);
  }, []);

  const handleCreate = async (name: string, email: string) => {
    const user = await createUser(name, email);
    setUsers((prev) => [...prev, user]);
  };

  return (/* render users */);
}
```

### Tauri Events (Backend → Frontend)
```rust
// Emit event from Rust
app.emit("download-progress", DownloadProgress { percent: 75, file: "update.zip".into() })?;

// Listen in frontend
import { listen } from '@tauri-apps/api/event';

const unlisten = await listen<{ percent: number; file: string }>('download-progress', (event) => {
  console.log(`Download: ${event.payload.percent}%`);
});
// Cleanup: unlisten();
```

### Tauri Configuration
```json
// src-tauri/tauri.conf.json
{
  "productName": "MyApp",
  "version": "1.0.0",
  "identifier": "com.myapp.desktop",
  "build": {
    "frontendDist": "../dist"
  },
  "app": {
    "windows": [
      {
        "title": "MyApp",
        "width": 1200,
        "height": 800,
        "minWidth": 800,
        "minHeight": 600,
        "resizable": true,
        "center": true
      }
    ],
    "security": {
      "csp": "default-src 'self'; style-src 'self' 'unsafe-inline'"
    }
  },
  "bundle": {
    "active": true,
    "targets": "all",
    "icon": ["icons/icon.png"]
  }
}
```

---

## Electron

### Setup
```bash
npm init electron-app@latest myapp -- --template=vite-react-ts
cd myapp
npm start
```

### Main Process (main.ts)
```typescript
// src/main.ts
import { app, BrowserWindow, ipcMain } from 'electron';
import path from 'path';

let mainWindow: BrowserWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,           // Security: isolate renderer
      nodeIntegration: false,            // Security: no Node in renderer
    },
    titleBarStyle: 'hiddenInset',        // macOS-style titlebar
  });

  if (process.env.NODE_ENV === 'development') {
    mainWindow.loadURL('http://localhost:5173');
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(__dirname, '../dist/index.html'));
  }
}

app.whenReady().then(createWindow);
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });

// IPC Handlers
ipcMain.handle('get-users', async () => {
  return db.getUsers();
});

ipcMain.handle('create-user', async (event, { name, email }) => {
  return db.createUser(name, email);
});
```

### Preload Script
```typescript
// src/preload.ts
import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('api', {
  getUsers: () => ipcRenderer.invoke('get-users'),
  createUser: (name: string, email: string) => ipcRenderer.invoke('create-user', { name, email }),
  onProgress: (callback: (data: any) => void) => {
    ipcRenderer.on('progress', (_, data) => callback(data));
  },
});

// TypeScript: declare global type
declare global {
  interface Window {
    api: {
      getUsers: () => Promise<User[]>;
      createUser: (name: string, email: string) => Promise<User>;
      onProgress: (callback: (data: any) => void) => void;
    };
  }
}
```

### Renderer (React)
```typescript
function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);

  useEffect(() => {
    window.api.getUsers().then(setUsers);
  }, []);

  return (/* render users */);
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Tauri for new apps** | Smaller bundles, better security, Rust performance |
| **Context isolation** | Always enable in Electron (contextIsolation: true) |
| **No nodeIntegration** | Never enable nodeIntegration in renderer |
| **IPC for communication** | Frontend ↔ Backend via IPC, never expose Node directly |
| **CSP** | Set strict Content Security Policy |
| **Auto-updates** | Tauri: built-in updater / Electron: electron-updater |
| **Code signing** | Sign apps for distribution (Apple notarization, Windows signing) |
| **State management** | Use Tauri `State` or Electron `ipcMain.handle` for shared state |

---

## Rules Integration
- **Architecture**: Frontend (React/Vue) + Backend (Rust/Node.js), IPC bridge
- **Security**: Context isolation, no Node in renderer, strict CSP
- **Tauri**: Rust commands with `#[tauri::command]`, event system, managed state
- **Electron**: Preload scripts for IPC, `contextBridge`, `ipcMain.handle`
- **Distribution**: Code signing, auto-updates, platform-specific builds
