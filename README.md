# Jaron Sommer – Portfolio Website

Persönliche Portfolio-Webseite für die Lehrstellensuche, gehostet via **GitHub Pages**.

🌐 **Live:** [jaronsommer.github.io](https://jaronsommer.github.io)

---

## Inhalt

Die Seite enthält folgende Sektionen:

| Sektion | Beschreibung |
|---|---|
| **Hero** | Name, Berufswunsch, Status-Badge |
| **Über mich** | Kurzprofil und persönliche Stärken |
| **Ausbildung** | Chronologische Timeline (Kindergarten → Sek.) |
| **Erfahrungen** | Arbeitserfahrung & Berufserkundungen |
| **Kenntnisse** | Sprachen, IT-Tools, Hobbys |
| **Kontakt** | E-Mail-Button (keine privaten Daten öffentlich) |

---

## Technologie

- **Pure HTML/CSS/JS** – kein Framework, keine Build-Tools
- **Google Fonts** – DM Serif Display + DM Sans
- **GitHub Pages** – kostenloses statisches Hosting
- **Responsive** – funktioniert auf Mobile, Tablet & Desktop

---

## Projektstruktur

```
portfolio/
├── index.html      # Gesamte Webseite (eine Datei)
├── README.md       # Diese Datei
└── .gitignore      # Ausgeschlossene Dateien
```

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

# 2. index.html ins Repo kopieren und pushen
git add index.html
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
git add index.html
git commit -m "fix: Beschreibung angepasst"
git push
```

GitHub Pages aktualisiert die Seite automatisch nach jedem Push.

---

## Mit IntelliJ IDEA bearbeiten

1. **Repo klonen:** `Git → Clone` → URL einfügen
2. **Bearbeiten:** `index.html` öffnen, Änderungen vornehmen
3. **Vorschau:** Rechtsklick → *Open in → Browser* oder Live Preview Plugin
4. **Commit & Push:** `Git → Commit` → Nachricht eingeben → *Commit and Push*

---

## Datenschutz

Auf der öffentlichen Webseite sind **keine privaten Kontaktdaten** sichtbar.  
Der Kontakt-Button öffnet den E-Mail-Client des Besuchers via `mailto:`.  
Die E-Mail-Adresse ist im JavaScript-Code aufgeteilt (Schutz vor Spam-Bots).

---

## Lizenz

Privates Projekt – alle Rechte vorbehalten.  
© 2026 Jaron Sommer, Wiedlisbach
