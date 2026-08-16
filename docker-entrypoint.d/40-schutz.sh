#!/bin/sh
# ---------------------------------------------------------------------------
# Passwortschutz und Suchmaschinen-Freigabe beim Containerstart setzen.
#
#   SITE_PASSWORT   gesetzt  -> Seite verlangt Basic Auth, noindex
#                   leer     -> Seite ist offen und indexierbar
#   SITE_BENUTZER   optional -> Benutzername, Vorgabe: festival
#
# Zum Livegang genuegt es, SITE_PASSWORT zu entfernen und den Stack neu
# zu starten. Kein neues Image, kein Redeploy der Anwendung.
# ---------------------------------------------------------------------------
set -eu

SCHUTZ_CONF=/etc/nginx/schutz.conf
ROBOTS=/usr/share/nginx/html/robots.txt

if [ -n "${SITE_PASSWORT:-}" ]; then
    BENUTZER="${SITE_BENUTZER:-festival}"

    htpasswd -bcB /etc/nginx/.htpasswd "$BENUTZER" "$SITE_PASSWORT" >/dev/null 2>&1
    # Gruppe MUSS mitgesetzt werden. Modus 640 allein genuegt nicht: Eigentuemer
    # und Gruppe waeren beide root, der nginx-Worker laeuft aber als Benutzer
    # nginx und gehoert zu keinem von beiden. Die Folge war eine 500 bei jedem
    # Aufruf MIT gueltigen Zugangsdaten - ohne Zugangsdaten kam weiter brav
    # eine 401, weil nginx die Datei dafuer nicht liest. Der Schutz sah damit
    # funktionsfaehig aus, liess aber niemanden herein.
    #   [crit] open("/etc/nginx/.htpasswd") failed (13: Permission denied)
    chown root:nginx /etc/nginx/.htpasswd
    chmod 640 /etc/nginx/.htpasswd

    cat > "$SCHUTZ_CONF" <<'EOF'
auth_basic           "Selbsthilfefestival - Vorschau";
auth_basic_user_file /etc/nginx/.htpasswd;
add_header X-Robots-Tag "noindex, nofollow" always;
EOF

    printf 'User-agent: *\nDisallow: /\n' > "$ROBOTS"
    echo "[schutz] Passwortschutz aktiv (Benutzer: $BENUTZER), Seite auf noindex."
else
    : > "$SCHUTZ_CONF"
    printf 'User-agent: *\nAllow: /\n' > "$ROBOTS"
    echo "[schutz] Kein Passwort gesetzt - Seite ist oeffentlich."
fi
