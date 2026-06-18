// Scroll-spy for the right-hand table of contents. Uses IntersectionObserver
// to add/remove .is-active on the matching anchor as heading sections enter
// the viewport. Only runs when #TableOfContents is present in the DOM.

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

  function setActive(link: HTMLAnchorElement | null): void {
    if (activeLink === link) return;
    if (activeLink) activeLink.classList.remove('is-active');
    activeLink = link;
    if (activeLink) activeLink.classList.add('is-active');
  }

  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) {
          const idx = headings.indexOf(entry.target as HTMLElement);
          if (idx !== -1) {
            setActive(links[idx] ?? null);
          }
        }
      }
    },
    { rootMargin: '0px 0px -70% 0px' },
  );

  for (const heading of headings) {
    observer.observe(heading);
  }
});

export {};
