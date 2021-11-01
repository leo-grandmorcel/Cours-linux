# TP2 : Manipulation de services



## Prérequis

Changer le nom de la machine
```
sudo hostname node1.tp2.linux
sudo nano /etc/hostname 
cat /etc/hostname
    node1.tp2.linux
reboot 
```


Ping la VM
```
ping 1.1.1.1 -c 1
    [...]
    --- 1.1.1.1 ping statistics ---
    1 packets transmitted, 1 received, 0% packet loss, time 0ms
    [...]
``` 


Ping ynov.com
```
ping ynov.com -c 3
    [...]
    --- ynov.com ping statistics ---
    3 packets transmitted, 3 received, 0% packet loss, time 10ms
    [...]
```


Ping la VM depuis le PC
```
ping 192.168.56.115 -c 1
    [...]
    Statistiques Ping pour 192.168.56.115:
        Paquets : envoyés = 1, reçus = 1, perdus = 0 (perte 0%),
    [...]
```

## Partie 1 : SSH

Installer le paquet openssh-server
```
sudo apt install openssh-server
    [...]
    openssh-server is already the newest version (1:8.2p1-4ubuntu0.3).
    0 upgraded, 0 newly installed, 0 to remove and 89 not upgraded.
```


Lancer le service sshd
```
systemctl start ssh
systemctl status ssh
    ● ssh.service - OpenBSD Secure Shell server
        Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
        Active: active (running) since Mon 2021-10-25 10:46:12 CEST; 34min ago
    [...]
```

Analyser le service en cours de fonctionnement
```
ps -e | grep sshd
     562 ?        00:00:00 sshd
     820 ?        00:00:00 ssh-agent
    1227 ?        00:00:00 sshd
    1305 ?        00:00:00 sshd

sudo ss -ltpn
    State    Recv-Q   Send-Q      Local Address:Port       Peer Address:Port   Process
    [...]
    LISTEN   0        128               0.0.0.0:22              0.0.0.0:*       users:(("sshd",pid=551,fd=3))
    LISTEN   0        5               127.0.0.1:631             0.0.0.0:*       users:(("cupsd",pid=439,fd=7))
    LISTEN   0        128                  [::]:22                 [::]:*       users:(("sshd",pid=551,fd=4))
    [...]

journalctl | grep sshd
    [...]
    oct. 25 11:00:18 node1.tp2.linux sshd[1162]: pam_unix(sshd:session): session closed for user leo
    oct. 25 11:05:04 node1.tp2.linux sshd[1310]: Accepted password for leo from 192.168.56.1 port 62637 ssh2
    [...]
```


Connectez vous au serveur
```
ssh leo@192.168.56.117
    leo@192.168.56.117's password:
    Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-38-generic x86_64)
    [...]
```


Modifier le comportement du service
```
sudo nano /etc/ssh/sshd_config
cat /etc/ssh/sshd_config
    [...]
    Port 2000
    [...]
sudo systemctl restart ssh
sudo ss -ltpn | grep sshd
    LISTEN    0         128                0.0.0.0:2000             0.0.0.0:*        users:(("sshd",pid=537,fd=3))          
    LISTEN    0         128                   [::]:2000                [::]:*        users:(("sshd",pid=537,fd=4))   
```


Connectez vous sur le nouveau port choisi
```
ssh -p 2000 leo@192.168.56.117
    leo@192.168.56.117's password:
    Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-38-generic x86_64)
    [...]
```




## Partie 2 : FTP

Installer le paquet vsftpd
```
sudo apt install vsftpd
    [...]
    The following NEW packages will be installed:
    vsftpd
    [...]
```


Lancer le service vsftpd
```
sudo systemctl start vsftpd
sudo systemctl status vsftpd
    ● vsftpd.service - vsftpd FTP server
        Loaded: loaded (/lib/systemd/system/vsftpd.service; enabled; vendor preset: enabled)
        Active: active (running) since Mon 2021-11-01 16:57:39 CET; 2min 23s ago
    [...]
```


Analyser le service en cours de fonctionnement
```
systemctl status vsftpd
    ● vsftpd.service - vsftpd FTP server
        Loaded: loaded (/lib/systemd/system/vsftpd.service; enabled; vendor preset: enabled)
        Active: active (running) since Mon 2021-10-25 12:28:54 CEST; 5min ago
    [...]

sudo ps -e | grep vsftpd
   1797 ?        00:00:00 vsftpd

sudo ss -ltpn | grep vsftpd
    LISTEN    0         32                       *:21                     *:*        users:(("vsftpd",pid=1797,fd=3))

journalctl | grep vsftpd
    nov. 01 16:57:36 node1.tp2.linux sudo[1625]:      leo : TTY=pts/1 ; PWD=/home/leo ; USER=root ; COMMAND=/usr/bin/apt install vsftpd
    [...]
```


