# docker-cups-airprint-suldr

This Ubuntu-based Docker image runs a CUPS instance that is meant as an AirPrint relay for old Samsung printers that are already on the network but not AirPrint capable. It includes the **Samsung Unified Linux Driver** from the [The Samsung Unified Linux Driver Repository](https://www.bchemnet.com/suldr/index.html).

It will generate a service file for the Avahi daemon. Note that the Avahi daemon is **not** part of this container though. It assumes that an Avahi daemon is running on the host and the `/etc/avahi/services` directory is mounted into the Docker container (see “Running” below).

See https://www.bchemnet.com/suldr/supported.html for a list of supported printer models.

## Building

```
docker build . --build-arg SULDR_PACKAGE=YOUR_VERSION_HERE -t docker-cups-airprint-suldr
```

Replace `YOUR_VERSION_HERE` by the correct driver version for your model (see https://www.bchemnet.com/suldr/supported.html for an overview). If you omit `--build-arg SULDR_PACKAGE`, it will default to `suld-driver-4.00.39` (which the correct version for the Samsung CLP510-N that I own).

## Running

```
docker run --name docker-cups-airprint-suldr --rm -p 631:631 \
	-v /etc/avahi/services:/services \
	-v /home/aaron/config:/config \
	--env CUPSADMIN=admin --env CUPSPASSWORD=admin \
	-t docker-cups-airprint
```

Update the paths to match your setup.

**Note that this assume that Avahi is running on your host computer!**

## Configuration Reference

### Build Arguments

Set the following to include the correct driver version:

* `SULDR_PACKAGE` (**example:** `suld-driver-4.00.39`)

You should be able to leave these unchanged as they have reasonable defaults:

* `SULDR_REPO`
* `SULDR_KEYRING_URL`
* `SULDR_KEYRING_DEB`

### Volumes

* `/config`: where the persistent printer configs will be stored
* `/services`: where the Avahi service files will be generated

### Variables

* `CUPSADMIN`: the CUPS admin user you want created
* `CUPSPASSWORD`: the password for the CUPS admin user

### Ports
* `631`: the TCP port for CUPS must be exposed

## Notes
* CUPS doesn’t write out `printers.conf` immediately when making changes even though they’re live in CUPS. Therefore it will take a few moments before the services files update.
* Don’t stop the container immediately if you intend to have a persistent configuration for this same reason.

## Acknowledgments

Many thanks go to [@quadportnick](https://github.com/quadportnick) who created https://github.com/quadportnick/docker-cups-airprint which this repository has been forked from.

