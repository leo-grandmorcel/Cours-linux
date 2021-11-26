# TP5 : P'tit cloud perso

- [TP5 : P'tit cloud perso](#tp5--ptit-cloud-perso)
- [I. Setup DB](#i-setup-db)
  - [1. Install MariaDB](#1-install-mariadb)
  - [2. Conf MariaDB](#2-conf-mariadb)
  - [3. Test](#3-test)
- [II. Setup Web](#ii-setup-web)
  - [1. Install Apache](#1-install-apache)
    - [A. Apache](#a-apache)
    - [B. PHP](#b-php)
  - [2. Conf Apache](#2-conf-apache)
  - [3. Install NextCloud](#3-install-nextcloud)
  - [4. Test](#4-test)


# I. Setup DB

## 1. Install MariaDB

🌞 **Installer MariaDB sur la machine `db.tp5.linux`**
```
[leo@db ~]$ sudo dnf install mariadb-server
[sudo] password for leo:
[...]
Installing:
 mariadb-server                   x86_64       3:10.3.28-1.module+el8.4.0+427+adf35707         appstream        16 M
[...]
```

🌞 **Le service MariaDB**
```
[leo@db ~]$ sudo systemctl start mariadb.service
[leo@db ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
```
```
[leo@db ~]$ systemctl status mariadb.service
● mariadb.service - MariaDB 10.3 database server
   Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2021-11-25 11:17:02 CET; 24s ago
[...]
```
```
[leo@db ~]$ sudo ss -ltpn | grep mysqld
LISTEN 0      80                 *:3306            *:*    users:(("mysqld",pid=4742,fd=21))
[leo@db ~]$ sudo ps -e | grep mysqld
   4742 ?        00:00:00 mysqld
```

🌞 **Firewall**
```
[leo@db ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
[leo@db ~]$ sudo firewall-cmd --reload
success
```

## 2. Conf MariaDB

🌞 **Configuration élémentaire de la base**

Lors de l'installation, nous avons plusieurs questions tels que choisir un mot de passe pour l'utilisateur root, garder l'utilisateur par défaut (anonymous), désactiver la connexion à l'utilisateur root depuis internet, garder la database par défaut, et enfin confirmer les modifications.
```
[leo@db ~]$ mysql_secure_installation
[...]
Change the root password? [Y/n] n
 ... skipping.
[...]
Remove anonymous users? [Y/n] y
 ... Success!
[...]
Disallow root login remotely? [Y/n] y
 ... Success!
[...]
Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!
[...]
Reload privilege tables now? [Y/n] y
 ... Success!
[...]
All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

🌞 **Préparation de la base en vue de l'utilisation par NextCloud**
```
[leo@db ~]$ sudo mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 22
Server version: 10.3.28-MariaDB MariaDB Server
[...]
MariaDB [(none)]> CREATE USER 'nextcloud'@'10.5.1.11' IDENTIFIED BY 'azerty';
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.5.1.11';
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> Ctrl-C -- exit!
Aborted
```


## 3. Test

🌞 **Installez sur la machine `web.tp5.linux` la commande `mysql`**
```
[leo@web ~]$ dnf provides mysql
[...]
mysql-8.0.26-1.module+el8.4.0+652+6de068a7.x86_64 : MySQL client programs and shared libraries
Repo        : appstream
Matched from:
Provide    : mysql = 8.0.26-1.module+el8.4.0+652+6de068a7
[leo@web ~]$ sudo dnf install mysql
```


🌞 **Tester la connexion**
```
[leo@web ~]$ mysql --host=10.5.1.12 --port=3306 --user=nextcloud --password nextcloud
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 26
Server version: 5.5.5-10.3.28-MariaDB MariaDB Server
[...]

mysql> SHOW TABLES;
Empty set (0.00 sec)
```



# II. Setup Web

## 1. Install Apache
### A. Apache
🌞 **Installer Apache sur la machine `web.tp5.linux`**

```
[leo@web ~]$ sudo dnf install httpd
[sudo] password for leo:
Last metadata expiration check: 0:50:33 ago on Thu 25 Nov 2021 11:16:00 AM CET.
Dependencies resolved.
[leo@web ~]$ sudo systemctl start httpd
[leo@web ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
```

🌞 **Analyse du service Apache**
```
[leo@web ~]$ pstree | grep httpd
        |-httpd-+-httpd
        |       |-2*[httpd---64*[{httpd}]]
        |       `-httpd---80*[{httpd}]
[leo@web ~]$ sudo ss -ltpn | grep httpd
LISTEN 0      128                *:80              *:*    users:(("httpd",pid=5590,fd=4),("httpd",pid=5589,fd=4),("httpd",pid=5588,fd=4),("httpd",pid=5586,fd=4))
```

Processus lancé par apache
```
[leo@web ~]$ ps -ef | grep httpd
root        5586       1  0 12:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      5587    5586  0 12:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      5588    5586  0 12:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      5589    5586  0 12:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      5590    5586  0 12:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
leo         5841    5026  0 12:16 pts/0    00:00:00 grep --color=auto httpd
```

🌞 **Un premier test**
```
[leo@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[leo@web ~]$ sudo firewall-cmd --reload
success
```

```
PS C:\Users\lgran> curl 10.5.1.12
curl : HTTP Server Test Page
[...]
```


### B. PHP

🌞 **Installer PHP**
```
[leo@web ~]$ sudo dnf install epel-release
Last metadata expiration check: 1:09:47 ago on Thu 25 Nov 2021 11:16:00 AM CET.
Dependencies resolved.
[...]
Complete!
[leo@web ~]$ sudo dnf update
[...]
Last metadata expiration check: 0:00:01 ago on Thu 25 Nov 2021 12:26:28 PM CET.
Dependencies resolved.
Nothing to do.
Complete!
[leo@web ~]$ sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
[Last metadata expiration check: 0:01:38 ago on Thu 25 Nov 2021 12:26:28 PM CET.
[...]
Complete!
[leo@web ~]$ sudo dnf module enable php:remi-7.4
Last metadata expiration check: 1:37:13 ago on Fri 26 Nov 2021 09:19:36 AM CET.
Dependencies resolved.
Nothing to do.
Complete!
[leo@web ~]$ sudo dnf install zip unzip libxml2 openssl php74-php php74-php-ctype php74-php-curl php74-php-gd php74-php-iconv php74-php-json php74-php-libxml php74-php-mbstring php74-php-openssl php74-php-posix php74-php-session php74-php-xml php74-php-zip php74-php-zlib php74-php-pdo php74-php-mysqlnd php74-php-intl php74-php-bcmath php74-php-gmp
[...]
Complete!
```

## 2. Conf Apache

🌞 **Analyser la conf Apache**
```
[leo@web ~]$ cat /etc/httpd/conf/httpd.conf | tail -n 2
# Load config files in the "/etc/httpd/conf.d" directory, if any.
IncludeOptional conf.d/*.conf
```

🌞 **Créer un VirtualHost qui accueillera NextCloud**
```
[leo@db ~]$ sudo nano /etc/httpd/conf.d/nextcloud.conf
[leo@db ~]$ cat /etc/httpd/nextcloud.conf
<VirtualHost *:80>
  DocumentRoot /var/www/nextcloud/html/  # on précise ici le dossier qui contiendra le site : la racine Web
  ServerName  web.tp5.linux  # ici le nom qui sera utilisé pour accéder à l'application

  <Directory /var/www/nextcloud/html/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews

    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>

[leo@web ~]$ sudo systemctl restart httpd.service
```
🌞 **Configurer la racine web**

```
[leo@web ~]$ sudo mkdir /var/www/nextcloud/
[leo@web ~]$ sudo mkdir /var/www/nextcloud/html
[leo@db ~]$ sudo sudo chown apache /var/www/nextcloud/*
```

🌞 **Configurer PHP**
```
[leo@web ~]$ timedatectl | grep "Time zone"
                Time zone: Europe/Paris (CET, +0100)
[leo@db ~]$ sudo nano /etc/opt/remi/php74/php.ini
[leo@db ~]$ cat /etc/opt/remi/php74/php.ini | grep "date.timezone ="
;date.timezone = "Europe/Paris (CET, +0100)"
[leo@db ~]$ sudo systemctl restart httpd.service
```

## 3. Install NextCloud

🌞 **Récupérer Nextcloud**
```
[leo@db ~]$ curl -SLO https://download.nextcloud.com/server/releases/nextcloud-21.0.1.zip
``` 
🌞 **Ranger la chambre**
```
[leo@db ~]$ unzip nextcloud-21.0.1.zip
[leo@db ~]$ sudo mv nextcloud/* /var/www/nextcloud/html/
[leo@db ~]$ sudo mv nextcloud/.* /var/www/nextcloud/html/
[leo@db ~]$ sudo chown apache /var/www/nextcloud/html/*
[leo@db ~]$ sudo chown apache /var/www/nextcloud/html/.*
[leo@web ~]$ sudo rm -r nextcloud-21.0.1.zip | sudo rm -r nextcloud
```
## 4. Test

🌞 **Modifiez le fichier `hosts` de votre PC**
```
lgran@LeoZenbook MINGW64 /c/Windows/System32/drivers/etc
$ cat hosts | tail -n 2
10.5.1.11 web.tp5.linux
127.0.0.1 view-localhost # view localhost server
```

🌞 **Tester l'accès à NextCloud et finaliser son install'**
```
lgran@LeoZenbook MINGW64 ~ $ curl http://web.tp5.linux
StatusCode        : 200
StatusDescription : OK
Content           : <!DOCTYPE html>
                    <html class="ng-csp" data-placeholder-focus="false" lang="en" data-locale="en" >
[...]
```