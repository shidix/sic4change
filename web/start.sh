#!/bin/bash
export PATH=/home/danidiaz/develop/flutter/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
#flutter build --release
while true
do
    cd /var/www/flutter
    #flutter build --release
    flutter build web
    flutter gen-l10n
    cd /var/www/flutter/sic4change/web
    flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8989
    #flutter run --release -d web-server --web-hostname 0.0.0.0 --web-port 8989
done
