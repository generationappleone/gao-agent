#!/usr/bin/env node

/**
 * GAO Agent — Context7 API Client (Cross-Platform)
 *
 * Search libraries and fetch up-to-date documentation from Context7.
 * Works on Windows, Linux, and macOS (requires Node.js 18+).
 *
 * Usage:
 *   node context7-api.mjs search <libraryName> [query]
 *   node context7-api.mjs docs <libraryId> <query>
 *
 * Examples:
 *   node context7-api.mjs search next.js "server actions"
 *   node context7-api.mjs docs /vercel/next.js "middleware authentication"
 *
 * API Key:
 *   Set CONTEXT7_API_KEY as environment variable or in .env file at project root.
 *   Get a free key at: https://context7.com/dashboard
 */

import { readFileSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const BASE_URL = 'https://context7.com/api/v2';

// ── Resolve API Key ──────────────────────────────────────────────
function getApiKey() {
    // 1. Environment variable
    if (process.env.CONTEXT7_API_KEY) {
        return process.env.CONTEXT7_API_KEY;
    }

    // 2. .env file in project root (3 levels up from .agent/scripts/)
    const projectRoot = join(__dirname, '..', '..');
    const envPaths = [
        join(projectRoot, '.env'),
        join(projectRoot, '.env.local'),
    ];

    for (const envPath of envPaths) {
        if (existsSync(envPath)) {
            const content = readFileSync(envPath, 'utf-8');
            const match = content.match(/^CONTEXT7_API_KEY\s*=\s*['"]?([^\s'"]+)['"]?/m);
            if (match) return match[1];
        }
    }

    return null;
}

// ── API Calls ────────────────────────────────────────────────────
async function searchLibrary(apiKey, libraryName, query = '') {
    const params = new URLSearchParams({ libraryName });
    if (query) params.append('query', query);

    const url = `${BASE_URL}/libs/search?${params}`;

    const res = await fetch(url, {
        headers: {
            'Authorization': `Bearer ${apiKey}`,
            'Accept': 'application/json',
        },
    });

    if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
    }

    const data = await res.json();

    if (data.results && data.results.length > 0) {
        console.log('\n=== Context7 Search Results ===\n');
        for (const r of data.results.slice(0, 5)) {
            console.log(`  ID:          ${r.id}`);
            console.log(`  Title:       ${r.title}`);
            console.log(`  Description: ${r.description || '-'}`);
            console.log(`  Stars:       ${r.stars}`);
            console.log(`  Trust Score: ${r.trustScore}`);
            if (r.versions && r.versions.length > 0) {
                console.log(`  Versions:    ${r.versions.slice(0, 5).join(', ')}`);
            }
            console.log('');
        }

        // Output first result ID for piping
        return data.results[0].id;
    } else {
        console.log(`No results found for "${libraryName}".`);
        return null;
    }
}

async function fetchDocs(apiKey, libraryId, query) {
    const params = new URLSearchParams({ libraryId, query, type: 'json' });
    const url = `${BASE_URL}/context?${params}`;

    const res = await fetch(url, {
        headers: {
            'Authorization': `Bearer ${apiKey}`,
            'Accept': 'application/json',
        },
    });

    if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
    }

    const data = await res.json();

    console.log('\n=== Context7 Documentation ===\n');

    // Code Snippets
    if (data.codeSnippets && data.codeSnippets.length > 0) {
        console.log('--- Code Snippets ---\n');
        for (const snippet of data.codeSnippets.slice(0, 5)) {
            console.log(`  Title:    ${snippet.codeTitle}`);
            console.log(`  Language: ${snippet.codeLanguage}`);
            console.log(`  Source:   ${snippet.pageTitle}`);
            if (snippet.codeList) {
                for (const code of snippet.codeList) {
                    console.log(`\n\`\`\`${code.language || ''}`);
                    console.log(code.code);
                    console.log('```\n');
                }
            }
        }
    }

    // Info Snippets
    if (data.infoSnippets && data.infoSnippets.length > 0) {
        console.log('--- Documentation ---\n');
        for (const info of data.infoSnippets.slice(0, 5)) {
            console.log(`  Path:    ${info.breadcrumb}`);
            console.log(`  Content: ${info.content?.substring(0, 500)}`);
            console.log('');
        }
    }

    return data;
}

// ── CLI ──────────────────────────────────────────────────────────
async function main() {
    const args = process.argv.slice(2);
    const action = args[0];

    if (!action || !['search', 'docs'].includes(action)) {
        console.log(`
GAO Agent — Context7 API Client

Usage:
  node context7-api.mjs search <libraryName> [query]
  node context7-api.mjs docs   <libraryId>   <query>

Examples:
  node context7-api.mjs search next.js "server actions"
  node context7-api.mjs docs /vercel/next.js "middleware authentication"

Environment:
  CONTEXT7_API_KEY  — API key from https://context7.com/dashboard
    `);
        process.exit(1);
    }

    const apiKey = getApiKey();
    if (!apiKey) {
        console.error('ERROR: CONTEXT7_API_KEY not found.');
        console.error('Set it via:');
        console.error('  1. Environment variable: export CONTEXT7_API_KEY=your_key');
        console.error('  2. .env file: CONTEXT7_API_KEY=your_key');
        console.error('  Get a free key at: https://context7.com/dashboard');
        process.exit(1);
    }

    try {
        if (action === 'search') {
            const libraryName = args[1];
            const query = args[2] || '';
            if (!libraryName) {
                console.error('ERROR: Library name is required. Example: node context7-api.mjs search react');
                process.exit(1);
            }
            const id = await searchLibrary(apiKey, libraryName, query);
            if (id) {
                // Output just the ID on last line for script piping
                console.log(`LIBRARY_ID=${id}`);
            }
        } else if (action === 'docs') {
            const libraryId = args[1];
            const query = args[2];
            if (!libraryId || !query) {
                console.error('ERROR: Both libraryId and query are required.');
                console.error('Example: node context7-api.mjs docs /vercel/next.js "server actions"');
                process.exit(1);
            }
            await fetchDocs(apiKey, libraryId, query);
        }
    } catch (err) {
        console.error(`ERROR: ${err.message}`);
        if (err.message.includes('401')) {
            console.error('Invalid API key. Get a new one at https://context7.com/dashboard');
        } else if (err.message.includes('429')) {
            console.error('Rate limit exceeded. Wait and retry, or upgrade your key.');
        }
        process.exit(1);
    }
}

main();
