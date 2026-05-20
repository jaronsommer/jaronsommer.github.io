  /* ── 1. Hamburger-Menü ─────────────────────────────
     Klick auf Burger togglet Klasse .open auf #navLinks.
     aria-expanded wird für Screenreader aktualisiert.
  ──────────────────────────────────────────────────── */
  const burger   = document.getElementById('burger');
  const navLinks = document.getElementById('navLinks');

  burger.addEventListener('click', () => {
    const isOpen = navLinks.classList.toggle('open');
    burger.setAttribute('aria-expanded', String(isOpen));
  });

  // Menü schliessen, sobald ein Link geklickt wird
  navLinks.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      navLinks.classList.remove('open');
      burger.setAttribute('aria-expanded', 'false');
    });
  });


  /* ── 2. Nav-Border beim Scrollen ───────────────────
     Fügt Klasse .scrolled hinzu sobald > 10px gescrollt.
  ──────────────────────────────────────────────────── */
  const nav = document.getElementById('nav');

  window.addEventListener('scroll', () => {
    nav.classList.toggle('scrolled', window.scrollY > 10);
  }, { passive: true });


  /* ── 3. Scroll-Reveal ──────────────────────────────
     IntersectionObserver beobachtet alle .reveal Elemente.
     Sobald sie im Viewport sichtbar sind, wird .visible
     hinzugefügt → CSS-Transition blendet sie ein.
  ──────────────────────────────────────────────────── */
  const revealObserver = new IntersectionObserver(
          (entries) => {
            entries.forEach(entry => {
              if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            // Einmal eingeblendet → nicht mehr beobachten
            revealObserver.unobserve(entry.target);
              }
            });
          },
          { threshold: 0.08 }  // 8% des Elements muss sichtbar sein
  );

  document.querySelectorAll('.reveal').forEach(el => {
    revealObserver.observe(el);
  });


  /* ── 4. Active Nav-Link Highlighting ───────────────
     Uses a scroll listener instead of IntersectionObserver.
     On every scroll event we find which section's top edge
     is closest to (but still above) the middle of the screen.
     That section is considered "active" and its nav link is
     highlighted. This is much more accurate than threshold-
     based observers, which tend to jump ahead on click.
  ──────────────────────────────────────────────────── */
  const sections    = document.querySelectorAll('section[id]');
  const allNavLinks = document.querySelectorAll('.nav-links a');

  function updateActiveNav() {
    // The trigger line: 40% down the viewport.
    // A section is "active" once its top has crossed this line.
    const triggerY = window.innerHeight * 0.4;

    let current = null;
    sections.forEach(section => {
      const top = section.getBoundingClientRect().top;
      if (top <= triggerY) {
        current = section.id;   // keep updating → last one wins = lowest visible section
      }
    });

    allNavLinks.forEach(a => {
      a.classList.toggle('active', a.getAttribute('href') === `#${current}`);
    });
  }

  // Run on scroll (passive = no performance impact)
  window.addEventListener('scroll', updateActiveNav, { passive: true });
  // Run once on load to set initial state
  updateActiveNav();


  /* ── 5. Abgelaufene "Bald"-Erkundungen entfernen ───
     Jede .exploration-card--upcoming hat ein data-end-date
     (YYYY-MM-DD). Ist dieses Datum vorbei, wird die Karte
     in eine normale (absolvierte) Karte umgewandelt:
     die Akzent-Klasse und das "Bald"-Badge werden entfernt.

     Danach: Anzahl der absolvierten Erkundungen zählen und
     im "Zielstrebig"-Eintrag automatisch einsetzen.
  ──────────────────────────────────────────────────── */
  (function () {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    document.querySelectorAll('.exploration-card--upcoming').forEach(card => {
      const endStr = card.dataset.endDate;
      if (!endStr) return;
      const endDate = new Date(endStr + 'T00:00:00');
      if (endDate < today) {
        card.classList.remove('exploration-card--upcoming');
        const badge = card.querySelector('.exploration-badge');
        if (badge) badge.remove();
      }
    });

    // Absolvierte Erkundungen nach Typ zählen.
    // Typ-Erkennung: 1. explizites data-type, 2. Stichwort im Titel.
    const counts = { zukunftstag: 0, infoanlass: 0, schnuppern: 0 };

    document.querySelectorAll(
      '.exploration-card:not(.exploration-card--upcoming)'
    ).forEach(card => {
      let type = card.dataset.type;
      if (!type) {
        const title = (card.querySelector('.exploration-title')?.textContent || '').toLowerCase();
        if (title.includes('zukunftstag'))    type = 'zukunftstag';
        else if (title.includes('infoanlass')) type = 'infoanlass';
        else if (title.includes('schnupper'))  type = 'schnuppern';
      }
      if (type && counts[type] !== undefined) counts[type]++;
    });

    // Singular/Plural-Labels pro Typ
    const label = {
      zukunftstag: n => n === 1 ? '1 Zukunftstag'  : `${n} Zukunftstage`,
      infoanlass:  n => n === 1 ? '1 Infoanlass'   : `${n} Infoanlässe`,
      schnuppern:  n => n === 1 ? '1 Schnuppertag' : `${n} Schnuppertage`,
    };
    const parts = Object.entries(counts)
      .filter(([, n]) => n > 0)
      .map(([type, n]) => label[type](n));

    const countEl = document.getElementById('strengthCount');
    if (countEl && parts.length > 0) {
      countEl.textContent = parts.join(' · ') + ' für die Berufswahl absolviert';
    }
  })();


  /* ── Copyright-Jahr automatisch setzen ─────────────
     Der Footer zeigt immer das aktuelle Jahr an.
  ──────────────────────────────────────────────────── */
  (function () {
    const yearEl = document.getElementById('footerYear');
    if (yearEl) {
      yearEl.textContent = String(new Date().getFullYear());
    }
  })();


  /* ── 6. Mailto-Link (Spam-Schutz) ──────────────────
     Die E-Mail-Adresse wird nicht im Klartext im HTML
     gespeichert, sondern hier per JS zusammengesetzt.
     Einfache Hürde gegen automatisierte Spam-Bots.
  ──────────────────────────────────────────────────── */
  (function () {
      // E-Mail in Teile aufgeteilt → wird per JS zusammengesetzt
    const parts   = ['jaron.sommer.ch', '@', 'icloud.com'];
    const email   = parts.join('');
    const subject = encodeURIComponent('Lehrstellenanfrage');
    const body    = encodeURIComponent(
            'Hallo Jaron\n\nIch bin auf dein Portfolio gestossen und würde mich gerne mit dir in Verbindung setzen.\n\nFreundliche Grüsse'
    );

    const btn = document.getElementById('mailBtn');
    if (btn) {
      btn.href = `mailto:${email}?subject=${subject}&body=${body}`;
    }
  })();


  /* ── 7. PDF-Speichern-Button ───────────────────────
     Öffnet den Browser-Druckdialog; im Dialog wählt
     der Nutzer „Als PDF speichern". Das Print-Stylesheet
     (styles.css @media print) sorgt für den Lebenslauf-
     Look ohne Navigation, Hover-Effekte etc.
  ──────────────────────────────────────────────────── */
  (function () {
    const btn = document.getElementById('pdfBtn');
    if (btn) {
      btn.addEventListener('click', () => window.print());
    }
  })();
