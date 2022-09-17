FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
	cups \
	libcupsimage2 \
	libcups2-dev \
	inotify-tools \
	python3-pip \
	rsync \
	avahi-daemon \
	printer-driver-splix \
	&& pip3 --no-cache-dir install --upgrade pip \
	&& pip3 install pycups \
	&& rm -rf /var/lib/apt/lists/* /tmp/*

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services
VOLUME /logs

# Add scripts
COPY scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

CMD ["run_cups.sh"]

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf && \
	sed -i 's#ErrorLog /var/log/cups/error_log#ErrorLog /logs/error_log#' /etc/cups/cups-files.conf && \
	sed -i 's#AccessLog /var/log/cups/access_log#AccessLog /logs/access_log#' /etc/cups/cups-files.conf
