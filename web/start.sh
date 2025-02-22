#!/bin/bash
#export PATH=/home/danidiaz/develop/flutter/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
#flutter build --release
while true
do
    echo $(date) "Restarting app... "
    cd /var/www/flutter/sic4change
    flutter pub get
    flutter build web --release --web-renderer html
    #flutter build web
    flutter gen-l10n
    cd /var/www/flutter/sic4change/web
    systemctl restart apache2
    #flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8989
    flutter run --release -d web-server --web-hostname 0.0.0.0 --web-port 8989 --web-renderer html
done
