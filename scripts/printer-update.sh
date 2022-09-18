#!/bin/bash
inotifywait -m -e close_write,moved_to,create /etc/cups | 
while read -r directory events filename; do
	rm -rf /services/AirPrint-*.service
	airprint-generate.py -d /services
	cp /etc/cups/printers.conf /config/printers.conf
	rsync -avh --delete /etc/cups/ppd/ /config/ppd/
	rsync -avh --delete /services/ /etc/avahi/services/
done
