// Scroll-spy for the right-hand table of contents. Uses IntersectionObserver
// to add/remove .is-active on the matching anchor as heading sections enter
// the viewport. Robust to both scroll directions: tracks a Set of currently-
// intersecting headings and picks the topmost one; falls back to the last
// heading above the viewport top when nothing is intersecting.
// Only runs when #TableOfContents is present in the DOM.

document.addEventListener('DOMContentLoaded', () => {
  const nav = document.getElementById('TableOfContents');
  if (!nav) return;

  const links = Array.from(
    nav.querySelectorAll<HTMLAnchorElement>('a[href^="#"]'),
  );
  if (links.length === 0) return;

  const headingIds = links.map((a) => a.getAttribute('href')!.slice(1));
  const headings = headingIds
    .map((id) => document.getElementById(id))
    .filter((el): el is HTMLElement => el !== null);

  let activeLink: HTMLAnchorElement | null = null;
  const intersecting = new Set<HTMLElement>();

  function setActive(link: HTMLAnchorElement | null): void {
    if (activeLink === link) return;
    if (activeLink) activeLink.classList.remove('is-active');
    activeLink = link;
    if (activeLink) activeLink.classList.add('is-active');
  }

  function pickActive(): void {
    if (intersecting.size > 0) {
      // Among currently-intersecting headings, pick the one closest to the
      // top of the viewport (smallest positive or least-negative boundingRect top).
      let best: HTMLElement | null = null;
      let bestTop = Infinity;
      for (const el of intersecting) {
        const top = el.getBoundingClientRect().top;
        if (top < bestTop) {
          bestTop = top;
          best = el;
        }
      }
      if (best) {
        const idx = headings.indexOf(best);
        setActive(idx !== -1 ? (links[idx] ?? null) : null);
      }
    } else {
      // Nothing intersecting - find the last heading whose top is above the
      // viewport top (i.e. the section we have scrolled past most recently).
      let best: HTMLElement | null = null;
      for (const el of headings) {
        if (el.getBoundingClientRect().top <= 0) {
          best = el;
        }
      }
      if (best) {
        const idx = headings.indexOf(best);
        setActive(idx !== -1 ? (links[idx] ?? null) : null);
      }
    }
  }

  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        const el = entry.target as HTMLElement;
        if (entry.isIntersecting) {
          intersecting.add(el);
        } else {
          intersecting.delete(el);
        }
      }
      pickActive();
    },
    { rootMargin: '0px 0px -70% 0px' },
  );

  for (const heading of headings) {
    observer.observe(heading);
  }
});

export {};