Connectez vous au serveur
```
sudo nano /etc/vsftpd.conf
sudo cat /etc/vsftpd.conf
    [...]
    local_enable=YES
    [...]
    anon_upload_enable=YES
    [...]
    xferlog_enable=YES
    [...]
    xferlog_file=/var/log/vsftpd.log
    [...]

sudo systemctl restart vsftpd.service
```
> Depuis FileZilla.
```
Statut :	Connexion à 192.168.56.117:21...
Statut :	Connexion établie, attente du message d'accueil...
Statut :	Serveur non sécurisé, celui-ci ne supporte pas FTP sur TLS.
Statut :	Le serveur ne supporte pas les caractères non-ASCII.
Statut :	Connecté
```

Visualiser les logs
```
sudo cat /var/log/vsftpd.log
    [...]
    Mon Nov  1 17:25:17 2021 [pid 16655] [leo] OK UPLOAD: Client "::ffff:192.168.56.1", "/home/leo/Desktop/TPupload", 15 bytes, 2.61Kbyte/sec
    [...]
    Mon Nov  1 17:25:21 2021 [pid 16658] [leo] OK DOWNLOAD: Client "::ffff:192.168.56.1", "/home/leo/Desktop/TP", 15 bytes, 16.61Kbyte/sec
```


Modifier le comportement du service
```
sudo nano /etc/vsftpd.conf
sudo cat /etc/vsftpd.conf
    [...]
    listen_port=2001
    [...]
    ferlog_std_format=YES
    [...]

sudo systemctl restart vsftpd.service
sudo ss -ltpn
    State                   Recv-Q                  Send-Q                                   Local Address:Port                                   Peer Address:Port                  Process
    [...]
    LISTEN                  0                       32                                                   *:2001                                              *:*                      users:(("vsftpd",pid=16933,fd=3))
    [...]
```


Connectez vous sur le nouveau port choisi
> Depuis FileZilla.
```
Statut :	Connexion à 192.168.56.117:2001...
[...]
Statut :	Connecté
Statut :	Démarrage de l'envoi de C:\Users\lgran\Desktop\Cours\Cours-linux\CR TP1.md
Statut :	Transfert de fichier réussi, 3,322 octets transférés en 1 seconde
Statut :	Démarrage du téléchargement de /home/leo/Desktop/CR TP1.md
Statut :	Transfert de fichier réussi, 3,322 octets transférés en 1 seconde
```

> Depuis la VM
```
sudo cat /var/log/vsftpd.log
    [...]
    Mon Nov  1 17:53:32 2021 [pid 16950] [leo] OK UPLOAD: Client "::ffff:192.168.56.1", "/home/leo/Desktop/CR TP1.md", 3322 bytes, 663.69Kbyte/sec
    [...]
    Mon Nov  1 17:53:59 2021 [pid 16954] [leo] OK DOWNLOAD: Client "::ffff:192.168.56.1", "/home/leo/Desktop/CR TP1.md", 3322 bytes, 4729.07Kbyte/sec
```




## Partie 3 : Création de votre propre service

Donnez les deux commandes pour établir ce petit chat avec netcat

> Depuis la VM
```
nc -l 2020

```

> Depuis le PC
```
C:\Users\lgran\Desktop\Cours\Cours-linux\netcat> .\nc.exe
Cmd line: 192.168.56.117 2020

```


Utiliser netcat pour stocker les données échangées dans un fichier
```
nano Desktop/chat.txt
nc -l 2020 > ./Desktop/chat.txt
    Comment tu vas ?

cat Desktop/chat.txt
    Bien
```

Créer un nouveau service
```
sudo nano /etc/systemd/system/chat_tp2.service
sudo cat /etc/systemd/chat_tp2.service
    [Unit]
    Description=Little chat service (TP2)

    [Service]
    ExecStart=/usr/bin/nc -l 2020

    [Install]
    WantedBy=multi-user.target

sudo chmod 777 /etc/systemd/system/chat_tp2.service
sudo systemctl daemon-reload
```


Tester le nouveau service
```
sudo systemctl start chat_tp2.service
systemctl status chat_tp2.service
    ● chat_tp2.service - Little chat service (TP2)
        Loaded: loaded (/etc/systemd/system/chat_tp2.service; disabled; vendor preset: enabled)
        Active: active (running) since Mon 2021-11-01 18:39:19 CET; 1s ago
    [...]

sudo ss -ltpn
    State    Recv-Q   Send-Q     Local Address:Port     Peer Address:Port   Process
    [...]
    LISTEN   0        1                0.0.0.0:2020          0.0.0.0:*       users:(("nc",pid=17289,fd=3))
    [...]
```

> Depuis le PC
```
C:\Users\lgran\Desktop\Cours\Cours-linux\netcat> .\nc.exe
Cmd line: 192.168.56.117 2020
Hello World !
```

> Depuis la VM
```
journalctl -xe -u chat_tp2 -f
    [...]
    nov. 01 18:40:43 node1.tp2.linux nc[17420]: Bonjour
```