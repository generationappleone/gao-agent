---
name: WebSocket
description: Skill for implementing real-time communication with WebSocket — covering native WebSocket API, Socket.IO, WS library, event-driven patterns, reconnection, authentication, rooms/channels, and scaling strategies.
---

# WebSocket Skill

## Overview
WebSocket provides full-duplex communication channels over a single TCP connection. This skill covers WebSocket protocol, Socket.IO, and WS library for real-time applications.

**Reference**: [RFC 6455 - WebSocket Protocol](https://datatracker.ietf.org/doc/html/rfc6455)

## Native WebSocket (Browser)
```typescript
const ws = new WebSocket("wss://api.example.com/ws");

ws.onopen = () => {
  console.log("Connected");
  ws.send(JSON.stringify({ type: "subscribe", channel: "notifications" }));
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log("Received:", data);
};

ws.onclose = (event) => {
  console.log(`Disconnected: ${event.code} ${event.reason}`);
};

ws.onerror = (error) => console.error("WebSocket error:", error);
```

## WS Library (Node.js Server)
```typescript
import { WebSocketServer, WebSocket } from "ws";
import { createServer } from "http";

const server = createServer();
const wss = new WebSocketServer({ server });

const clients = new Map<string, WebSocket>();

wss.on("connection", (ws, req) => {
  const clientId = crypto.randomUUID();
  clients.set(clientId, ws);

  ws.on("message", (raw) => {
    const message = JSON.parse(raw.toString());
    switch (message.type) {
      case "chat":
        broadcast({ type: "chat", from: clientId, text: message.text });
        break;
      case "ping":
        ws.send(JSON.stringify({ type: "pong" }));
        break;
    }
  });

  ws.on("close", () => clients.delete(clientId));
  ws.on("error", (err) => console.error(`Client ${clientId}:`, err));
});

function broadcast(data: object, exclude?: string) {
  const msg = JSON.stringify(data);
  clients.forEach((ws, id) => {
    if (id !== exclude && ws.readyState === WebSocket.OPEN) {
      ws.send(msg);
    }
  });
}

server.listen(3001);
```

## Socket.IO (Recommended for Production)
```typescript
// Server
import { Server } from "socket.io";

const io = new Server(httpServer, {
  cors: { origin: "http://localhost:3000", credentials: true },
  pingInterval: 25000,
  pingTimeout: 60000,
});

// Authentication middleware
io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  try {
    socket.data.user = verifyJWT(token);
    next();
  } catch {
    next(new Error("Authentication failed"));
  }
});

io.on("connection", (socket) => {
  const user = socket.data.user;

  // Join rooms
  socket.join(`user:${user.id}`);
  socket.join("general");

  // Handle events
  socket.on("chat:message", (data) => {
    io.to(data.room).emit("chat:message", {
      from: user.name, text: data.text, timestamp: new Date(),
    });
  });

  // Emit to specific user
  socket.on("notification:send", (data) => {
    io.to(`user:${data.userId}`).emit("notification", data);
  });

  socket.on("disconnect", (reason) => {
    console.log(`${user.name} disconnected: ${reason}`);
  });
});

// Client
import { io } from "socket.io-client";

const socket = io("http://localhost:3001", {
  auth: { token: "jwt-token-here" },
  reconnection: true,
  reconnectionAttempts: 5,
  reconnectionDelay: 1000,
});

socket.on("connect", () => console.log("Connected:", socket.id));
socket.on("chat:message", (msg) => console.log(msg));
socket.emit("chat:message", { room: "general", text: "Hello!" });
```

## Reconnection Pattern
```typescript
class ReconnectingWebSocket {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxAttempts = 10;
  private baseDelay = 1000;

  constructor(private url: string) { this.connect(); }

  private connect() {
    this.ws = new WebSocket(this.url);
    this.ws.onopen = () => { this.reconnectAttempts = 0; };
    this.ws.onclose = () => this.reconnect();
    this.ws.onerror = () => this.ws?.close();
  }

  private reconnect() {
    if (this.reconnectAttempts >= this.maxAttempts) return;
    const delay = this.baseDelay * Math.pow(2, this.reconnectAttempts++);
    setTimeout(() => this.connect(), Math.min(delay, 30000));
  }

  send(data: object) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(data));
    }
  }
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Use WSS** | Always use `wss://` (TLS) in production |
| **Authentication** | Authenticate on handshake, not after connect |
| **Heartbeat/Ping** | Implement ping/pong to detect dead connections |
| **Reconnection** | Exponential backoff with max attempts |
| **Message format** | Use JSON with `{ type, payload }` convention |
| **Socket.IO** | Preferred for production — handles reconnection, rooms, fallback |
| **Rate limiting** | Limit messages per client to prevent abuse |
| **Rooms/Channels** | Group connections by topic for targeted broadcasts |
| **Error handling** | Handle `error` and `close` events gracefully |
| **Scaling** | Use Redis adapter for multi-server Socket.IO |
