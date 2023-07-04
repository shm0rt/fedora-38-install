# fedora-38-install
# Installation
After creating the USB stick, you should follow the following steps:

Disable Secure Boot and enable virtualization in the BIOS (if not already enabled).
Boot from the USB stick with the live ISO.
Select the system language, keyboard layout, and time zone.
When selecting the storage on which the system should be installed, choose the hard drive and check the option below:

![Pasted image 20230628094356](https://github.com/shm0rt/fedora-38-install/assets/126892002/dee10fb9-03ca-414f-a30b-ed4947bf93c3)

After following these steps, you will be redirected to the next page. Here, you can choose whether you want to encrypt the hard drive and which file system you want to use. Since I want to use [*Timeshift*](https://github.com/linuxmint/timeshift), I recommend using the btrfs file system as it provides faster restoration.

> Note:
> If you want to encrypt the drive, please consider the following:
> - The keyboard layout will remain as American during password entry.
> - You will need to enter the password every time you start the system.

![Pasted image 20230628100419](https://github.com/shm0rt/fedora-38-install/assets/126892002/ab56518f-92b4-4116-b682-1301b5a1f3d1)

Click on the highlighted text as shown in the image to perform automatic partitioning. In order for Timeshift to read the file system correctly, two folders should be renamed:

Rename the root folder to @
Rename the home folder to @home
To rename the folder, follow these steps:

1. Click on the respective folder.
2. Enter the correct name in the bottom right corner.
3. Click on the "Apply Settings" button.

After you have completed everything, it should look similar to this:
![Screenshot from 2023-06-28 10-51-59](https://github.com/shm0rt/fedora-38-install/assets/126892002/f3339497-db48-4d90-ba04-989c29e30b0e)

---
# Nach der Installation

## Dunkler Modus

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'        # Legacy apps
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'      # new apps
```

---
## Geräte-Namen ändern
Um den Geräte-Namen zu ändern öffnen Sie den Terminal und fügen Sie folgendes ein:
```bash
hostnamectl set-hostname <gereate-name>
```

Ändern Sie den ```<gereate-name>``` durch den neuen Namen Ihres Gerätes. Zum Beispiel:
```bash
hostnamectl set-hostname inf-nb-tux01
```

---
## dnf einstellen
Um das System ein wenig zu beschleunigen bearbeiten Sie den _dnf.conf_. 
Folgendes wurde geändert:
- Schnellere Installation (fastest_mirror, max_parallel_downloads)
- Immer Ja (defaultyes)

Die Option _defaultyes_ erlaubt es mit der ENTER-Taste die Eingabe mit Ja bestätigen. Zum Beispiel: anstatt folgendes eintippen ```sudo apt-get update -y``` gibt ihr folgendes ein:
```sudo apt-get update``` und bestätigt es mit der ENTER-Taste

Ändern Sie den File wie folgend:
- Öffnen Sie den Terminal und geben Sie dies hinein: `sudo nano /etc/dnf/dnf.conf` 
- Kopieren Sie den Text und ersetzen Sie ihn durch den folgenden Text:

```bash
[main] 
gpgcheck=1 
installonly_limit=3 
clean_requirements_on_remove=True 
best=False 
skip_if_unavailable=True 
fastestmirror=1 
max_parallel_downloads=10 
deltarpm=true
defaultyes=True
```

>[!info]+
>Das Plugin `fastestmirror=1` kann manchmal kontraproduktiv sein. Verwenden Sie es nach eigenem Ermessen. Setzen Sie es auf `fastestmirror=0`, wenn Sie mit schlechten Download-Geschwindigkeiten konfrontiert sind. Viele Benutzer haben von besseren Download-Geschwindigkeiten berichtet, wenn das Plugin aktiviert ist. Daher ist es standardmäßig aktiviert.

---
## Nvidia Treiber
Mit der Installation von den Nvidia-Treiber haben Sie die Möglichkeit auf die:
- Grafikbeschleunigung
- CUDA-Unterstützung
- Mehrere Monitorunterstützung

Sie können selber auswählen welche Treiber Sie wollen:
- Nouveau (Open-Source)
- Cuda (proprietär)
- RPM Fusion (proprietär)

Der Unterschied zwischen den genannten Treiberoptionen liegt in ihrer Quelle, Lizenzierung und den mitgelieferten Funktionen. Nouveau ist ein quellenoffener Treiber, der von der Linux-Community entwickelt wird und grundlegende Grafikkartenunterstützung bietet. Der CUDA-Treiber ist ein proprietärer Treiber von Nvidia, der speziell für CUDA-Berechnungen entwickelt wurde und die parallele Rechenleistung der Nvidia-GPUs voll ausschöpft. RPM Fusion bietet proprietäre Nvidia-Treiber als Teil seines Software-Repositories für RPM-basierte Linux-Distributionen an, um Benutzern den Zugriff auf die neuesten Treiberversionen zu ermöglichen.

### Cuda
Fügen Sie die Repository hinzu:
```bash
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora37/x86_64/cuda-fedora37.repo
```

Installieren Sie die Abhängigkeiten:
```bash
sudo dnf install -y kernel-headers kernel-devel tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-opengl libglvnd-glx libglvnd-devel acpid pkgconfig dkms
```

Installieren Sie die Treiber:
```bash
sudo dnf module install -y nvidia-driver:latest-dkms
```

### RPM Fusion

RPM Fusion ermöglicht den Zugriff auf nicht-freie Softwarepakete, die in den offiziellen Fedora-Repositories aus rechtlichen oder lizenztechnischen Gründen nicht verfügbar sind. Dazu gehören proprietäre Treiber, Codecs für Multimedia-Wiedergabe, bestimmte Anwendungen und Erweiterungen. Um die RPM zu installieren und zu aktivieren:

```bash
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

---
## Appstream Metadaten
[AppStream](https://www.freedesktop.org/wiki/Distributions/AppStream/) verwendet ein XML-basiertes Datenformat, um Metadaten für Anwendungen zu definieren. Diese Metadaten umfassen Informationen wie Anwendungsnamen, Beschreibungen, Kategorien, Lizenzen, Entwicklerdetails, Abhängigkeiten, unterstützte Sprachen und mehr. Die Metadaten dienen dazu, Benutzern umfassende Informationen über verfügbare Anwendungen bereitzustellen.

Um den App-Stream-Metadaten auf den neuesten Stand zu bringen, geben Sie folgendes in den Terminal ein:
```bash
sudo dnf groupupdate core
```
 
---
## Update 
Um dein System zu _aktualisieren_:
- ```sudo dnf update -y```

Um dein System zu _upgraden_:
- ```sudo dnf upgrade -y```

Um Änderungen anzuwenden, neue Module zu laden und alte Module zu entladen:
- ```sudo reboot```

**_Oneliner:_**
```bash
sudo dnf update -y && sudo dnf upgrade -y && sudo reboot
```

---
## Firmware ([fwupd](https://wiki.archlinux.org/title/Fwupd))

Wenn Ihr System Firmware-Update durch lvfs unterstützt, updaten Sie ihr Gerät mithilfe wie folgt:
- Den Firmware-Update Dienst herunterladen:
```sudo dnf install fwupd```

- Den fwupd.service starten und beim Start ausführen:
```sudo systemctl start fwupd```
```sudo systemctl enable fwupd```

- Um alle Geräte anzuzeigen, die von fwupd erkennt worden sind:
```sudo fwupdmgr get-devices```

- Um die neusten Metadaten herunterzuladen:
```sudo fwupdmgr refresh --force```

- Zur Auflistung der verfügbaren Updates für alle Geräte auf dem System:
```sudo fwupdmgr get-updates```

- Um alle Updates zu installieren:
```sudo fwupdmgr update```

**_Oneliner:_**
```bash
sudo dnf install fwupd && sudo systemctl start fwupd && sudo systemctl enable fwupd && sudo fwupdmgr get-devices && sudo fwupdmgr refresh --force && sudo fwupdmgr get-updates && sudo fwupdmgr update
```

---

## Media Codecs
Installieren Sie folgende Module um korrekte Multimedia Playback zu erhalten:
```bash
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia
sudo dnf groupupdate multimedia sound-and-video
# Nur für Chrome-Benutzer
# sudo dnf swap chromium chromium-freeworld --allowerasing
sudo dnf install ffmpeg-libs
```

### Weitere Verbesserungs-Möglichkeiten
- [Video I/O hardware acceleration, Video Decoding with VA-API ](https://github.com/opencv/opencv/wiki/Video-IO-hardware-acceleration)
- [OpenH264 für Firefox](https://docs.fedoraproject.org/de/quick-docs/openh264/)
---

## Update Flatpak
Fedora 38 kommt mit Flatpak schon vorinstalliert, aber nicht aktiviert. Fügen Sie folgende Befehle aus, um flathub repo zu aktivieren und flatpak auf den neusten Stand bringen:
```bash
flatpak remote-delete flathub
flatpak remote-delete fedora
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update
```
---

## Tools
- Für komprimierte Files (7z, rar):
```sudo dnf install -y unzip p7zip p7zip-plugins unrar```
- Für GNOME:
```sudo dnf install -y gnome-tweaks gnome-network-displays```
- Für Fedora:
 ```sudo dnf install -y packageKit timeshift grub-customizer dconf-editor```
 - Von Flatpak:
 ```sudo flatpak install -y com.mattjakeman.ExtensionManager com.github.tchx84.Flatseal```
---

## Thema [Optional]
### Icons und Zeiger
- [Oxygen-Cursors](https://github.com/wo2ni/Oxygen-Cursors)
- [Papirus Icon Theme]](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)

### Thema in Flatpaks nutzen
* `sudo flatpak override --filesystem=$HOME/.themes`
* `sudo flatpak override --env=GTK_THEME=my-theme` 

---

## Weitere:
- [Install-Script](/fedora_install.sh)




