# Video Recording — Playwright CLI

## Capture Video

```bash
# Start video recording
playwright open --record-video ./videos/ https://example.com

# Perform actions...
playwright snapshot
playwright click e1
playwright fill e2 "test"

# Video is saved when session closes
playwright close
```

## Output

- Format: **WebM** (VP8 codec)
- Default filename: `[timestamp]-[session-name].webm`
- Location: directory specified in `--record-video`

## Configuration

```bash
# Custom video size
playwright open --record-video ./videos/ --record-video-size 1280,720 https://example.com

# Combined with other options
playwright open \
  --record-video ./videos/ \
  --record-video-size 1920,1080 \
  --viewport-size 1920,1080 \
  https://example.com
```

## Tracing vs Video

| Feature | Tracing | Video |
|---------|---------|-------|
| **Format** | ZIP (snapshots + logs) | WebM |
| **Interactive** | Yes (trace viewer) | No (playback only) |
| **Network data** | Yes | No |
| **DOM state** | Yes (snapshots) | No |
| **File size** | Larger | Smaller |
| **Best for** | Debugging | Demo/documentation |

## Use Cases

- **Bug reproduction** — Record exact steps that trigger a bug
- **Documentation** — Create visual demos of features
- **Regression** — Compare video before/after changes
