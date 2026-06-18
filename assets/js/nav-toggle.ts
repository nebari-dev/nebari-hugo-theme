// Mobile nav toggle. Wires the hamburger button to slide the sidebar in/out.
// The sidebar becomes off-canvas below 768px (CSS: transform: translateX(-100%)).
// Adding .sidebar--open translates it to 0. A backdrop closes it on click.
//
// While open we also: lock background scroll (body.nav-open), trap Tab focus
// inside the drawer, close on Escape, and close when a drawer link is followed.

document.addEventListener('DOMContentLoaded', () => {
  const toggle = document.getElementById('nav-toggle') as HTMLButtonElement | null;
  const sidebar = document.querySelector('.sidebar') as HTMLElement | null;
  if (!toggle || !sidebar) return;

  // Create backdrop element
  const backdrop = document.createElement('div');
  backdrop.className = 'nav-backdrop';
  backdrop.setAttribute('aria-hidden', 'true');
  document.body.appendChild(backdrop);

  function focusable(): HTMLElement[] {
    return Array.from(
      sidebar!.querySelectorAll<HTMLElement>('a[href], button:not([disabled])'),
    ).filter((el) => el.offsetParent !== null);
  }

  function openSidebar(): void {
    sidebar!.classList.add('sidebar--open');
    backdrop.classList.add('nav-backdrop--visible');
    document.body.classList.add('nav-open');
    toggle!.setAttribute('aria-expanded', 'true');
    focusable()[0]?.focus();
  }

  function closeSidebar(): void {
    sidebar!.classList.remove('sidebar--open');
    backdrop.classList.remove('nav-backdrop--visible');
    document.body.classList.remove('nav-open');
    toggle!.setAttribute('aria-expanded', 'false');
  }

  function isOpen(): boolean {
    return sidebar!.classList.contains('sidebar--open');
  }

  toggle.addEventListener('click', () => {
    if (isOpen()) {
      closeSidebar();
    } else {
      openSidebar();
    }
  });

  // Close on backdrop click
  backdrop.addEventListener('click', closeSidebar);

  // Close when a drawer link is followed (covers in-page anchors that don't
  // trigger a full reload).
  sidebar.addEventListener('click', (e: MouseEvent) => {
    if (isOpen() && (e.target as HTMLElement).closest('a[href]')) {
      closeSidebar();
    }
  });

  document.addEventListener('keydown', (e: KeyboardEvent) => {
    if (!isOpen()) return;

    // Close on Escape, return focus to the toggle.
    if (e.key === 'Escape') {
      closeSidebar();
      toggle.focus();
      return;
    }

    // Trap Tab focus within the drawer.
    if (e.key === 'Tab') {
      const items = focusable();
      if (items.length === 0) return;
      const first = items[0];
      const last = items[items.length - 1];
      const active = document.activeElement;
      if (e.shiftKey && active === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && active === last) {
        e.preventDefault();
        first.focus();
      }
    }
  });
});

export {};
