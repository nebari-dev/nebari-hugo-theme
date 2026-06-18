// Collapsible sidebar groups with persisted open/closed state.
// Each <details class="sidebar__group"> carries a data-key attribute;
// state is stored in localStorage as "nbt-nav:<key>" = "open" | "closed".

document.addEventListener('DOMContentLoaded', () => {
  const groups = document.querySelectorAll<HTMLDetailsElement>('details.sidebar__group');

  groups.forEach((group) => {
    const key = group.dataset.key;
    if (!key) return;

    const storageKey = `nbt-nav:${key}`;

    // Restore persisted state on load
    try {
      const saved = localStorage.getItem(storageKey);
      if (saved === 'closed') {
        group.removeAttribute('open');
      } else if (saved === 'open') {
        group.setAttribute('open', '');
      }
      // If nothing saved, leave the default 'open' attribute from HTML
    } catch {
      /* private-mode / storage disabled — ignore */
    }

    // Persist state on toggle
    group.addEventListener('toggle', () => {
      try {
        localStorage.setItem(storageKey, group.open ? 'open' : 'closed');
      } catch {
        /* private-mode / storage disabled — ignore */
      }
    });
  });
});

export {};
