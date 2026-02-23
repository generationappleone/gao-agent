---
name: React Chessboard
description: Skill for building interactive chess UIs with react-chessboard — covering v5 options API, chess.js integration, AI game loops, position management, piece animations, custom styling, and common pitfalls (v4→v5 migration, dual-state sync, stale closures).
---

# React Chessboard Skill

## Overview
`react-chessboard` is a React component for rendering interactive chess boards. It supports FEN positions, drag-and-drop pieces, custom styling, animations, arrows, spare pieces, and board orientation. Combined with `chess.js` for game logic, it provides a complete chess UI solution.

**Current Version**: v5.x (complete rewrite from v4)  
**Minimum React**: React 18+

**References**:
- [react-chessboard GitHub](https://github.com/Clariity/react-chessboard)
- [react-chessboard v5 Documentation](https://react-chessboard.vercel.app/)
- [chess.js Documentation](https://github.com/jhlywa/chess.js)
- [FEN Notation](https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation)

---

## ⚠️ CRITICAL: v4 → v5 Breaking Changes

**`react-chessboard` v5 is a COMPLETE REWRITE.** The API has fundamentally changed. All configuration is now passed through a single `options` prop instead of individual props.

### v4 → v5 Prop Migration Table

| v4 (deprecated) | v5 (current) | Notes |
|---|---|---|
| `<Chessboard position={fen} />` | `<Chessboard options={{ position: fen }} />` | **All props must be inside `options`** |
| `arePiecesDraggable={false}` | `options={{ allowDragging: false }}` | Renamed |
| `animationDuration={500}` | `options={{ animationDurationInMs: 500 }}` | Renamed, unit explicit |
| `customSquareStyles={{...}}` | `options={{ squareStyles: {...} }}` | Renamed |
| `customDarkSquareStyle={{...}}` | `options={{ darkSquareStyle: {...} }}` | Renamed |
| `customLightSquareStyle={{...}}` | `options={{ lightSquareStyle: {...} }}` | Renamed |
| `boardOrientation="black"` | `options={{ boardOrientation: 'black' }}` | Same name, inside options |
| `id="board-1"` | `options={{ id: 'board-1' }}` | Inside options |
| `boardWidth={500}` | CSS container width | v5 uses container-based sizing |
| `onPieceDrop={(s,t,p) => ...}` | `options={{ onPieceDrop: ({piece, sourceSquare, targetSquare}) => ... }}` | Handler args changed to object destructuring |
| `onSquareClick={(sq) => ...}` | `options={{ onSquareClick: ({piece, square}) => ... }}` | Handler args changed |

### ❌ Silent Failure Mode — The Most Dangerous Bug

If you use v4 API syntax with v5, **there is NO error** — the props are simply ignored and the board shows the default starting position, never updating:

```tsx
// ❌ WRONG — v4 API with v5 package. Silently fails. Board never updates!
const ChessboardComponent = Chessboard as any; // casting hides type errors
<ChessboardComponent
  position={fen}                    // IGNORED by v5
  arePiecesDraggable={false}        // IGNORED by v5
  customDarkSquareStyle={{...}}     // IGNORED by v5
/>

// ✅ CORRECT — v5 API
<Chessboard
  options={{
    position: fen,
    allowDragging: false,
    darkSquareStyle: { backgroundColor: '#779556' },
  }}
/>
```

> **RULE: NEVER cast `Chessboard` as `any`.** This hides TypeScript errors that would catch API mismatches. Always use the typed component directly.

---

## Installation

```bash
npm install react-chessboard chess.js
```

### Package Versions (Tested Compatibility)

| Package | Version | Notes |
|---|---|---|
| `react-chessboard` | `^5.10.0` | v5 options API |
| `chess.js` | `^1.4.0` | Game logic, move validation |
| `react` | `^18.0.0` or `^19.0.0` | Required peer dependency |

---

## Basic Usage (v5 API)

### Display-Only Board (AI vs AI, Spectator)

```tsx
import { Chessboard } from 'react-chessboard';

function SpectatorBoard({ fen }: { fen: string }) {
  return (
    <div style={{ width: '500px' }}>
      <Chessboard
        options={{
          position: fen,
          allowDragging: false,
          showAnimations: true,
          animationDurationInMs: 500,
          darkSquareStyle: { backgroundColor: '#779556' },
          lightSquareStyle: { backgroundColor: '#ebecd0' },
        }}
      />
    </div>
  );
}
```

### Interactive Board (Human vs AI)

```tsx
import { useState } from 'react';
import { Chessboard } from 'react-chessboard';
import { Chess } from 'chess.js';

function PlayableBoard() {
  const [game, setGame] = useState(new Chess());

  function onPieceDrop({ sourceSquare, targetSquare }: {
    piece: { isSparePiece: boolean; position: string; pieceType: string };
    sourceSquare: string;
    targetSquare: string | null;
  }): boolean {
    if (!targetSquare) return false;

    const gameCopy = new Chess(game.fen());
    const move = gameCopy.move({
      from: sourceSquare,
      to: targetSquare,
      promotion: 'q', // Always promote to queen for simplicity
    });

    if (!move) return false; // Illegal move

    setGame(gameCopy);
    return true;
  }

  return (
    <div style={{ width: '500px' }}>
      <Chessboard
        options={{
          position: game.fen(),
          onPieceDrop: onPieceDrop,
          allowDragging: true,
          showAnimations: true,
          animationDurationInMs: 300,
          darkSquareStyle: { backgroundColor: '#779556' },
          lightSquareStyle: { backgroundColor: '#ebecd0' },
        }}
      />
    </div>
  );
}
```

---

## Complete ChessboardOptions Reference (v5)

```typescript
import type { ChessboardOptions } from 'react-chessboard';

const options: ChessboardOptions = {
  // === Identity ===
  id: 'my-board',                        // Unique board identifier

  // === Position ===
  position: 'start',                     // FEN string, 'start', or PositionDataType object
  boardOrientation: 'white',             // 'white' | 'black'

  // === Grid (for non-standard boards) ===
  chessboardRows: 8,                     // Number of rows (default: 8)
  chessboardColumns: 8,                  // Number of columns (default: 8)

  // === Interactivity ===
  allowDragging: true,                   // Enable/disable piece dragging
  allowDragOffBoard: false,              // Allow pieces to be dragged off the board
  allowAutoScroll: true,                 // Auto-scroll when dragging near edges
  dragActivationDistance: 3,             // Pixels before drag activates

  // === Animation ===
  showAnimations: true,                  // Enable/disable piece animations
  animationDurationInMs: 300,            // Animation duration in milliseconds

  // === Notation ===
  showNotation: true,                    // Show rank/file labels

  // === Styling ===
  boardStyle: {},                        // React.CSSProperties for the board container
  squareStyle: {},                       // Default style for all squares
  squareStyles: {},                      // Record<string, CSSProperties> per-square overrides
  darkSquareStyle: { backgroundColor: '#779556' },
  lightSquareStyle: { backgroundColor: '#ebecd0' },
  dropSquareStyle: { boxShadow: 'inset 0 0 1px 6px rgba(0,0,0,0.1)' },
  draggingPieceStyle: {},                // Style for piece being dragged
  draggingPieceGhostStyle: {},           // Style for ghost piece at original position

  // === Notation Styling ===
  darkSquareNotationStyle: {},
  lightSquareNotationStyle: {},
  alphaNotationStyle: {},                // Column labels (a-h)
  numericNotationStyle: {},              // Row labels (1-8)

  // === Arrows ===
  allowDrawingArrows: true,              // Enable arrow drawing (right-click + drag)
  arrows: [],                            // Pre-drawn arrows: [{ startSquare, endSquare, color }]
  arrowOptions: { /* ... */ },           // Arrow rendering options
  clearArrowsOnClick: true,              // Clear arrows when clicking
  clearArrowsOnPositionChange: true,     // Clear arrows when position changes

  // === Custom Pieces ===
  pieces: undefined,                     // PieceRenderObject for custom piece rendering

  // === Event Handlers ===
  canDragPiece: ({ isSparePiece, piece, square }) => true,
  onArrowsChange: ({ arrows }) => {},
  onMouseOutSquare: ({ piece, square }) => {},
  onMouseOverSquare: ({ piece, square }) => {},
  onPieceClick: ({ isSparePiece, piece, square }) => {},
  onPieceDrag: ({ isSparePiece, piece, square }) => {},
  onPieceDrop: ({ piece, sourceSquare, targetSquare }) => true, // Return false to reject
  onSquareClick: ({ piece, square }) => {},
  onSquareMouseDown: ({ piece, square }, e) => {},
  onSquareMouseUp: ({ piece, square }, e) => {},
  onSquareRightClick: ({ piece, square }) => {},

  // === Custom Rendering ===
  squareRenderer: undefined,             // Custom square render function
};
```

---

## Integration with chess.js

### Chess Engine Wrapper (Recommended Pattern)

```typescript
import { Chess, Move } from 'chess.js';

export class ChessEngine {
  private game: Chess;

  constructor(fen?: string) {
    this.game = new Chess(fen);
  }

  getGame(): Chess { return this.game; }

  makeMove(move: string | { from: string; to: string; promotion?: string }): Move | null {
    try {
      return this.game.move(move);
    } catch {
      return null;
    }
  }

  getLegalMoves(): Move[] {
    return this.game.moves({ verbose: true });
  }

  isGameOver(): boolean { return this.game.isGameOver(); }
  getTurn(): 'w' | 'b' { return this.game.turn(); }
  getFen(): string { return this.game.fen(); }
  reset(): void { this.game.reset(); }

  isCheck(): boolean { return this.game.isCheck(); }
  isCheckmate(): boolean { return this.game.isCheckmate(); }
  isDraw(): boolean { return this.game.isDraw(); }
  isStalemate(): boolean { return this.game.isStalemate(); }
  isThreefoldRepetition(): boolean { return this.game.isThreefoldRepetition(); }
  isInsufficientMaterial(): boolean { return this.game.isInsufficientMaterial(); }
}
```

---

## AI Game Loop (Automated Play)

### ⚠️ Common Pitfall: Dual-State Synchronization Bug

**NEVER** maintain two separate `Chess` instances (one in React state, one in a ref). They will get out of sync, causing the board to show wrong positions.

```tsx
// ❌ WRONG — Two Chess instances that desync
const [game, setGame] = useState(new Chess());    // State instance
const engineRef = useRef(new ChessEngine());       // Ref instance
// ...
setGame(new Chess(engineRef.current.getFen()));    // Creates yet another instance!

// ✅ CORRECT — Single source of truth
const engineRef = useRef(new ChessEngine());       // ONLY instance
const [fen, setFen] = useState('start');           // Derived string for UI
// ...
setFen(engineRef.current.getFen());                // Just reads the string
```

### ⚠️ Common Pitfall: Stale Closures in setTimeout

When using `setTimeout` for delayed moves, function closures capture the props/state at the time they were created. Use refs to access the latest values.

```tsx
// ❌ WRONG — Stale closure: white/black could change between timeout scheduling and execution
const makeMove = () => {
  const agent = turn === 'w' ? white : black;  // 'white' is stale from initial render
  // ...
};
setTimeout(makeMove, 3000);

// ✅ CORRECT — Always-fresh values via refs
const whiteRef = useRef(white);
const blackRef = useRef(black);
whiteRef.current = white;  // Update on every render
blackRef.current = black;

const makeMove = () => {
  const agent = turn === 'w' ? whiteRef.current : blackRef.current;  // Always fresh
  // ...
};
setTimeout(makeMove, 3000);
```

### Complete AI vs AI Component (Production Pattern)

```tsx
import React, { useEffect, useState, useRef } from 'react';
import { Chessboard } from 'react-chessboard';
import { Chess } from 'chess.js';

interface Agent {
  id: string;
  name: string;
  style: string;
}

interface AIMatchProps {
  white: Agent;
  black: Agent;
  onGameEnd: (result: { winnerId: string | null; reason: string }) => void;
  moveDelayMs?: { min: number; max: number };
}

export function AIMatch({ white, black, onGameEnd, moveDelayMs = { min: 3000, max: 10000 } }: AIMatchProps) {
  // === Refs: mutable state that doesn't trigger re-renders ===
  const engineRef = useRef(new ChessEngine());
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const isActiveRef = useRef(true);
  const gameOverHandledRef = useRef(false);

  // Latest props via refs (avoid stale closures)
  const whiteRef = useRef(white);
  const blackRef = useRef(black);
  const onGameEndRef = useRef(onGameEnd);
  whiteRef.current = white;
  blackRef.current = black;
  onGameEndRef.current = onGameEnd;

  // === React state: ONLY for UI rendering, derived from engine ===
  const [fen, setFen] = useState('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
  const [currentTurn, setCurrentTurn] = useState<'w' | 'b'>('w');
  const [moveHistory, setMoveHistory] = useState<string[]>([]);
  const [lastMoveSquares, setLastMoveSquares] = useState<Record<string, React.CSSProperties>>({});

  // Reset game when players change
  useEffect(() => {
    if (timerRef.current) clearTimeout(timerRef.current);

    isActiveRef.current = true;
    gameOverHandledRef.current = false;
    engineRef.current = new ChessEngine();

    setFen(engineRef.current.getFen());
    setCurrentTurn('w');
    setMoveHistory([]);
    setLastMoveSquares({});

    scheduleMove();

    return () => {
      isActiveRef.current = false;
      if (timerRef.current) clearTimeout(timerRef.current);
    };
  }, [white.id, black.id]);

  function scheduleMove() {
    if (!isActiveRef.current || gameOverHandledRef.current) return;
    const delay = Math.floor(Math.random() * (moveDelayMs.max - moveDelayMs.min)) + moveDelayMs.min;
    timerRef.current = setTimeout(executeMove, delay);
  }

  function executeMove() {
    if (!isActiveRef.current || gameOverHandledRef.current) return;

    const engine = engineRef.current;
    const game = engine.getGame();

    if (game.isGameOver() || game.isDraw()) {
      endGame(game);
      return;
    }

    const moves = engine.getLegalMoves();
    if (moves.length === 0) {
      endGame(game);
      return;
    }

    // Simple AI: pick a random legal move
    const selectedMove = moves[Math.floor(Math.random() * moves.length)];
    const result = engine.makeMove(selectedMove.san);

    if (!result) {
      endGame(game);
      return;
    }

    // Update UI from single source of truth
    setFen(engine.getFen());
    setCurrentTurn(engine.getTurn());
    setMoveHistory(prev => [...prev, result.san]);
    setLastMoveSquares({
      [result.from]: { backgroundColor: 'rgba(255, 255, 0, 0.4)' },
      [result.to]: { backgroundColor: 'rgba(255, 255, 0, 0.4)' },
    });

    if (engine.isGameOver()) {
      endGame(engine.getGame());
    } else {
      scheduleMove();
    }
  }

  function endGame(finalGame: Chess) {
    if (gameOverHandledRef.current) return;
    gameOverHandledRef.current = true;
    isActiveRef.current = false;
    if (timerRef.current) clearTimeout(timerRef.current);

    let winnerId: string | null = null;
    let reason = 'Draw';

    if (finalGame.isCheckmate()) {
      winnerId = finalGame.turn() === 'w' ? blackRef.current.id : whiteRef.current.id;
      reason = 'Checkmate';
    } else if (finalGame.isStalemate()) {
      reason = 'Stalemate';
    } else if (finalGame.isThreefoldRepetition()) {
      reason = 'Repetition';
    } else if (finalGame.isInsufficientMaterial()) {
      reason = 'Insufficient Material';
    }

    onGameEndRef.current({ winnerId, reason });
  }

  return (
    <div style={{ width: '500px' }}>
      <Chessboard
        options={{
          position: fen,
          allowDragging: false,
          showAnimations: true,
          animationDurationInMs: 500,
          squareStyles: lastMoveSquares,
          darkSquareStyle: { backgroundColor: '#779556' },
          lightSquareStyle: { backgroundColor: '#ebecd0' },
        }}
      />
      <div>
        <p>Turn: {currentTurn === 'w' ? 'White' : 'Black'}</p>
        <p>Moves: {moveHistory.join(', ')}</p>
      </div>
    </div>
  );
}
```

---

## Highlight Squares

### Last Move Highlight

```tsx
const [highlights, setHighlights] = useState<Record<string, React.CSSProperties>>({});

// After a move:
setHighlights({
  [move.from]: { backgroundColor: 'rgba(255, 255, 0, 0.4)' },
  [move.to]: { backgroundColor: 'rgba(255, 255, 0, 0.4)' },
});

<Chessboard
  options={{
    position: fen,
    squareStyles: highlights,
  }}
/>
```

### Legal Move Indicators

```tsx
function getLegalMoveStyles(game: Chess, square: string): Record<string, React.CSSProperties> {
  const moves = game.moves({ square, verbose: true });
  const styles: Record<string, React.CSSProperties> = {};

  // Highlight selected square
  styles[square] = { backgroundColor: 'rgba(255, 255, 0, 0.4)' };

  // Dot on legal target squares
  for (const move of moves) {
    styles[move.to] = {
      background: move.captured
        ? 'radial-gradient(circle, transparent 60%, rgba(0,0,0,0.2) 60%)'
        : 'radial-gradient(circle, rgba(0,0,0,0.2) 25%, transparent 25%)',
      borderRadius: '50%',
    };
  }

  return styles;
}
```

---

## Arrows

```tsx
import type { Arrow } from 'react-chessboard';

const [arrows, setArrows] = useState<Arrow[]>([
  { startSquare: 'e2', endSquare: 'e4', color: 'rgba(0, 128, 0, 0.6)' },
  { startSquare: 'd7', endSquare: 'd5', color: 'rgba(255, 0, 0, 0.6)' },
]);

<Chessboard
  options={{
    position: fen,
    arrows: arrows,
    allowDrawingArrows: true,
    onArrowsChange: ({ arrows: newArrows }) => setArrows(newArrows),
    clearArrowsOnClick: true,
    clearArrowsOnPositionChange: true,
  }}
/>
```

---

## Board Orientation (Flip Board)

```tsx
const [orientation, setOrientation] = useState<'white' | 'black'>('white');

<Chessboard
  options={{
    position: fen,
    boardOrientation: orientation,
  }}
/>

<button onClick={() => setOrientation(o => o === 'white' ? 'black' : 'white')}>
  Flip Board
</button>
```

---

## ChessboardProvider (Advanced — Spare Pieces)

For features like spare pieces or shared context across multiple components:

```tsx
import { Chessboard, ChessboardProvider, SparePiece } from 'react-chessboard';

function ChessWithSparePieces() {
  return (
    <ChessboardProvider
      options={{
        position: fen,
        allowDragging: true,
        onPieceDrop: handleDrop,
      }}
    >
      <div style={{ display: 'flex', gap: '16px' }}>
        <div>
          <SparePiece piece={{ pieceType: 'wQ' }} />
          <SparePiece piece={{ pieceType: 'wR' }} />
        </div>
        <Chessboard />
        <div>
          <SparePiece piece={{ pieceType: 'bQ' }} />
          <SparePiece piece={{ pieceType: 'bR' }} />
        </div>
      </div>
    </ChessboardProvider>
  );
}
```

> **Note:** When using `ChessboardProvider`, options go on the Provider, not on the `<Chessboard />` component itself.

---

## Custom Square Rendering

```tsx
import type { SquareRenderer } from 'react-chessboard';

const customSquareRenderer: SquareRenderer = ({ piece, square, children }) => {
  const isHighlighted = highlightedSquares.includes(square);

  return (
    <div style={{
      position: 'relative',
      width: '100%',
      height: '100%',
      outline: isHighlighted ? '3px solid red' : 'none',
    }}>
      {children}
      {piece && (
        <div style={{
          position: 'absolute',
          bottom: 2,
          right: 2,
          fontSize: '10px',
          color: 'rgba(0,0,0,0.3)',
        }}>
          {square}
        </div>
      )}
    </div>
  );
};

<Chessboard
  options={{
    position: fen,
    squareRenderer: customSquareRenderer,
  }}
/>
```

---

## Color Themes

### Lichess Theme
```tsx
darkSquareStyle: { backgroundColor: '#779556' },
lightSquareStyle: { backgroundColor: '#ebecd0' },
```

### Chess.com Theme
```tsx
darkSquareStyle: { backgroundColor: '#769656' },
lightSquareStyle: { backgroundColor: '#eeeed2' },
```

### Blue Theme
```tsx
darkSquareStyle: { backgroundColor: '#4f6d91' },
lightSquareStyle: { backgroundColor: '#dee3e6' },
```

### Brown Classic
```tsx
darkSquareStyle: { backgroundColor: '#b58863' },
lightSquareStyle: { backgroundColor: '#f0d9b5' },
```

---

## Game State Determination

When determining game-over conditions, check specific conditions **before** generic ones:

```typescript
// ✅ CORRECT — Specific conditions first
function getGameResult(game: Chess): { winnerId: string | null; reason: string } {
  if (game.isCheckmate()) {
    return {
      winnerId: game.turn() === 'w' ? blackId : whiteId, // Loser's turn
      reason: 'Checkmate',
    };
  }

  // Specific draw conditions before generic isDraw()
  if (game.isStalemate()) return { winnerId: null, reason: 'Stalemate' };
  if (game.isThreefoldRepetition()) return { winnerId: null, reason: 'Repetition' };
  if (game.isInsufficientMaterial()) return { winnerId: null, reason: 'Insufficient Material' };
  if (game.isDraw()) return { winnerId: null, reason: 'Draw' }; // 50-move rule, etc.

  return { winnerId: null, reason: 'Unknown' };
}

// ❌ WRONG — isDraw() checked first masks specific reasons
if (game.isDraw()) reason = 'Draw';           // This matches stalemate too!
else if (game.isStalemate()) reason = 'Stalemate';  // Never reached
```

---

## FEN Position Format

FEN (Forsyth-Edwards Notation) describes a board position as a string:

```
rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
│                                              │ │    │ │ │
│                                              │ │    │ │ └─ Fullmove number
│                                              │ │    │ └─── Halfmove clock (50-move rule)
│                                              │ │    └────── En passant target square
│                                              │ └──────────── Castling availability
│                                              └─────────────── Active color (w/b)
└──────────────────────────────────────────────────────────────── Piece placement (rank 8→1)
```

**Piece letters**: K=King, Q=Queen, R=Rook, B=Bishop, N=Knight, P=Pawn  
**Uppercase** = White, **lowercase** = black  
**Numbers** = consecutive empty squares

The `position` option accepts:
- Full FEN string: `'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1'`
- `'start'` keyword: Starting position
- Position object: `{ e1: { pieceType: 'wK' }, d1: { pieceType: 'wQ' }, ... }`

---

## Performance Tips

1. **Don't create new Chess instances on every render** — use refs for the engine
2. **Minimize squareStyles changes** — only update when highlights actually change
3. **Use `animationDurationInMs: 0`** for instant updates (rapid game review)
4. **Container sizing** — v5 uses the parent container width; avoid setting explicit board width
5. **Memoize options object** if it doesn't change every render:

```tsx
import { useMemo } from 'react';

const boardOptions = useMemo(() => ({
  position: fen,
  allowDragging: false,
  showAnimations: true,
  animationDurationInMs: 500,
  squareStyles: lastMoveSquares,
  darkSquareStyle: { backgroundColor: '#779556' },
  lightSquareStyle: { backgroundColor: '#ebecd0' },
}), [fen, lastMoveSquares]);

<Chessboard options={boardOptions} />
```

---

## Common Bugs & Solutions

### Bug: Board shows starting position but moves are logged
**Cause**: Using v4 props API with v5 package (props silently ignored).  
**Fix**: Wrap all props inside `options={{ ... }}`.

### Bug: Pieces teleport instead of animating
**Cause**: Two separate `Chess` instances getting out of sync, or FEN updates too fast.  
**Fix**: Use a single engine ref as source of truth. Ensure `showAnimations: true` and `animationDurationInMs > 0`.

### Bug: Game over called multiple times
**Cause**: `setTimeout` callback fires after component unmounts or between renders.  
**Fix**: Use `gameOverHandledRef` flag and `isActiveRef` guard. Clear timeouts on unmount.

### Bug: Wrong player wins (checkmate attribution)
**Cause**: `game.turn()` returns the turn of the player who is IN checkmate (the loser).  
**Fix**: `winnerId = game.turn() === 'w' ? blackId : whiteId;` — the OTHER player won.

### Bug: `clearInterval` on a `setTimeout` handle
**Cause**: Copy-paste error mixing `setInterval` and `setTimeout`.  
**Fix**: Always use `clearTimeout` for `setTimeout` handles, `clearInterval` for `setInterval`.

### Bug: TypeScript errors with Chessboard component
**Cause**: Casting as `any` to suppress type errors from wrong API usage.  
**Fix**: Never cast as `any`. Use the `Chessboard` component directly with `options` prop.

---

## Testing

### Unit Testing Chess Logic

```typescript
import { ChessEngine } from './chessEngine';

describe('ChessEngine', () => {
  it('should start with initial position', () => {
    const engine = new ChessEngine();
    expect(engine.getFen()).toBe('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
    expect(engine.getTurn()).toBe('w');
  });

  it('should make a valid move', () => {
    const engine = new ChessEngine();
    const result = engine.makeMove('e4');
    expect(result).not.toBeNull();
    expect(result?.san).toBe('e4');
    expect(engine.getTurn()).toBe('b');
  });

  it('should reject an invalid move', () => {
    const engine = new ChessEngine();
    const result = engine.makeMove('e5'); // Not white's move
    expect(result).toBeNull();
  });

  it('should detect checkmate', () => {
    // Scholar's mate
    const engine = new ChessEngine();
    engine.makeMove('e4');
    engine.makeMove('e5');
    engine.makeMove('Qh5');
    engine.makeMove('Nc6');
    engine.makeMove('Bc4');
    engine.makeMove('Nf6');
    engine.makeMove('Qxf7');

    expect(engine.isGameOver()).toBe(true);
    expect(engine.getGame().isCheckmate()).toBe(true);
    expect(engine.getTurn()).toBe('b'); // Black is in checkmate = White won
  });
});
```

---

## ELO Rating Calculation

```typescript
/**
 * Calculate new ELO rating after a game.
 * @param playerRating  Current player rating
 * @param opponentRating  Opponent's rating
 * @param score  1 = win, 0.5 = draw, 0 = loss
 * @param kFactor  Sensitivity (default: 32)
 */
export function calculateElo(
  playerRating: number,
  opponentRating: number,
  score: number,
  kFactor: number = 32
): number {
  const expectedScore = 1 / (1 + Math.pow(10, (opponentRating - playerRating) / 400));
  return Math.round(playerRating + kFactor * (score - expectedScore));
}
```

---

## Exports Summary

```typescript
// Main components
import { Chessboard } from 'react-chessboard';
import { ChessboardProvider, useChessboardContext } from 'react-chessboard';
import { SparePiece } from 'react-chessboard';

// Types
import type { ChessboardOptions } from 'react-chessboard';
import type { Arrow, SquareDataType, PieceDataType, PositionDataType } from 'react-chessboard';
import type { SquareHandlerArgs, PieceHandlerArgs, PieceDropHandlerArgs } from 'react-chessboard';
import type { SquareRenderer, PieceRenderObject, FenPieceString } from 'react-chessboard';

// Utilities
import { defaultPieces } from 'react-chessboard';
import { defaultDarkSquareStyle, defaultLightSquareStyle } from 'react-chessboard';
```
