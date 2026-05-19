# Jaron Sommer – Portfolio Website

Persönliche Portfolio-Webseite für die Lehrstellensuche, gehostet via **GitHub Pages**.

🌐 **Live:** [jaronsommer.github.io](https://jaronsommer.github.io)

---

## Inhalt

Die Seite enthält folgende Sektionen:

| Sektion         | Beschreibung                                    |
|-----------------|-------------------------------------------------|
| **Hero**        | Name, Berufswunsch, Status-Badge                |
| **Über mich**   | Kurzprofil und persönliche Stärken              |
| **Ausbildung**  | Chronologische Timeline (Kindergarten → Sek.)   |
| **Erfahrungen** | Arbeitserfahrung & Berufserkundungen            |
| **Projekte**    | Eigene Webprojekte mit Live-Demo & GitHub-Link  |
| **Kenntnisse**  | Sprachen, IT-Tools, Hobbys                      |
| **Kontakt**     | E-Mail-Button (keine privaten Daten öffentlich) |

---

## Technologie

- **Pure HTML/CSS/JS** – kein Framework, keine Build-Tools, keine Dependencies
- **Saubere Trennung** – HTML (`index.html`), CSS (`styles.css`), JavaScript (`script.js`) in eigenen Dateien
- **Google Fonts** – DM Serif Display + DM Sans
- **GitHub Pages** – kostenloses statisches Hosting
- **Responsive** – funktioniert auf Mobile, Tablet & Desktop
- **Druck- & Share-optimiert** – Print-Stylesheet, Open Graph Tags, Favicon

---

## Projektstruktur

```
jaronsommer.github.io/
├── index.html        # HTML-Struktur & Inhalt
├── styles.css        # Layout, Farben, Animationen, Print-Stylesheet
├── script.js         # Navigation, Scroll-Reveal, Mailto-Link
├── favicon.svg       # Browser-Tab-Icon ("J" in Akzentblau)
├── README.md         # Diese Datei
├── .gitignore        # Ausgeschlossene Dateien
└── images/           # Bilder & Fotos
    └── Jaron.jpg     # Portrait (Hero-Bereich)
```

**Was gehört wohin?**

| Datei         | Wann anpassen?                                                                 |
|---------------|---------------------------------------------------------------------------------|
| `index.html`  | Texte, neue Sektionen, Berufserkundungen, Projekte                              |
| `styles.css`  | Farben, Schriften, Abstände, Layout, Hover-Effekte                              |
| `script.js`   | Verhalten (z.B. Menü-Toggle, Scroll-Effekte, neue Interaktionen)                |
| `favicon.svg` | Tab-Icon (aktuell ein kursives „J" – kann mit jedem Vektor-Editor geändert werden) |

### Bilder hinzufügen

Neue Bilder immer im Ordner `images/` speichern und in `index.html` so einbinden:

```html
<img src="images/dateiname.jpg" alt="Beschreibung" />
```

**Tipps:**
- Dateinamen ohne Leerzeichen und Sonderzeichen (z.B. `foto.jpg` statt `mein foto (1).jpg`)
- Fotos vor dem Upload verkleinern auf max. ~800px Breite → [squoosh.app](https://squoosh.app)
- Format: JPG für Fotos, PNG für Grafiken mit transparentem Hintergrund

---

## Lokal öffnen

Keine Installation nötig – einfach `index.html` im Browser öffnen:

```bash
# macOS / Linux
open index.html

# Windows
start index.html

# Oder per Live Server in IntelliJ IDEA:
# Rechtsklick auf index.html → "Open in" → "Browser"
```

---

## Deployment auf GitHub Pages

### Erstmalig einrichten

```bash
# 1. Repository klonen
git clone https://github.com/jaronsommer/jaronsommer.github.io
cd jaronsommer.github.io

# 2. Dateien ins Repo kopieren und pushen
git add .
git commit -m "feat: Portfolio Website hinzugefügt"
git push origin main
```

### GitHub Pages aktivieren

1. GitHub Repo öffnen → **Settings** → **Pages**
2. Source: **Deploy from a branch**
3. Branch: `main` / Ordner: `/ (root)`
4. Speichern – nach ~2 Minuten ist die Seite live

### Änderungen deployen

```bash
git add .
git commit -m "fix: Beschreibung angepasst"
git push
```

GitHub Pages aktualisiert die Seite automatisch nach jedem Push.

---

## Mit IntelliJ IDEA bearbeiten

1. **Repo klonen:** `Git → Clone` → URL einfügen
2. **Bearbeiten:**
   - Inhalte/Texte → `index.html`
   - Aussehen → `styles.css`
   - Verhalten → `script.js`
3. **Vorschau:** Rechtsklick auf `index.html` → *Open in → Browser* oder Live Preview Plugin
4. **Commit & Push:** `Git → Commit` → Nachricht eingeben → *Commit and Push*

---

## Datenschutz

Auf der öffentlichen Webseite sind **keine privaten Kontaktdaten** sichtbar.  
Der Kontakt-Button öffnet den E-Mail-Client des Besuchers via `mailto:`.  
Die E-Mail-Adresse ist in `script.js` aufgeteilt und wird erst zur Laufzeit zusammengesetzt (Schutz vor Spam-Bots).

---

## Lizenz

Privates Projekt – alle Rechte vorbehalten.  
© 2026 Jaron Sommer, Wiedlisbach
