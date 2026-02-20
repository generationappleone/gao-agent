---
name: WebSocket
description: Skill for implementing real-time communication with WebSocket — covering native WebSocket API, Socket.IO, WS library, event-driven patterns, reconnection, authentication, rooms/channels, and scaling strategies.
---

# WebSocket Skill

## Overview
WebSocket provides full-duplex, persistent communication between client and server over a single TCP connection. Socket.IO is the most popular WebSocket library, adding automatic reconnection, rooms, namespaces, and fallback transports. Use for real-time features: chat, notifications, live updates, presence.

**References**:
- [Socket.IO Documentation](https://socket.io/docs/v4/)
- [MDN WebSocket API](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)

---

## Socket.IO Server

```typescript
// src/socket/server.ts
import { Server } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';
import { verifyAccessToken } from '../services/jwt.service';

export function setupSocketIO(httpServer: HttpServer) {
  const io = new Server(httpServer, {
    cors: { origin: process.env.CORS_ORIGINS?.split(','), credentials: true },
    pingInterval: 25000,
    pingTimeout: 20000,
    maxHttpBufferSize: 1e6,
  });

  // ── Redis adapter (for scaling across multiple servers) ──
  if (process.env.REDIS_URL) {
    const pubClient = createClient({ url: process.env.REDIS_URL });
    const subClient = pubClient.duplicate();
    Promise.all([pubClient.connect(), subClient.connect()]).then(() => {
      io.adapter(createAdapter(pubClient, subClient));
    });
  }

  // ── Authentication middleware ──
  io.use((socket, next) => {
    const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.split(' ')[1];
    if (!token) return next(new Error('Authentication required'));

    try {
      const payload = verifyAccessToken(token);
      socket.data.user = { id: payload.sub, email: payload.email, role: payload.role };
      next();
    } catch {
      next(new Error('Invalid token'));
    }
  });

  // ── Connection handler ──
  io.on('connection', (socket) => {
    const userId = socket.data.user.id;
    console.log(`Connected: ${userId} (${socket.id})`);

    // Join user's personal room
    socket.join(`user:${userId}`);

    // ── Chat ──
    socket.on('chat:join', (roomId: string) => {
      socket.join(`chat:${roomId}`);
      socket.to(`chat:${roomId}`).emit('chat:user-joined', {
        userId, timestamp: Date.now(),
      });
    });

    socket.on('chat:message', async (data: { roomId: string; content: string }) => {
      const message = {
        id: crypto.randomUUID(),
        userId,
        content: data.content,
        roomId: data.roomId,
        timestamp: Date.now(),
      };

      // Save to DB
      await db.message.create({ data: message });

      // Broadcast to room
      io.to(`chat:${data.roomId}`).emit('chat:message', message);
    });

    socket.on('chat:typing', (roomId: string) => {
      socket.to(`chat:${roomId}`).emit('chat:typing', { userId });
    });

    socket.on('chat:leave', (roomId: string) => {
      socket.leave(`chat:${roomId}`);
      socket.to(`chat:${roomId}`).emit('chat:user-left', { userId });
    });

    // ── Presence ──
    socket.on('disconnect', () => {
      console.log(`Disconnected: ${userId}`);
      io.emit('presence:offline', { userId, timestamp: Date.now() });
    });
  });

  return io;
}

// ── Emit from anywhere (e.g., from API routes) ──
export function emitToUser(io: Server, userId: string, event: string, data: any) {
  io.to(`user:${userId}`).emit(event, data);
}

export function emitToRoom(io: Server, room: string, event: string, data: any) {
  io.to(room).emit(event, data);
}
```

---

## Client Setup

```typescript
// src/lib/socket.ts
import { io, Socket } from 'socket.io-client';

let socket: Socket | null = null;

export function getSocket(): Socket {
  if (!socket) {
    socket = io(process.env.NEXT_PUBLIC_WS_URL || 'http://localhost:3000', {
      auth: { token: localStorage.getItem('accessToken') },
      autoConnect: false,
      reconnection: true,
      reconnectionAttempts: 10,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 10000,
      timeout: 20000,
    });

    socket.on('connect', () => console.log('WS connected'));
    socket.on('disconnect', (reason) => console.log('WS disconnected:', reason));
    socket.on('connect_error', (err) => {
      console.error('WS error:', err.message);
      if (err.message === 'Invalid token') {
        // Handle token refresh
      }
    });
  }
  return socket;
}

export function connectSocket() { getSocket().connect(); }
export function disconnectSocket() { socket?.disconnect(); socket = null; }
```

---

## React Hooks

```typescript
// src/hooks/useSocket.ts
import { useEffect, useRef, useCallback } from 'react';
import { getSocket, connectSocket, disconnectSocket } from '@/lib/socket';

export function useSocket() {
  const socketRef = useRef(getSocket());

  useEffect(() => {
    connectSocket();
    return () => { disconnectSocket(); };
  }, []);

  const on = useCallback((event: string, handler: (...args: any[]) => void) => {
    socketRef.current.on(event, handler);
    return () => { socketRef.current.off(event, handler); };
  }, []);

  const emit = useCallback((event: string, data?: any) => {
    socketRef.current.emit(event, data);
  }, []);

  return { socket: socketRef.current, on, emit };
}

// src/hooks/useChat.ts
export function useChat(roomId: string) {
  const { on, emit } = useSocket();
  const [messages, setMessages] = useState<Message[]>([]);
  const [typingUsers, setTypingUsers] = useState<string[]>([]);

  useEffect(() => {
    emit('chat:join', roomId);

    const unsub1 = on('chat:message', (msg: Message) => {
      setMessages(prev => [...prev, msg]);
    });

    const unsub2 = on('chat:typing', ({ userId }: { userId: string }) => {
      setTypingUsers(prev => [...new Set([...prev, userId])]);
      setTimeout(() => {
        setTypingUsers(prev => prev.filter(id => id !== userId));
      }, 3000);
    });

    return () => {
      emit('chat:leave', roomId);
      unsub1(); unsub2();
    };
  }, [roomId]);

  const sendMessage = (content: string) => emit('chat:message', { roomId, content });
  const sendTyping = () => emit('chat:typing', roomId);

  return { messages, typingUsers, sendMessage, sendTyping };
}

// src/hooks/useNotifications.ts
export function useNotifications() {
  const { on } = useSocket();
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);

  useEffect(() => {
    const unsub = on('notification', (notif: Notification) => {
      setNotifications(prev => [notif, ...prev]);
      setUnreadCount(prev => prev + 1);
    });
    return unsub;
  }, []);

  const markRead = () => setUnreadCount(0);

  return { notifications, unreadCount, markRead };
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Authentication** | Verify JWT in handshake middleware |
| **Rooms** | Use rooms for scoped broadcasting (chat, user) |
| **Redis adapter** | Scale across multiple server instances |
| **Reconnection** | Auto-reconnect with exponential backoff |
| **Presence** | Track online/offline via connect/disconnect events |
| **Typing** | Debounce typing indicators, auto-expire after 3s |
| **Error handling** | Handle `connect_error` for auth failures |
| **Emitting externally** | Helper functions to emit from API routes |
| **Cleanup** | Unsubscribe on component unmount |
| **Buffer size** | Set `maxHttpBufferSize` to prevent abuse |

---

## Rules Integration
- **Server**: Socket.IO with auth middleware, rooms, namespaces
- **Client**: Singleton socket with auto-reconnection
- **React**: Custom hooks (useSocket, useChat, useNotifications)
- **Scaling**: Redis adapter for multi-server deployment
- **Patterns**: Chat, typing indicators, presence, notifications
