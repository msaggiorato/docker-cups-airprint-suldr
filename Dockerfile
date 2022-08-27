FROM ubuntu:20.04

ARG SULDR_REPO="deb https://www.bchemnet.com/suldr/ debian extra"
ARG SULDR_KEYRING_URL=http://www.bchemnet.com/suldr/pool/debian/extra/su/suldr-keyring_2_all.deb
ARG SULDR_KEYRING_DEB=suldr-keyring_2_all.deb

# Appropriate version for CLP-510. Can be overriden in build command if needed.
# See https://www.bchemnet.com/suldr/supported.html for all supported models.
ARG SULDR_PACKAGE=suld-driver2-1.00.39

RUN apt-get update && apt-get upgrade -y && apt-get install -y software-properties-common

ADD $SULDR_KEYRING_URL /tmp/$SULDR_KEYRING_DEB

RUN dpkg -i "/tmp/$SULDR_KEYRING_DEB" && \
	apt-add-repository "$SULDR_REPO" && \
	apt-get update && apt-get install -y \
	cups \
	libcupsimage2 \
	libcups2-dev \
	inotify-tools \
	python3-pip \
	rsync \
	avahi-daemon \
	$SULDR_PACKAGE \
	&& pip3 --no-cache-dir install --upgrade pip \
	&& pip3 install pycups \
	&& rm -rf /var/lib/apt/lists/* "/tmp/$SULDR_KEYRING_DEB"

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
