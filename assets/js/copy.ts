// Inject a "Copy" button into every <pre> Hugo emits for fenced code
// blocks. The button uses the Clipboard API and falls back to nothing
// (the button still appears but disables itself) if it's unavailable.
//
// Hugo wraps highlighted blocks in `<div class="highlight"><pre>…</pre></div>`
// — we hook the .highlight wrapper and absolutely-position the button.

type ButtonState = 'idle' | 'copied' | 'failed';

function setState(btn: HTMLButtonElement, state: ButtonState): void {
  btn.dataset.state = state;
  btn.textContent =
    state === 'copied' ? 'Copied' : state === 'failed' ? 'Failed' : 'Copy';
}

function attach(highlight: HTMLElement): void {
  if (highlight.querySelector('.copy-btn')) return;
  const pre = highlight.querySelector('pre');
  if (!pre) return;

  const btn = document.createElement('button');
  btn.type = 'button';
  btn.className = 'copy-btn';
  btn.setAttribute('aria-label', 'Copy code to clipboard');
  setState(btn, 'idle');
  highlight.appendChild(btn);

  btn.addEventListener('click', async () => {
    const text = pre.innerText;
    try {
      await navigator.clipboard.writeText(text);
      setState(btn, 'copied');
    } catch {
      setState(btn, 'failed');
    }
    setTimeout(() => setState(btn, 'idle'), 1500);
  });
}

document.addEventListener('DOMContentLoaded', () => {
  if (!('clipboard' in navigator)) return;
  document.querySelectorAll<HTMLElement>('.highlight').forEach(attach);
});

export {};
