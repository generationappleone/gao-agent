# Tracing — Playwright CLI

## Start Trace Recording

```bash
# Start tracing
playwright trace start --screenshots --snapshots

# Perform actions...
playwright navigate https://example.com
playwright click e3  
playwright fill e1 "test"

# Stop and save trace
playwright trace stop --path trace.zip
```

## View Trace

```bash
# Open trace viewer (local UI)
playwright show-trace trace.zip

# Or serve via browser
npx playwright show-trace trace.zip
```

## Trace Contents

A trace file (`.zip`) contains:
- **Screenshots** at each action
- **DOM snapshots** at each step
- **Network logs** (requests/responses)
- **Console logs** (errors, warnings)
- **Action timeline** with durations

## Network Logs in Trace

```bash
# Enable network logging
playwright trace start --screenshots --snapshots --sources

# All network requests/responses are captured
# View in trace viewer under "Network" tab
```

## Debugging with Traces

### Identify Failures

1. Open trace viewer
2. Navigate to the failed step (red highlight)
3. Check the **Before** and **After** snapshots
4. Inspect **Network** tab for failed requests
5. Check **Console** tab for JS errors

### Performance Analysis

```bash
# Record trace with timing
playwright trace start --screenshots

# In trace viewer:
# - Action column shows duration per step
# - Network tab shows request timing
# - Timeline shows parallelism
```

## CI Integration

```bash
# Record trace on failure
playwright trace start
# ... run test steps ...
# If failure:
playwright trace stop --path ./artifacts/trace-failure.zip
```

## Best Practices

- Always enable `--screenshots` for visual debugging
- Use `--snapshots` for DOM state inspection
- Traces are large — only record when debugging
- Keep trace files for failed CI runs (upload as artifacts)
