# Selbsthilfefestival Hessen — Platzhalterseite

Die Seite für die Zeit **nach** dem Festival am 28.11.2026, bis Termin und Programm für 2027 feststehen.
Veranstalterin: LAG Selbsthilfe Hessen e. V.

Bewusst minimal: Logo, die Jahreszahl, zwei Sätze, Newsletter, Kontakt, Impressum und Datenschutz. Keine Navigation — es gibt nichts zu navigieren.

Statische Seite, ausgeliefert über nginx im Container. Kein Build-Schritt.

---

## Wann diese Seite läuft

Nach dem Festival wird der DNS-Eintrag beziehungsweise der Reverse-Proxy von `selbsthilfefestival-website` auf dieses Image umgestellt. Sobald die Eckdaten für 2027 stehen, geht die Festivalseite mit neuem Inhalt wieder live.

**Wichtig:** Impressum und Datenschutz sind hier vollständig enthalten. Eine Seite, die monatelang allein im Netz steht, braucht beides — der Text ist derselbe wie auf der Festivalseite und muss bei Änderungen **in beiden Repos** gepflegt werden.

---

## Struktur

```
site/
├── index.html
├── css/stil.css
├── js/seite.js             Umschalter für Farbmodus und Leichte Sprache
└── assets/
    ├── schriften/          Archivo, Atkinson Hyperlegible Next (woff2, lokal)
    └── bilder/             Logo und Signet als WebP

Dockerfile · nginx.conf · docker-compose.yml
.github/workflows/          Release-Automatik und Container-Build
```

---

## Lokal ansehen

```bash
python -m http.server 8080 --directory site
```

Mit Docker:

```bash
docker build -t festival-placeholder .
docker run --rm -p 8080:80 festival-placeholder
```

---

## Was beim Bearbeiten zu beachten ist

Es gelten dieselben Regeln wie auf der Festivalseite:

- **Nichts von fremden Servern.** Schriften lokal, keine Analyse-Dienste, kein Cookie-Banner nötig. Die CSP in `nginx.conf` setzt das durch.
- **Farbe nie als alleiniger Informationsträger.**
- **Zwei Sprachfassungen** parallel im Markup (`.nur-standard` / `.nur-leicht`) — beide pflegen.
- **Zwei Farbmodi**, alle Farben über Tokens, dreifach definiert.
- **Keine Bewegung beim Scrollen.**

Die Jahreszahl steht als `<p class="jahr">` im Markup. Beim Wechsel auf 2028 reicht es nicht, sie zu ändern — dann sollte auch geprüft werden, ob die Sätze noch stimmen.

---

## Passwortschutz

Die Seite kann deployt werden, **bevor** sie öffentlich ist. Der Schalter ist eine Umgebungsvariable.

| `SITE_PASSWORT` | Wirkung |
|---|---|
| gesetzt | Basic Auth, `X-Robots-Tag: noindex`, `robots.txt` sperrt alles |
| leer | Seite ist offen und indexierbar |

Der Schalter greift **beim Containerstart**, nicht beim Build. Zum Livegang: Variable leeren, Stack neu starten. Kein neues Image, kein Release.

```bash
# lokal mit Schutz
docker run --rm -p 8080:80 -e SITE_PASSWORT=vorschau test

# lokal ohne
docker run --rm -p 8080:80 test
```

Der Benutzername ist über `SITE_BENUTZER` einstellbar, Vorgabe `festival`.

**Vom Schutz ausgenommen:** `/healthz` — sonst gälte der Container als ungesund und der Deploy würde scheitern. Und `/robots.txt`, damit Suchmaschinen die Sperre überhaupt lesen können.

**Zur Einordnung:** Basic Auth ist ein Sichtschutz, kein Sicherheitsmechanismus. Er hält Suchmaschinen und zufällige Besucher fern. Für einen unveröffentlichten Entwurf ist das angemessen — für echte Geheimnisse wäre es das nicht.

Der Schutz sitzt bewusst im Container statt im Reverse Proxy: So hängt er am Image und geht bei einer Proxy-Änderung nicht versehentlich verloren.

---

## Commits und Versionierung

Die Version wird aus den Commit-Messages abgeleitet ([release-please](https://github.com/googleapis/release-please)).

| Prefix | Wirkung | Changelog |
|---|---|---|
| `feat:` | minor | Features |
| `fix:` | patch | Bug Fixes |
| `a11y:` | — | Barrierefreiheit |
| `content:` | — | Inhalte |
| `perf:` | patch | Performance |
| `refactor:` | patch | Refactor |
| `docs:` `chore:` `ci:` `build:` `style:` | — | ausgeblendet |

Breaking Change: `feat!:` oder `BREAKING CHANGE:` im Body. Vor 1.0 bleibt das ein Minor-Bump.

```
content: Jahreszahl auf 2028 gesetzt
a11y: Fokusreihenfolge im Newsletter-Formular korrigiert
fix: Impressum an Stand der Festivalseite angeglichen
```

### Der Ablauf

1. Commit mit Prefix auf `main`.
2. release-please öffnet einen Release-PR (Version + `CHANGELOG.md`).
3. PR mergen → Tag `vX.Y.Z`.
4. Image wird nach `ghcr.io` gepusht, `prod` wandert mit.
5. Portainer-Webhook rollt aus, die Pipeline wartet auf `/healthz`.

**Ein Push auf `main` verändert nichts in Produktion** — `prod` wandert nur bei einem Release-Tag.

### Einmaliger Setup-Schritt

**Settings → Actions → General → Workflow permissions** → *Allow GitHub Actions to create and approve pull requests*.

| Art | Name | Inhalt |
|---|---|---|
| Secret | `PORTAINER_WEBHOOK_URL` | Stack-Webhook |
| Variable | `DEPLOY_HEALTH_URL` | z. B. `https://selbsthilfefestival-hessen.de/healthz` |

---

## Betrieb

Image: `ghcr.io/rattlingcrab/selbsthilfefestival-placeholder`
Container: `vbk_lagh_festival_placeholder` (LAGH-Konvention `vbk_lagh_<name>`)

`/healthz` liefert `ok` für Docker-Healthcheck und Deploy-Pipeline und ist vom Passwortschutz ausgenommen.

---

## Verwandte Repos

| Was | Wo |
|---|---|
| Konzepte, Recherche, Designsystem | `lagh-selbsthilfe-festival` |
| Festivalseite 2026 | `selbsthilfefestival-website` |
| Betriebskonfiguration | `selbsthilfefestival-config` |
