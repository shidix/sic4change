#!/bin/bash
export PATH=/home/danidiaz/develop/flutter/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
while true
do
    cd /var/www/flutter/sic4change/web
    flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8989
done
