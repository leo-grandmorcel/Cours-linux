# TP 3 : A little script

-[ Script carte d'identité](#script-carte-didentité)

-[ Script youtube-dl](#script-youtube-dl)

-[ MAKE IT A SERVICE](#make-it-a-service)

-[ Bonus](#bonus)


## Script carte d'identité
```
sudo bash /srv/idcard/idcard.sh
    Machine name : node1.tp2.linux
    OS Ubuntu and kernel version is 5.11.0-38-generic
    IP : 192.168.56.117
    RAM : 449Mebi / 1985Mebi
    Disque : 2,5Go Left
    Top 5 processes by RAM usage :
    - 882 xfwm4
    - 1699 /usr/libexec/fwupd/fwupd
    - 587 /usr/lib/xorg/Xorg
    - 732 xfce4-session
    - 962 /usr/bin/python3
    Listening ports :
    - 2000 : sshd
    - 53 : systemd-resolve
    - 631 : cupsd
    - 2000 : sshd
    - 2001 : vsftpd
    - 631 : cupsd

    Here's your random cat : https://cdn2.thecatapi.com/images/WVLNnLY-7.jpg
```

## Script youtube-dl
```
sudo bash /srv/yt/yt.sh https://www.youtube.com/watch?v=sNx57atloH8
    Video https://www.youtube.com/watch?v=sNx57atloH8
    File path : /srv/yt/downloads/tomato anxiety/tomato anxiety.mp4
```

## MAKE IT A SERVICE
```
systemctl status yt.service
    ● yt.service - "Processus pour dl des vidéos"
        Loaded: loaded (/etc/systemd/system/yt.service; disabled; vendor preset: enabled)
        Active: active (running) since Fri 2021-11-19 12:31:23 CET; 1min 45s ago
    Main PID: 4800 (bash)
        Tasks: 2 (limit: 2312)
        Memory: 772.0K
        CGroup: /system.slice/yt.service
                ├─4800 /usr/bin/bash /srv/yt/yt-v2.sh
                └─4887 sleep 5s

    nov. 19 12:31:23 node1.tp2.linux systemd[1]: Started "Processus pour dl des vidéos".
    nov. 19 12:31:39 node1.tp2.linux bash[4802]: Video https://www.youtube.com/watch?v=sNx57atloH8 was downloaded
    nov. 19 12:31:39 node1.tp2.linux bash[4802]: File path : /srv/yt/downloads/tomato anxiety/tomato anxiety.mp4
```

```
journalctl -xe -u yt
    [...]
    -- The job identifier is 3507.
    nov. 19 12:31:39 node1.tp2.linux bash[4802]: Video https://www.youtube.com/watch?v=sNx57atloH8 was downloaded
    nov. 19 12:31:39 node1.tp2.linux bash[4802]: File path : /srv/yt/downloads/tomato anxiety/tomato anxiety.mp4
```

## Bonus
[![asciicast](https://asciinema.org/a/PdGhqOL66w6jZuVqTZ6hHJ3Uw.svg)](https://asciinema.org/a/PdGhqOL66w6jZuVqTZ6hHJ3Uw)