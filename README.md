# Common configuration

- Run ./setup.sh


# ThinkPad laptop

## Backlight brightness

- Install xbacklight
```sh
sudo dnf -y install xbacklight
```

## TLP

```sh
sudo dnf install tlp tlp-rdw

dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf install https://repo.linrunner.de/fedora/tlp/repos/releases/tlp-release.fc$(rpm -E %fedora).noarch.rpm
dnf install akmod-acpi_call
```

## Fingerprint sensor on Fedora 33

- From directory `python-validity` install the packages
```sh
sudo dnf install python3-validity-0.12-1.fc33.noarch.rpm open-fprintd-0.6-1.fc33.noarch.rpm fprintd-clients-1.90.1-2.fc33.x86_64.rpm fprintd-clients-pam-1.90.1-2.fc33.x86_64.rpm
```
- Fix small issues before starting the service:
```sh
sudo touch /usr/share/python-validity/backoff
sudo touch /usr/share/python-validity/calib-data.bin
sudo chmod 755 /usr/share/python-validity/6_07f_lenovo_mis_qm.xpfwext
```
- Enable and start the service:
```sh
systemctl enable python3-validity.service
systemctl start python3-validity.service
```
- Allow fingerprint authentication
```sh
sudo authselect enable-feature with-fingerprint
sudo authselect apply-changes
```

More information here:
- https://github.com/uunicorn/python-validity
- https://github.com/uunicorn/python-validity/issues/54
- https://wiki.archlinux.org/index.php/Fprint#Login_configuration
