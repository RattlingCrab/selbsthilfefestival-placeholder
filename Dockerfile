# Statische Seite auf nginx. Kein Build-Schritt: was in site/ liegt, wird
# ausgeliefert. Damit ist das Image reproduzierbar und winzig.
FROM nginx:1.27-alpine

# htpasswd fuer den optionalen Passwortschutz (siehe 40-schutz.sh).
RUN apk add --no-cache apache2-utils

# Eigene Konfiguration statt der Default-Site.
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/site.conf

# Wird beim Containerstart ausgefuehrt und schaltet den Schutz je nach
# Umgebungsvariable an oder aus. Die leere schutz.conf wird gleich mit
# angelegt: nginx startet nicht, wenn eine per include eingebundene Datei
# fehlt - und das darf nicht davon abhaengen, dass das Script lief.
COPY docker-entrypoint.d/40-schutz.sh /docker-entrypoint.d/40-schutz.sh
RUN chmod +x /docker-entrypoint.d/40-schutz.sh  && touch /etc/nginx/schutz.conf

COPY site/ /usr/share/nginx/html/

EXPOSE 80

# Der Health-Check ist vom Passwortschutz ausgenommen - sonst wuerde der
# Container als ungesund gelten, sobald der Schutz aktiv ist.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/healthz || exit 1
