---
name: MCP Server — Unity
description: MCP Server for Unity — enables AI assistants to control the Unity Editor, manage assets, manipulate scenes, generate C# scripts, run tests, and automate game development workflows.
---

# MCP Server — Unity

## Overview
Unity MCP Server provides bidirectional communication between the Unity Editor and AI assistants, enabling AI-driven game development automation — from asset management and scene manipulation to script generation and test execution.

## Tools Provided

| Tool | Description |
|------|-------------|
| `create_gameobject` | Create a new GameObject in the scene |
| `add_component` | Add a component to a GameObject |
| `update_component` | Modify component properties |
| `get_scene_hierarchy` | Get the full scene hierarchy |
| `create_material` | Create a new material |
| `import_asset` | Import assets into the project |
| `read_script` | Read C# script contents |
| `write_script` | Create or modify C# scripts |
| `compile_scripts` | Trigger script compilation |
| `run_tests` | Execute Unity Test Runner |
| `build_project` | Build the project for a target platform |
| `play_scene` | Enter Play mode |
| `stop_scene` | Exit Play mode |
| `undo` | Undo last editor action |
| `redo` | Redo last undone action |
| `get_project_settings` | Read project configuration |

## Configuration

```json
{
  "mcpServers": {
    "unity": {
      "command": "npx",
      "args": ["-y", "unity-mcp-server"],
      "env": {
        "UNITY_PROJECT_PATH": "C:/Projects/MyGame"
      }
    }
  }
}
```

## Supported Platforms
- Windows, macOS, Linux (Editor)
- Build targets: PC, Android, iOS, WebGL, Consoles

## Use Cases
- AI-assisted level design and scene setup
- Automated C# script generation following Unity conventions
- Shader code generation
- Automated testing with Test Runner integration
- Batch asset processing and organization
- Rapid prototyping with AI-generated game logic
