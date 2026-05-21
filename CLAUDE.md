# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project context

Persönliche Portfolio-Webseite für die **Lehrstellensuche in der Schweiz** (Jaron Sommer bewirbt sich bei Lehrbetrieben). Live auf GitHub Pages: https://jaronsommer.github.io

Sämtlicher User-facing Content ist **deutsch (de-CH)** — neue Texte ebenfalls auf Deutsch verfassen. Tonalität: seriös, klar, lesbar (Lehrbetriebe als Zielgruppe).

## Build / Deploy

- **Kein Build-System, keine Dependencies, kein Test-Runner.** Reines HTML/CSS/JS.
- **Deploy = `git push origin main`** → GitHub Pages serviert die Seite nach ~1–2 min automatisch.
- **Lokal anschauen:** `start index.html` (Windows) oder Live Preview in IntelliJ. Kein Dev-Server nötig.
- **Cache der Live-Seite testen** (CDN von GitHub Pages cached aggressiv): `curl -s -I https://jaronsommer.github.io/styles.css` und nach `cache-control` schauen, ggf. `?v=N` Query-Param zum Erzwingen.

## Architektur

Single-Page-Site mit strikter Trennung HTML / CSS / JS. Drei Dateien, ein gemeinsames Strukturprinzip:

- **`index.html`** — der Header-Kommentar (Zeilen 1–40 ca.) listet alle Sektionen in Reihenfolge auf. Sektions-IDs: `hero`, `about`, `education`, `experience`, `projects`, `skills`, `contact`.
- **`styles.css`** — gegliedert durch große `═══`-Banner-Kommentare, **in derselben Reihenfolge wie die HTML-Sektionen**. Erste ~30 Zeilen: `:root` mit allen Design-Tokens (Farben, Schriften, Spacing-Skala, Radien). Beim Anpassen einer Sektion → entsprechenden Banner-Block suchen, nicht querverteilt patchen.
- **`script.js`** — 7 nummerierte Module mit `── N. Titel ───` Bannern: (1) Hamburger-Menü, (2) Nav-Border-on-Scroll, (3) Scroll-Reveal via `IntersectionObserver`, (4) Active-Nav-Link Highlighting, (5) Abgelaufene „Bald"-Erkundungen entfernen + Anzahl absolvierter Erkundungen in `#strengthCount` einsetzen (date-basiert via `data-end-date`), (6) Mailto-Link Spam-Schutz, (7) PDF-Button (`window.print()`). IIFE-Stil, kein State-Sharing zwischen Modulen.

**Design-Token-Disziplin:** Hardcodierte Farben, Pixel oder Schriften vermeiden — immer die `--var-…` aus `:root` verwenden. Eine neue Farbe gehört in `:root`, nicht inline.

## Wichtige Konventionen

- **E-Mail-Adresse niemals direkt ins HTML schreiben.** Der Mailto-Link wird in `script.js` Modul 6 zur Laufzeit aus Teilstrings zusammengesetzt (Spam-Schutz). Wenn die Adresse ändert, dort bearbeiten.
- **Bilder unter `images/`**: kleinbuchstaben, keine Leerzeichen/Sonderzeichen. **Vor dem Commit unbedingt `.\optimize-images.ps1` ausführen** (resized auf 800px, JPEG-Quality 80 + mozjpeg, PNG palette + max compression). Sharp via npx — beim ersten Run ~50MB Download, danach gecached. Der PostToolUse-Hook reminded automatisch wenn Bilder über 150 KB liegen.
- **Print-Stylesheet** (`styles.css` letzter `═══`-Block) ist load-bearing: Lehrbetriebe **drucken Bewerbungsseiten oft aus**. Bei neuen Sektionen/Buttons → prüfen, ob sie im Print sichtbar oder ausgeblendet sein sollen (Beispiel-Pattern: `.btn-pdf` ist via `display: none` in `@media print` ausgeblendet).
- **`404.html`** liegt im Repo-Root — GitHub Pages serviert sie automatisch bei 404. Bei größeren Refactorings des Site-Designs (Farben/Schriften ändern) auch dort updaten — sie hat eigene inline-styles, ist nicht an `styles.css` angebunden (bewusst self-contained).
- **Private Daten (Telefon, Adresse, vollständige E-Mail) gehören NICHT ins Repo** — auch nicht in Kommentare. Repo ist public.
- **Bewerbungsunterlagen** (`*.pdf`, `Lebenslauf*`, `Beilagen*`, `Bewerbung*`) sind in `.gitignore` — beim Hinzufügen neuer privater Dateien Pattern erweitern.

## Animations- / Motion-Philosophie

Bewusst zurückhaltend: ein orchestrierter Page-Load (gestaffelte `fadeUp` mit 0.08s/0.16s/0.24s Delays im Hero) plus `IntersectionObserver`-Scroll-Reveals (Klasse `.reveal` → `.visible`). Keine neuen kontinuierlichen / scroll-getriebenen / aufmerksamkeitssuchenden Animationen einbauen ohne explizite Anfrage — sie passen nicht zum Zielpublikum.

## Analytics

`counter.dev` Script ist am Ende von `index.html` eingebunden (privacy-friendly, kein Cookie-Banner nötig). Keine zusätzlichen Trackers hinzufügen — das würde DSGVO-/Banner-Anforderungen auslösen.

## Claude-Tooling in diesem Repo (.claude/)

- **`.claude/settings.json`** (committed): aktiviert das `frontend-design` Plugin (`anthropics/claude-code` Marketplace) und registriert einen `PostToolUse`-Hook auf `Write|Edit|MultiEdit`.
- **`.claude/readme-reminder.ps1`** (committed): der Hook. Macht **zwei Checks** bei jeder Datei-Änderung: (a) reminded README-Update wenn eine Nicht-README/Nicht-`.claude/`-Datei geändert wird; (b) reminded `optimize-images.ps1` wenn irgendein Bild in `images/` >150 KB ist. Reminders kumulieren. **Hinweis: Windows-only** (PowerShell). Auf macOS/Linux würde der Hook fehlschlagen — bei Cross-Platform-Bedarf umschreiben.
- **`.claude/settings.local.json`** (gitignored): persönliche Permissions, nicht für andere Maschinen relevant.

**Wichtig zum `frontend-design` Plugin:** Die Skill propagiert „bold, distinctive, brutalist/maximalist" Designs. Das ist für diese Seite **bewusst nicht** das Ziel — die zurückhaltende Minimalismus-Richtung ist eine Antwort auf die Zielgruppe (Lehrbetriebe wollen seriös, nicht ausgefallen). Skill-Vorschläge daher immer gegen das Audience-Briefing abwägen.
