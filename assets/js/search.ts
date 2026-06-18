// Client-side Fuse.js search. Loads /index.json (emitted by Hugo's JSON
// output for the home page via layouts/_default/index.json), builds a
// Fuse index on first interaction, and renders results into a dropdown.
//
// The consuming site MUST enable JSON output for the home page in its
// hugo.toml — `outputs.home = ["HTML", "RSS", "JSON"]` — otherwise the
// fetch will 404 and the input renders disabled.

import Fuse from '../vendor/fuse.basic.min.mjs';

interface IndexedPage {
  title: string;
  url: string;
  section: string;
  summary: string;
  content: string;
}

interface SearchUI {
  input: HTMLInputElement;
  drawer: HTMLElement;
  list: HTMLElement;
  empty: HTMLElement;
}

const STATE = {
  fuse: null as Fuse<IndexedPage> | null,
  loading: null as Promise<Fuse<IndexedPage>> | null,
};

async function loadIndex(indexURL: string): Promise<Fuse<IndexedPage>> {
  if (STATE.fuse) return STATE.fuse;
  if (STATE.loading) return STATE.loading;
  STATE.loading = (async () => {
    const res = await fetch(indexURL);
    if (!res.ok) throw new Error(`search index fetch failed: ${res.status}`);
    const pages = (await res.json()) as IndexedPage[];
    const fuse = new Fuse(pages, {
      keys: [
        { name: 'title', weight: 0.6 },
        { name: 'summary', weight: 0.25 },
        { name: 'content', weight: 0.15 },
      ],
      threshold: 0.4,
      ignoreLocation: true,
      includeScore: true,
      minMatchCharLength: 2,
    });
    STATE.fuse = fuse;
    return fuse;
  })();
  return STATE.loading;
}

function escapeHTML(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function snippet(text: string, query: string, maxLen = 140): string {
  if (!text) return '';
  const lower = text.toLowerCase();
  const q = query.toLowerCase().trim();
  const idx = q ? lower.indexOf(q) : -1;
  if (idx < 0) {
    return escapeHTML(text.slice(0, maxLen)) + (text.length > maxLen ? '…' : '');
  }
  const start = Math.max(0, idx - 40);
  const end = Math.min(text.length, idx + q.length + maxLen - (idx - start));
  const head = start > 0 ? '…' : '';
  const tail = end < text.length ? '…' : '';
  const chunk = text.slice(start, end);
  const matchStart = idx - start;
  const before = escapeHTML(chunk.slice(0, matchStart));
  const match = escapeHTML(chunk.slice(matchStart, matchStart + q.length));
  const after = escapeHTML(chunk.slice(matchStart + q.length));
  return `${head}${before}<mark>${match}</mark>${after}${tail}`;
}

function renderResults(ui: SearchUI, query: string, results: Array<{ item: IndexedPage }>): void {
  ui.list.innerHTML = '';
  if (results.length === 0) {
    ui.empty.hidden = false;
    return;
  }
  ui.empty.hidden = true;
  for (const { item } of results.slice(0, 12)) {
    const li = document.createElement('li');
    const text = snippet(item.summary || item.content || '', query);
    li.innerHTML = `
      <a class="search__result" href="${escapeHTML(item.url)}">
        <div class="search__result-title">${escapeHTML(item.title)}</div>
        ${item.section ? `<div class="search__result-section">${escapeHTML(item.section)}</div>` : ''}
        <div class="search__result-snippet">${text}</div>
      </a>
    `;
    ui.list.appendChild(li);
  }
}

function wire(ui: SearchUI, indexURL: string): void {
  let lastQuery = '';
  const onInput = async () => {
    const q = ui.input.value.trim();
    if (q === lastQuery) return;
    lastQuery = q;
    if (q.length < 2) {
      ui.drawer.hidden = true;
      ui.list.innerHTML = '';
      ui.empty.hidden = true;
      return;
    }
    try {
      const fuse = await loadIndex(indexURL);
      const results = fuse.search(q);
      ui.drawer.hidden = false;
      renderResults(ui, q, results);
    } catch (err) {
      console.error('[search]', err);
      ui.drawer.hidden = false;
      ui.list.innerHTML = '';
      ui.empty.hidden = false;
      ui.empty.textContent = 'Search index unavailable.';
    }
  };
  ui.input.addEventListener('input', onInput);
  ui.input.addEventListener('focus', onInput);
  document.addEventListener('click', (ev) => {
    const target = ev.target as Node;
    if (!ui.drawer.contains(target) && target !== ui.input) {
      ui.drawer.hidden = true;
    }
  });
  ui.input.addEventListener('keydown', (ev) => {
    if (ev.key === 'Escape') {
      ui.drawer.hidden = true;
      ui.input.blur();
    }
  });
}

document.addEventListener('DOMContentLoaded', () => {
  const input = document.getElementById('search-input') as HTMLInputElement | null;
  const drawer = document.getElementById('search-drawer');
  const list = document.getElementById('search-results');
  const empty = document.getElementById('search-empty');
  if (!input || !drawer || !list || !empty) return;
  const indexURL = input.dataset.indexUrl ?? '/index.json';
  wire({ input, drawer, list, empty }, indexURL);
});

export {};
