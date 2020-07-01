#!/bin/sh
if [ `id -u` -eq 0 ]
then
  sed ':b;/IfModule mpm_prefork_module/ba;n;bb;:a;s/\(StartServers\).*/\1           '$APACHE_MPM_STARTSERVERS'/;n;/\/IfModule/b;ba' -i /etc/apache2/mods-available/mpm_prefork.conf
  sed ':b;/IfModule mpm_prefork_module/ba;n;bb;:a;s/\(MinSpareServers\).*/\1        '$APACHE_MPM_MINSPARESERVERS'/;n;/\/IfModule/b;ba' -i /etc/apache2/mods-available/mpm_prefork.conf
  sed ':b;/IfModule mpm_prefork_module/ba;n;bb;:a;s/\(MaxSpareServers\).*/\1        '$APACHE_MPM_MAXSPARESERVERS'/;n;/\/IfModule/b;ba' -i /etc/apache2/mods-available/mpm_prefork.conf
  sed ':b;/IfModule mpm_prefork_module/ba;n;bb;:a;s/\(MaxRequestWorkers\).*/\1      '$APACHE_MPM_MAXREQUESTWORKERS'/;n;/\/IfModule/b;ba' -i /etc/apache2/mods-available/mpm_prefork.conf
  sed ':b;/IfModule mpm_prefork_module/ba;n;bb;:a;s/\(MaxConnectionsPerChild\).*/\1 '$APACHE_MPM_MAXCONNECTIONSPERCHILD'/;n;/\/IfModule/b;ba' -i /etc/apache2/mods-available/mpm_prefork.conf
fi

exec $@
