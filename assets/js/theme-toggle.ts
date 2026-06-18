// Theme toggle. Loaded after the FOUC-prevention script in <head>, which
// already set the initial class. This module just wires the click handler.

type Theme = 'light' | 'dark';

function applyTheme(next: Theme): void {
  const root = document.documentElement;
  if (next === 'dark') root.classList.add('dark');
  else root.classList.remove('dark');
  try {
    localStorage.setItem('theme', next);
  } catch {
    /* private-mode / storage disabled — ignore */
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const btn = document.getElementById('theme-toggle');
  if (!btn) return;
  btn.addEventListener('click', () => {
    const next: Theme = document.documentElement.classList.contains('dark') ? 'light' : 'dark';
    applyTheme(next);
  });
});

export {};
