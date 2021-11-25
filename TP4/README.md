# TP4 : Une distribution orientée serveur

## Sommaire

- [TP4 : Une distribution orientée serveur](#tp4--une-distribution-orientée-serveur)
  - [Sommaire](#sommaire)
- [I. Checklist](#i-checklist)
- [II. Mettre en place un service](#ii-mettre-en-place-un-service)
  - [1. Intro NGINX](#1-intro-nginx)
  - [2. Install](#2-install)
  - [3. Analyse](#3-analyse)
  - [4. Visite du service web](#4-visite-du-service-web)
  - [5. Modif de la conf du serveur web](#5-modif-de-la-conf-du-serveur-web)


# I. Checklist

🌞 **Choisissez et définissez une IP à la VM**
```
[leo@localhost ~]$ cat /etc/sysconfig/network-scripts/ifcfg-enp0s8
BOOTPROTO=static
IPADDR=10.200.1.2
NAME=enp0s8
NETMASK=255.255.255.0
DEVICE=enp0s8
ONBOOT=yes
```
```
[leo@localhost ~]$ ip a | grep enp0s8
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 10.200.1.2/24 brd 10.200.1.255 scope global noprefixroute enp0s8
```

🌞 **Vous me prouverez que :**

- le service ssh est actif sur la VM
- vous pouvez vous connecter à la VM, grâce à un échange de clés

```
[leo@localhost ~]$ systemctl status sshd.service
● sshd.service - OpenSSH server daemon
Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
Active: active (running) since Tue 2021-11-23 10:57:48 CET; 42min ago
    Docs: man:sshd(8)
        man:sshd_config(5)
Main PID: 862 (sshd)
    Tasks: 1 (limit: 11408)
Memory: 5.9M
CGroup: /system.slice/sshd.service
        └─862 /usr/sbin/sshd -D -oCiphers=aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes256->

[...]
Nov 23 11:38:54 localhost.localdomain sshd[5670]: pam_unix(sshd:session): session opened for user leo by (uid=0)
```
Sur le pc
```
PS C:\Users\lgran> cat .\.ssh\id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMFct1gNOGKJ7t/J4luT8/f4tyssgu/ltsY6/[...]== lgran@LeoZenbook
```

Sur la VM
```
[leo@localhost ~]$ cat /home/leo/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMFct1gNOGKJ7t/J4luT8/f4tyssgu/ltsY6/[...]== lgran@LeoZenbook
```
```
PS C:\Users\lgran> ssh leo@10.200.1.2
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Tue Nov 23 11:38:54 2021 from 10.200.1.1
```

🌞 **Prouvez que vous avez un accès internet**

```
[leo@localhost ~]$ ping -c 2 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=26.5 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=26.6 ms

--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 26.499/26.539/26.579/0.040 ms
```

🌞 **Prouvez que vous avez de la résolution de nom**

```
[leo@localhost ~]$ ping -c 2 google.com
PING google.com (142.250.74.238) 56(84) bytes of data.
64 bytes from par10s40-in-f14.1e100.net (142.250.74.238): icmp_seq=1 ttl=114 time=24.3 ms
64 bytes from par10s40-in-f14.1e100.net (142.250.74.238): icmp_seq=2 ttl=114 time=23.6 ms

--- google.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 23.585/23.923/24.262/0.372 ms
```

🌞 **Définissez `node1.tp4.linux` comme nom à la machine**

```
[leo@node1 ~]$ cat /etc/hostname
node1.tp4.linux
```
```
[leo@node1 ~]$ hostname
node1.tp4.linux
```

# II. Mettre en place un service

## 1. Intro NGINX
## 2. Install
🌞 **Installez NGINX en vous référant à des docs online**

```
[leo@node1 ~]$ sudo dnf install nginx
Last metadata expiration check: 1:00:04 ago on Tue 23 Nov 2021 10:52:30 AM CET.
Dependencies resolved.
=====================================================================================================================
 Package                           Architecture Version                                        Repository       Size
=====================================================================================================================
Installing:
 nginx                             x86_64       1:1.14.1-9.module+el8.4.0+542+81547229         appstream       566 k
[...]
Install  61 Packages

Total download size: 15 M
Installed size: 45 M
Is this ok [y/N]: y
Downloading Packages:
[...]

Complete!
```
## 3. Analyse
🌞 **Analysez le service NGINX**
```
[leo@node1 ~]$ ps -ef | grep nginx
root        8470       1  0 11:54 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       8471    8470  0 11:54 ?        00:00:00 nginx: worker process
leo         8479    5795  0 11:55 pts/1    00:00:00 grep --color=auto nginx
```
```
[leo@node1 ~]$ sudo ss -ltpn | grep nginx
LISTEN 0      128          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=8471,fd=8),("nginx",pid=8470,fd=8))
LISTEN 0      128             [::]:80           [::]:*    users:(("nginx",pid=8471,fd=9),("nginx",pid=8470,fd=9))
```
```
[leo@node1 ~]$ cat /etc/nginx/nginx.conf
[...]
# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;
[...]
```
```
[leo@node1 ~]$ ls /usr/share/nginx/html/
404.html  50x.html  index.html  nginx-logo.png  poweredby.png
```
```
[leo@node1 ~]$ ls -al /usr/share/nginx/
total 4
drwxr-xr-x.  4 root root   33 Nov 23 11:52 .
drwxr-xr-x. 91 root root 4096 Nov 23 11:52 ..
drwxr-xr-x.  2 root root   99 Nov 23 11:52 html
drwxr-xr-x.  2 root root  143 Nov 23 11:52 modules
```


## 4. Visite du service web
🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX** (c'est du TCP ;) )
```
[leo@node1 ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
```
```
[leo@node1 ~]$ sudo firewall-cmd --reload
success
```

🌞 **Tester le bon fonctionnement du service**


```
[leo@node1 ~]$ curl http://10.200.1.2:80 | head -n 1
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3429  100  3429    0     0  3348k      0 --:--:-- --:--:-- --:--:-- 3348k
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
```

## 5. Modif de la conf du serveur web
🌞 **Changer le port d'écoute**

```
[leo@node1 ~]$ cat /etc/nginx/nginx.conf | grep 80
        listen       8080 default_server;
        listen       [::]:8080 default_server;
```
```
[leo@node1 ~]$ sudo systemctl restart nginx.service
systemctl status nginx.service
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2021-11-23 12:20:22 CET; 57s ago
[...]
```
```
[leo@node1 ~]$ sudo ss -ltpn | grep nginx
LISTEN 0      128          0.0.0.0:8080      0.0.0.0:*    users:(("nginx",pid=8783,fd=8),("nginx",pid=8782,fd=8))
LISTEN 0      128             [::]:8080         [::]:*    users:(("nginx",pid=8783,fd=9),("nginx",pid=8782,fd=9))
```
```
[leo@node1 ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
```
```
[leo@node1 ~]$ sudo firewall-cmd --add-port=8080/tcp --permanent
success
```
```
[leo@node1 ~]$ sudo firewall-cmd --reload
success
```
```
[leo@node1 ~]$ curl http://10.200.1.2:8080 | head -n 1
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3429  100  3429    0     0  3348k      0 --:--:-- --:--:-- --:--:-- 3348k
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
```

🌞 **Changer l'utilisateur qui lance le service**

```
[leo@node1 ~]$ sudo useradd web -m
useradd: warning: the home directory already exists.
Not copying any file from skel directory into it.
Creating mailbox file: File exists
```
```
[leo@node1 ~]$ ls /home/
leo  web
```
```
[leo@node1 ~]$ sudo passwd web
Changing password for user web.
New password:
BAD PASSWORD: The password is shorter than 8 characters
Retype new password:
passwd: all authentication tokens updated successfully.
```
```
[leo@node1 ~]$ cat /etc/nginx/nginx.conf | grep user
user web;
[leo@node1 ~]$ ps -ef | grep nginx
root        8966       1  0 12:32 ?        00:00:00 nginx: master process /usr/sbin/nginx
web         8967    8966  0 12:32 ?        00:00:00 nginx: worker process
```

🌞 **Changer l'emplacement de la racine Web**

```
[leo@node1 ~]$ sudo mkdir /var/www/
[leo@node1 ~]$ sudo mkdir /var/www/super_site_web
[leo@node1 ~]$ sudo chmod 777 /var/www/
[leo@node1 ~]$ sudo su - web
[web@node1 ~]$ cd /var/www/
[web@node1 www]$ mkdir super_site_web
[web@node1 super_site_web]$ nano index.html
[web@node1 super_site_web]$ exit
```
```
[leo@node1 ~]$ sudo nano /etc/nginx/nginx.conf
[leo@node1 ~]$ sudo systemctl restart nginx.service
[leo@node1 ~]$ sudo systemctl status nginx.service
[leo@node1 ~]$ cat /etc/nginx/nginx.conf | grep /var/www
        root         /var/www/super_site_web;
[leo@node1 ~]$ curl 10.200.1.2:8080 | head -n 1
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    64  100    64    0     0  64000      0 --:--:-- --:--:-- --:--:-- 64000
<head>
```
