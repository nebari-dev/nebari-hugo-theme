// Mobile nav toggle. Wires the hamburger button to slide the sidebar in/out.
// The sidebar becomes off-canvas below 768px (CSS: transform: translateX(-100%)).
// Adding .sidebar--open translates it to 0. An optional backdrop closes it on click.

document.addEventListener('DOMContentLoaded', () => {
  const toggle = document.getElementById('nav-toggle') as HTMLButtonElement | null;
  const sidebar = document.querySelector('.sidebar') as HTMLElement | null;
  if (!toggle || !sidebar) return;

  // Create backdrop element
  const backdrop = document.createElement('div');
  backdrop.className = 'nav-backdrop';
  backdrop.setAttribute('aria-hidden', 'true');
  document.body.appendChild(backdrop);

  function openSidebar(): void {
    sidebar!.classList.add('sidebar--open');
    backdrop.classList.add('nav-backdrop--visible');
    toggle!.setAttribute('aria-expanded', 'true');
  }

  function closeSidebar(): void {
    sidebar!.classList.remove('sidebar--open');
    backdrop.classList.remove('nav-backdrop--visible');
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

  // Close on Escape key
  document.addEventListener('keydown', (e: KeyboardEvent) => {
    if (e.key === 'Escape' && isOpen()) {
      closeSidebar();
      toggle.focus();
    }
  });
});

export {};
