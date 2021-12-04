# TP6 : Stockage et sauvegarde

# Sommaire

- [TP6 : Stockage et sauvegarde](#tp6--stockage-et-sauvegarde)
- [Sommaire](#sommaire)
- [Partie 1 : Préparation de la machine `backup.tp6.linux`](#partie-1--préparation-de-la-machine-backuptp6linux)
  - [I. Ajout de disque](#i-ajout-de-disque)
  - [II. Partitioning](#ii-partitioning)
  - [III. Bonus](#iii-bonus)
- [Partie 2 : Setup du serveur NFS sur `backup.tp6.linux`](#partie-2--setup-du-serveur-nfs-sur-backuptp6linux)
- [Partie 3 : Setup des clients NFS : `web.tp6.linux` et `db.tp6.linux`](#partie-3--setup-des-clients-nfs--webtp6linux-et-dbtp6linux)
- [Partie 4 : Scripts de sauvegarde](#partie-4--scripts-de-sauvegarde)
  - [I. Sauvegarde Web](#i-sauvegarde-web)
  - [II. Sauvegarde base de données](#ii-sauvegarde-base-de-données)
  - [III. Check sur la machine backup](#iii-check-sur-la-machine-backup)

# Partie 1 : Préparation de la machine `backup.tp6.linux`

## I. Ajout de disque

🌞 **Ajouter un disque dur de 5Go à la VM `backup.tp6.linux`**
```
[leo@backup ~]$ lsblk | grep sdb
sdb           8:16   0    5G  0 disk
```

## II. Partitioning

🌞 **Partitionner le disque à l'aide de LVM**

- créer un *physical volume (PV)* : le nouveau disque ajouté à la VM
```
[leo@backup ~]$ sudo pvcreate /dev/sdb
[sudo] password for leo:
  Physical volume "/dev/sdb" successfully created.
[leo@backup ~]$ sudo pvs
  PV         VG Fmt  Attr PSize  PFree
  /dev/sda2  rl lvm2 a--  <7.00g    0
  /dev/sdb      lvm2 ---   5.00g 5.00g
[leo@backup ~]$ sudo pvdisplay
 [...]
  "/dev/sdb" is a new physical volume of "5.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name
  PV Size               5.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               dgX71v-rPQU-TMuE-eCpx-d9d3-EGi9-kqs32k
```
- créer un nouveau *volume group (VG)*
```
[leo@backup ~]$ sudo vgcreate backup /dev/sdb
  Volume group "backup" successfully created
[leo@backup ~]$ sudo vgs
  VG     #PV #LV #SN Attr   VSize  VFree
  backup   1   0   0 wz--n- <5.00g <5.00g
  rl       1   2   0 wz--n- <7.00g     0
[leo@backup ~]$ sudo vgdisplay
  --- Volume group ---
  VG Name               backup
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <5.00 GiB
  PE Size               4.00 MiB
  Total PE              1279
  Alloc PE / Size       0 / 0
  Free  PE / Size       1279 / <5.00 GiB
  VG UUID               Bdn8EC-CD7Z-UbGh-h2S3-6ntD-TVpZ-xAUjVF
[...]
```

- créer un nouveau *logical volume (LV)* : ce sera la partition utilisable
```
[leo@backup ~]$ sudo lvcreate -l 100%FREE backup -n stockage
  Logical volume "stockage" created.
[leo@backup ~]$ sudo lvs
  LV       VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  stockage backup -wi-a-----  <5.00g
  root     rl     -wi-ao----  <6.20g
  swap     rl     -wi-ao---- 820.00m
[leo@backup ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/backup/stockage
  LV Name                stockage
  VG Name                backup
  LV UUID                vlLDUr-vH1x-fu2B-sZEy-d9nC-PhBJ-SGQB4R
  LV Write Access        read/write
  LV Creation host, time backup.tp6.linux, 2021-11-30 10:58:34 +0100
  LV Status              available
  # open                 0
  LV Size                <5.00 GiB
  Current LE             1279
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2
[...]
```

🌞 **Formater la partition**
```
[leo@backup ~]$ sudo !!
sudo mkfs -t ext4 /dev/backup/stockage
[sudo] password for leo:
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 1309696 4k blocks and 327680 inodes
Filesystem UUID: 4eb39983-be87-4cb6-bc98-3b12123d6fff
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```

🌞 **Monter la partition**
```

[leo@backup ~]$ sudo mount /dev/backup/stockage /mnt/backup/
[leo@backup ~]$ df -h
Filesystem                   Size  Used Avail Use% Mounted on
devtmpfs                     892M     0  892M   0% /dev
tmpfs                        909M     0  909M   0% /dev/shm
tmpfs                        909M  8.5M  901M   1% /run
tmpfs                        909M     0  909M   0% /sys/fs/cgroup
/dev/mapper/rl-root          6.2G  2.1G  4.2G  34% /
/dev/sda1                   1014M  265M  750M  27% /boot
tmpfs                        182M     0  182M   0% /run/user/1000
/dev/mapper/backup-stockage  4.9G   20M  4.6G   1% /mnt/backup
[leo@backup ~]$ ls -l /mnt/
total 4
drwxr-xr-x. 3 root root 4096 Nov 30 11:46 backup
```


```
[leo@backup ~]$ cat /etc/fstab | tail -n 1
/dev/backup/stockage /mnt/backup ext4 defaults 0 0
[leo@backup ~]$ sudo umount /mnt/backup
[leo@backup ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /mnt/backup does not contain SELinux labels.
       You just mounted an file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/mnt/backup              : successfully mounted
```

## III. Bonus


```
[leo@backup ~]$ sudo vgextend backup /dev/sdc
  Physical volume '/dev/sdc' is already in volume group 'backup'
  Unable to add physical volume '/dev/sdc' to volume group 'backup'
  /dev/sdc: physical volume not initialized.
[leo@backup ~]$ sudo lvextend -l +100%FREE /dev/backup/stockage
  New size (2558 extents) matches existing size (1294 extents).
[leo@backup ~]$ resize2fs /dev/backup/stockage
resize2fs 1.45.6 (20-Mar-2020)
open: Permission denied while opening /dev/backup/stockage
[leo@backup ~]$ sudo !!
sudo resize2fs /dev/backup/stockage
resize2fs 1.45.6 (20-Mar-2020)
Filesystem at /dev/backup/stockage is mounted on /mnt/backup; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
The filesystem on /dev/backup/stockage is now 2619392 (4k) blocks long.
[leo@backup ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/backup/stockage
  LV Name                stockage
  VG Name                backup
  LV UUID                9gMjKE-jH01-AVI8-YKdK-xFJj-oJxM-jYzP0S
  LV Write Access        read/write
  LV Creation host, time backup.tp6.linux, 2021-11-30 11:44:52 +0100
  LV Status              available
  # open                 1
  LV Size                9.99 GiB
  Current LE             2558
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2
[...]
```




# Partie 2 : Setup du serveur NFS sur `backup.tp6.linux`

🌞 Préparer les dossiers à partager
```
[leo@backup /]$ sudo mkdir backup
[leo@backup /]$ sudo mkdir /backup/web.tp6.linux
[leo@backup /]$ sudo mkdir /backup/db.tp6.linux
[leo@backup /]$ ls /backup/
```

🌞 Install du serveur NFS
```
[leo@backup /]$ sudo dnf install nfs-utils
[...]

Installed:
  gssproxy-0.8.0-19.el8.x86_64               keyutils-1.5.10-9.el8.x86_64          libevent-2.1.8-5.el8.x86_64
  libverto-libevent-0.3.0-5.el8.x86_64       nfs-utils-1:2.3.3-46.el8.x86_64       rpcbind-1.2.5-8.el8.x86_64

Complete!
```

🌞 Conf du serveur NFS
```
[leo@backup /]$ cat /etc/idmapd.conf | grep Domain | head -n 1
Domain = tp6.linux
[leo@backup /]$ cat /etc/exports
/backup/web.tp6.linux 10.5.1.0/24(rw,no_root_squash)
/backup/db.tp6.linux 10.5.1.0/24(rw,no_root_squash)
```
(rw,no_root_squash) donne les droits de lire et écrire mais empêche l'attribution de l'utilisateur root à un autre user.


🌞 Démarrez le service
```
[leo@backup /]$ sudo systemctl start nfs-server.service
[leo@backup /]$ sudo systemctl status nfs-server.service
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; disabled; vendor preset: disabled)
   Active: active (exited) since Tue 2021-11-30 12:46:44 CET; 8s ago
  Process: 24532 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=>
  Process: 24520 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
  Process: 24519 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
 Main PID: 24532 (code=exited, status=0/SUCCESS)

Nov 30 12:46:44 backup.tp6.linux systemd[1]: Starting NFS server and services...
Nov 30 12:46:44 backup.tp6.linux systemd[1]: Started NFS server and services.
[leo@backup /]$ sudo systemctl enable nfs-server.service
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
```


🌞 Firewall
```
[leo@backup /]$ sudo firewall-cmd --add-port=2049/tcp --permanent
success
[leo@backup /]$ sudo firewall-cmd --reload
success
[leo@backup /]$ sudo ss -ltpn | grep 2049
LISTEN 0      64           0.0.0.0:2049       0.0.0.0:*
LISTEN 0      64              [::]:2049          [::]:*
```

# Partie 3 : Setup des clients NFS : `web.tp6.linux` et `db.tp6.linux`

```
[leo@web ~]$ sudo dnf install nfs-utils
[sudo] password for leo:
[...]
Installed:
  gssproxy-0.8.0-19.el8.x86_64               keyutils-1.5.10-9.el8.x86_64          libevent-2.1.8-5.el8.x86_64
  libverto-libevent-0.3.0-5.el8.x86_64       nfs-utils-1:2.3.3-46.el8.x86_64       rpcbind-1.2.5-8.el8.x86_64

Complete!
```

```
[leo@web ~]$ sudo mkdir /srv/backup
[leo@web ~]$ sudo nano /etc/idmapd.conf
[leo@web ~]$ cat /etc/idmapd.conf | grep Domain | head -n 1
Domain = tp6.linux
[leo@web ~]$ sudo systemctl restart nfs-server.service
[leo@web ~]$ sudo systemctl enable nfs-server.service
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[leo@web ~]$ sudo systemctl status nfs-server.service
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
   Active: active (exited) since Tue 2021-11-30 12:58:55 CET; 15s ago
 Main PID: 2729 (code=exited, status=0/SUCCESS)
    Tasks: 0 (limit: 11408)
   Memory: 0B
   CGroup: /system.slice/nfs-server.service

Nov 30 12:58:55 web.tp5.linux systemd[1]: Starting NFS server and services...
Nov 30 12:58:55 web.tp5.linux systemd[1]: Started NFS server and services.
```

🌞 Montage !
```
[leo@web ~]$ sudo mount -t nfs 10.5.1.13:/backup/web.tp6.linux/ /srv/backup
[leo@web ~]$ df -h | tail -n 1
10.5.1.13:/backup/web.tp6.linux  9.8G   23M  9.3G   1% /srv/backup
[leo@web ~]$ sudo chown leo /srv/backup/
[sudo] password for leo:
[leo@web ~]$ ls -l /srv/
total 4
drwxr-xr-x. 2 leo root 4096 Nov 30 12:36 backup
```
```
[leo@web ~]$ tail -n 1 /etc/fstab
10.5.1.13:/backup/web.tp6.linux/ /srv/backup nfs defaults 0 0
[leo@web ~]$ [leo@web ~]$ sudo umount /srv/backup
[leo@web ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount.nfs: timeout set for Tue Nov 30 13:14:54 2021
mount.nfs: trying text-based options 'vers=4.2,addr=10.5.1.13,clientaddr=10.5.1.11'
/srv/backup              : successfully mounted
```



🌞 Répétez les opérations sur db.tp6.linux
```
[leo@db ~]$ sudo dnf install nfs-utils
[sudo] password for leo:
[...]
Installed:
  gssproxy-0.8.0-19.el8.x86_64               keyutils-1.5.10-9.el8.x86_64          libevent-2.1.8-5.el8.x86_64
  libverto-libevent-0.3.0-5.el8.x86_64       nfs-utils-1:2.3.3-46.el8.x86_64       rpcbind-1.2.5-8.el8.x86_64

Complete!
[leo@db ~]$ sudo mkdir /srv/backup
[leo@db ~]$ sudo nano /etc/idmapd.conf
[leo@db ~]$ cat /etc/idmapd.conf | grep Domain | head -n 1
Domain = tp6.linux
[leo@db ~]$ sudo systemctl restart nfs-server.service
[leo@db ~]$ sudo systemctl enable nfs-server.service
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[leo@db ~]$ sudo systemctl status nfs-server.service
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
   Active: active (exited) since Tue 2021-11-30 13:21:17 CET; 14s ago
 Main PID: 2832 (code=exited, status=0/SUCCESS)
    Tasks: 0 (limit: 11408)
   Memory: 0B
   CGroup: /system.slice/nfs-server.service

Nov 30 13:21:17 db.tp6.linux systemd[1]: Starting NFS server and services...
Nov 30 13:21:17 db.tp6.linux systemd[1]: Started NFS server and services.
```
```
[leo@db ~]$ df -h | tail -n 1
10.5.1.13:/backup/db.tp6.linux  9.8G   23M  9.3G   1% /srv/backup
[leo@db ~]$ sudo chown leo /srv/backup/
[sudo] password for leo:
[leo@db ~]$ ls -l /srv/
total 4
drwxr-xr-x. 2 leo root 4096 Nov 30 12:37 backup
[leo@db ~]$ sudo nano /etc/fstab
[leo@db ~]$ tail -n 1 /etc/fstab
10.5.1.13:/backup/db.tp6.linux/ /srv/backup nfs defaults 0 0
[leo@db ~]$ sudo umount /srv/backup
[leo@db ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount.nfs: timeout set for Tue Nov 30 13:26:40 2021
mount.nfs: trying text-based options 'vers=4.2,addr=10.5.1.13,clientaddr=10.5.1.12'
/srv/backup              : successfully mounted
```


# Partie 4 : Scripts de sauvegarde

## I. Sauvegarde Web

📁 **Le script [`/srv/backup.sh`](/TP6/fichiers/backup.sh)**

📁 **Le service [`/etc/systemd/system/backup.service`](/TP6/fichiers/backup.service)**

📁 **Le timer [`/etc/systemd/system/backup.timer`](/TP6/fichiers/backup.timer)**

🌞 **Ecrire un script qui sauvegarde les données de NextCloud**
```
[leo@web ~]$ sudo mkdir /var/log/backup
[leo@web ~]$ sudo nano /var/log/backup/backup.log
[leo@web ~]$ sudo nano /srv/backup.sh
```
🌞 **Créer un service et un timer**

```
[leo@web ~]$ sudo nano /etc/systemd/system/backup.service
[leo@web ~]$ sudo nano /etc/systemd/system/backup.timer
[leo@web ~]$ sudo systemctl daemon-reload
[leo@web ~]$ sudo systemctl start backup.timer
[leo@web ~]$ sudo systemctl enable backup.timer
Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
[leo@web ~]$ sudo systemctl list-timers | grep backup
Fri 2021-12-03 17:10:00 CET  55min left   n/a                          n/a          backup.timer              backup.service
```
🌞 **Vérifier que vous êtes capables de restaurer les données**
```
[leo@web ~]$ ls /srv/backup
nexcloud_211203_171208.tar.gz
[leo@web ~]$ tar -xf /srv/backup/nexcloud_211203_171226.tar.gz
[leo@web ~]$ ls
nextcloud
[leo@web ~]$ ls nextcloud/html/
3rdparty  config       core      index.html  occ           ocs-provider  resources   themes
apps      console.php  cron.php  index.php   ocm-provider  public.php    robots.txt  updater
AUTHORS   COPYING      data      lib         ocs           remote.php    status.php  version.php
[leo@web ~]$ cat /var/log/backup/backup.log
[21/12/03 17:12:38] Backup /srv/backup/nexcloud_211203_171228.tar.gz created successfully.
```


## II. Sauvegarde base de données


📁 **Le script [`/srv/backup_db.sh`](/TP6/fichiers/backup_db.sh)**

📁 **Le service [`/etc/systemd/system/backup_db.service`](/TP6/fichiers/backup_db.service)**

📁 **Le service [`/etc/systemd/system/backup_db.timer`](/TP6/fichiers/backup_db.timer)**

🌞 **Ecrire un script qui sauvegarde les données de la base de données MariaDB**
```
[leo@db ~]$ sudo mkdir /var/log/backup
[leo@db ~]$ sudo nano /var/log/backup/backup_db.log
[leo@db ~]$ sudo nano /srv/backup_db.sh
```

🌞 **Créer un service et un timer**
```
[leo@db ~]$ sudo nano /etc/systemd/system/backup_db.service
[leo@db ~]$ sudo nano /etc/systemd/system/backup_db.timer
[leo@db ~]$ sudo systemctl daemon-reload
[leo@db ~]$ sudo systemctl start backup_db.timer
[leo@db ~]$ sudo systemctl enable backup_db.timer
Created symlink /etc/systemd/system/timers.target.wants/backup_db.timer → /etc/systemd/system/backup_db.timer.
[leo@db tmp]$ sudo systemctl list-timers | grep backup
Fri 2021-12-03 17:00:00 CET  32min left   n/a                          n/a          backup_db.timer              backup_db.service
```
🌞 **Vérifier que vous êtes capables de restaurer les données**
```
[leo@db tmp]$ ls /srv/backup
nextcloud_db_211203_161231.tar.gz
[leo@db tmp]$ tar -ztvf /srv/backup/nextcloud_db_211203_161231.tar.gz
-rw-r--r-- root/root    199202 2021-12-03 16:25 nextcloud.sql
[leo@db tmp]$ cat /var/log/backup/backup_db.log
[21/12/03 16:12:40] Backup /srv/backup/nextcloud_db_211203_161240.tar.gz created successfully.
```


## III. Check sur la machine backup

```
[leo@backup ~]$ tree /backup/
/backup/
├── db.tp6.linux
│   ├── nextcloud_db_211203_161231.tar.gz
│   └── nextcloud_db_211203_161240.tar.gz
├── lost+found [error opening dir]
└── web.tp6.linux
    ├── nexcloud_211203_181203.tar.gz
    ├── nexcloud_211203_191204.tar.gz
    └── nexcloud_211203_201203.tar.gz
```