ip VM 192.168.56.115
ip pc

changer le nom de la machine
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
Installer le paquet openssh-server
```
sudo apt install openssh-server
[...]
openssh-server is already the newest version (1:8.2p1-4ubuntu0.3).
0 upgraded, 0 newly installed, 0 to remove and 89 not upgraded.
```

Afficher le service SSH
```
cat /etc/systemd/system/sshd.service
[Unit]
Description=OpenBSD Secure Shell server
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target auditd.service
ConditionPathExists=!/etc/ssh/sshd_not_to_be_run

[Service]
EnvironmentFile=-/etc/default/ssh
ExecStartPre=/usr/sbin/sshd -t
ExecStart=/usr/sbin/sshd -D $SSHD_OPTS
ExecReload=/usr/sbin/sshd -t
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartPreventExitStatus=255
Type=notify
RuntimeDirectory=sshd
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target
Alias=sshd.service

```
Afficher le dossier de config ssh
```
ls /etc/ssh
moduli      ssh_config.d  sshd_config.d       ssh_host_ecdsa_key.pub  ssh_host_ed25519_key.pub  ssh_host_rsa_key.pub
ssh_config  sshd_config   ssh_host_ecdsa_key  ssh_host_ed25519_key    ssh_host_rsa_key          ssh_import_id
```

Lancer le service sshd
```
systemctl start sshd
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to start 'ssh.service'.
Authenticating as: leo,,, (leo)
Password:
==== AUTHENTICATION COMPLETE ===
```

vérifier que le service est actuellement actif avec une commande
```
systemctl status sshd
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-10-25 10:46:12 CEST; 34min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 517 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 551 (sshd)
      Tasks: 1 (limit: 2312)
     Memory: 4.1M
     CGroup: /system.slice/ssh.service
             └─551 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups

oct. 25 10:46:12 node1.tp2.linux systemd[1]: Starting OpenBSD Secure Shell server...
oct. 25 10:46:12 node1.tp2.linux sshd[551]: Server listening on 0.0.0.0 port 22.
oct. 25 10:46:12 node1.tp2.linux sshd[551]: Server listening on :: port 22.
oct. 25 10:46:12 node1.tp2.linux systemd[1]: Started OpenBSD Secure Shell server.
oct. 25 10:51:31 node1.tp2.linux sshd[1162]: Accepted password for leo from 192.168.56.1 port 60047 ssh2
oct. 25 10:51:31 node1.tp2.linux sshd[1162]: pam_unix(sshd:session): session opened for user leo by (uid=0)
oct. 25 11:05:04 node1.tp2.linux sshd[1310]: Accepted password for leo from 192.168.56.1 port 62637 ssh2
oct. 25 11:05:04 node1.tp2.linux sshd[1310]: pam_unix(sshd:session): session opened for user leo by (uid=0)
```

afficher le/les processus liés au service sshd
```
ps -e | grep sshd
    551 ?        00:00:00 sshd
   1310 ?        00:00:00 sshd
   1362 ?        00:00:00 sshd
```

afficher le port utilisé par le service sshd
```
 sudo ss -ltpn
[sudo] password for leo:
State    Recv-Q   Send-Q      Local Address:Port       Peer Address:Port   Process
LISTEN   0        4096        127.0.0.53%lo:53              0.0.0.0:*       users:(("systemd-resolve",pid=403,fd=13))
LISTEN   0        128               0.0.0.0:22              0.0.0.0:*       users:(("sshd",pid=551,fd=3))
LISTEN   0        5               127.0.0.1:631             0.0.0.0:*       users:(("cupsd",pid=439,fd=7))
LISTEN   0        128                  [::]:22                 [::]:*       users:(("sshd",pid=551,fd=4))
LISTEN   0        5                   [::1]:631                [::]:*       users:(("cupsd",pid=439,fd=6))
```

afficher les logs du service sshd
```
journalctl | grep sshd
[...]
oct. 25 11:00:18 node1.tp2.linux sshd[1162]: pam_unix(sshd:session): session closed for user leo
oct. 25 11:05:04 node1.tp2.linux sshd[1310]: Accepted password for leo from 192.168.56.1 port 62637 ssh2
[...]
```

Afficher les logs du services sshd
```
```

Connecter à la machine
```
ssh leo@192.168.56.115
leo@192.168.56.115's password:
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-38-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

89 updates can be applied immediately.
38 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

Your Hardware Enablement Stack (HWE) is supported until April 2025.
Last login: Mon Oct 25 11:05:04 2021 from 192.168.56.1
```

Modifier le comportement du service
```
sudo nano /etc/ssh/sshd_config
cat /etc/ssh/sshd_config
    [...]
    Port 2000
    [...]
```

```
sudo ss -ltpn | grep sshd
    LISTEN    0         128                0.0.0.0:2000             0.0.0.0:*        users:(("sshd",pid=537,fd=3))          
    LISTEN    0         128                   [::]:2000                [::]:*        users:(("sshd",pid=537,fd=4))   
```
```
sudo systemctl restart sshd
```

```
ssh -p 2000 leo@192.168.56.115
```




Partie 2

Installer le paquet vsftpd

```
sudo apt install vsftpd
    [...]
    The following NEW packages will be installed:
    vsftpd
    [...]
```

Lancer le service FTP

```
sudo systemctl start vsftpd
```

Etude du service FTP
```
systemctl status vsftpd
    ● vsftpd.service - vsftpd FTP server
        Loaded: loaded (/lib/systemd/system/vsftpd.service; enabled; vendor preset: enabled)
        Active: active (running) since Mon 2021-10-25 12:28:54 CEST; 5min ago
    [...]
sudo ps -e | grep vsftpd
   2355 ?        00:00:00 vsftpd

sudo ss -ltpn | grep vsftpd
    LISTEN    0         32                       *:21                     *:*        users:(("vsftpd",pid=2355,fd=3))

journalctl | grep vsftpd
    oct. 25 12:12:06 node1.tp2.linux sudo[1416]:      leo : TTY=pts/1 ; PWD=/home/leo ; USER=root ; COMMAND=/usr/bin/apt install vsftpd
    oct. 25 12:12:15 node1.tp2.linux systemd[1]: Starting vsftpd FTP server...
    oct. 25 12:12:15 node1.tp2.linux systemd[1]: Started vsftpd FTP server.
    [...]

```

Connectez vous au serveur

