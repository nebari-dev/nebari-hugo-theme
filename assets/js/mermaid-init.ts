// Lazy-loads Mermaid only when the page contains at least one
// ```mermaid block. The Hugo Goldmark "highlight" output for an unknown
// language emits a `<pre><code class="language-mermaid">…</code></pre>`
// wrapper — we unwrap to a `<div class="mermaid">` Mermaid can render
// into, then call `mermaid.run()` once.

const MERMAID_CDN = 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';

interface MermaidAPI {
  initialize: (cfg: { startOnLoad: boolean; theme: string; securityLevel: string }) => void;
  run: () => Promise<void>;
}

function findMermaidBlocks(): HTMLPreElement[] {
  return Array.from(document.querySelectorAll<HTMLPreElement>('pre > code.language-mermaid'))
    .map((c) => c.parentElement)
    .filter((p): p is HTMLPreElement => p instanceof HTMLPreElement);
}

function unwrap(pre: HTMLPreElement): void {
  const code = pre.querySelector('code.language-mermaid');
  if (!code) return;
  const div = document.createElement('div');
  div.className = 'mermaid';
  div.textContent = code.textContent ?? '';
  pre.replaceWith(div);
}

document.addEventListener('DOMContentLoaded', async () => {
  const blocks = findMermaidBlocks();
  if (blocks.length === 0) return;
  blocks.forEach(unwrap);
  try {
    const mod = (await import(/* @vite-ignore */ MERMAID_CDN)) as { default: MermaidAPI };
    const mermaid = mod.default;
    const isDark = document.documentElement.classList.contains('dark');
    mermaid.initialize({
      startOnLoad: false,
      theme: isDark ? 'dark' : 'default',
      securityLevel: 'strict',
    });
    await mermaid.run();
  } catch (err) {
    console.error('[mermaid]', err);
  }
});

export {};
