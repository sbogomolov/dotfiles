# Common configuration

## Install packages:

```sh
sudo xbps-install -Sy ImageMagick bash-completion bemenu btrfs-progsr chrony cmake cronie curl dconf firefox font-firacode foot fzf gcc git gnome-keyring gnome-themes-extra google-fonts-ttf grim gsettings-desktop-schemas htop i3status j4-dmenu-desktop kwayland make mako mesa-dri mpv pavucontrol pipewire pulseaudio-utils qt5-wayland ranger ripgrep seatd slurp socklog-void sway swayidle swaylock vim void-repo-nonfree vulkan-loader wl-clipboard xdg-desktop-portal-wlr xdg-user-dirs xdpyinfo yaml-cpp
```

### Intel CPU and/or Graphics

```sh
sudo xbps-install -Sy intel-ucode
sudo xbps-reconfigure -fa
```

### Intel Graphics

```sh
sudo xbps-install -Sy intel-video-accel libvdpau-va-gl mesa-vulkan-intel
```

### Extra packages for the laptop:

```sh
sudo xbps-install -Sy iwd light tlp
```

## Setting up configuration files:

- Run ./setup.sh

## Hardware acceleration

- https://wiki.archlinux.org/title/Hardware_video_acceleration

## Groups

- Add your user to `video` and `_seatd` groups
- Add `_greeter` user to `_seatd` group

## Auto-login to gnome-keyring

https://wiki.archlinux.org/title/GNOME/Keyring#PAM_method

## Printers

To enable automatic discovery of IPP printers (https://wiki.debian.org/CUPSQuickPrintQueues?action=show&redirect=QuickPrintQueuesCUPS#IPP_Printers):
- In `/etc/cups/cups-browsed.conf` uncomment `CreateIPPPrinterQueues All`
- `systemctl restart cups-browsed`

## Map CapsLock to Ctrl/Esc

- Install build dependencies
```sh
sudo xbps-install -Sy boost-devel eudev-libudev-devel libevdev-devel yaml-cpp-devel
```
- Clone, build and install [Interception Tools](https://gitlab.com/interception/linux/tools)
```sh
mkdir -p ~/code
cd ~/code
git clone https://gitlab.com/interception/linux/tools.git interception-tools
cd interception-tools
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
sudo cmake --install build
```
- Clone, build and install [caps2esc](https://gitlab.com/interception/linux/plugins/caps2esc)
```sh
mkdir -p ~/code
cd ~/code
git clone https://gitlab.com/interception/linux/plugins/caps2esc.git
cd caps2esc
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
sudo cmake --install build
```
- Create a service for `udevmon`
```sh
sudo mkdir /etc/sv/udevmon
sudo tee /etc/sv/udevmon/run > /dev/null <<EOT
#!/bin/sh

exec /usr/local/bin/udevmon
EOT
chmod +x /etc/sv/udevmon/run
```

# ThinkPad laptop

## Backlight brightness

- Install xbacklight
```sh
sudo dnf -y install xbacklight
```

## Synaptic touchpad

- Install synaptic driver (to use instead of libinput):
```sh
sudo dnf -y install xorg-x11-drv-synaptics-legacy
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


## Hibernation to swapfile on btrfs

- Prepare swapfile:
```sh
sudo truncate -s 0 /swapfile
sudo chattr +C /swapfile
sudo btrfs property set /swapfile compression none
sudo dd if=/dev/zero of=/swapfile bs=1M count=30720 status=progress
sudo chmod 600 /swapfile
sudo mkswap /swapfile
```
- Enable swap file
```sh
sudo swapon /swapfile
```
- To enable it on boot, add this line to /etc/fstab
```
/swapfile                                 none                    swap    defaults        0 0
```
- Download https://github.com/osandov/osandov-linux/blob/master/scripts/btrfs_map_physical.c
- Build it
```sh
gcc -O2 -o btrfs_map_physical btrfs_map_physical.c
```
- Find out physical offset to the swap file (first row, last column is the number we need)
```sh
sudo ./btrfs_map_physical /swapfile | head
```
- Divide that number by page size. To find page size:
```sh
getconf PAGESIZE
```
- Add `resume` module to initramfs
```sh
sudo sh -c 'echo "add_dracutmodules+=\" resume \"" > /etc/dracut.conf.d/resume.conf'
sudo dracut -f
```
- Add kernel parameters in `/etc/default/grub` (use the correct UUID of the device where swapfile is created and offset computed in the previous steps)
```
resume=UUID=6d1e4046-9258-4be3-9d08-b52653272aad resume_offset=1796570
```
- Update grub config
```sh
sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
```
- Disable hibernation memory check for `systemd-hibernate` and `systemd-logind`. Edit the overrides for these services and insert there following:
```
[Service]
Environment=SYSTEMD_BYPASS_HIBERNATION_MEMORY_CHECK=1
```
```sh
sudo systemctl edit systemd-hibernate
# Insert text, save and exit

sudo systemctl edit systemd-logind
# Insert text, save and exit
```
- Reboot

More information here:
- https://wiki.archlinux.org/index.php/Btrfs#Swap_file
- https://wiki.archlinux.org/index.php/Power_management/Suspend_and_hibernate#Hibernation_into_swap_file_on_Btrfs
