// Theme toggle. Loaded after the FOUC-prevention script in <head>, so
// the initial class is already set when this runs.
document.addEventListener('DOMContentLoaded', () => {
  const btn = document.getElementById('theme-toggle');
  if (!btn) return;
  btn.addEventListener('click', () => {
    const next = document.documentElement.classList.toggle('dark') ? 'dark' : 'light';
    try { localStorage.setItem('theme', next); } catch {}
  });
});
