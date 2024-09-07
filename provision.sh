#!/bin/bash
set -u  # Treat unset variables as an error when substituting.
set -v  # Print shell input lines as they are read.

# установка утилит для работы с SELinux
dnf install --quiet --assumeyes setools-console setroubleshoot-server

# установка и настройка nginx:
dnf install --quiet --assumeyes nginx
sed '/\blisten\b/ s/\b80;/4881;/' -i /etc/nginx/nginx.conf
systemctl enable nginx.service
systemctl start nginx.service

# получаем ошибку запуска nginx из его лога:
cat /var/log/nginx/error.log

# расшифровываем Access Vector Cache событие аудита SELinux:
sealert --analyze /var/log/audit/audit.log

# из ошибки видно, что домену httpd_t запрещена операция name_bind на порту 4881
# класса tcp_socket, поищем похожие правила с помощью sesearch:
seinfo --portcon=4881
sesearch --allow --source httpd_t --class tcp_socket --perms name_bind
sesearch --allow --source httpd_t --class tcp_socket \
  --target unreserved_port_t --perms name_bind

# порт 4881 присутствует только в unreserved_port_t и его нет в политиках,
# которые разрешают операцию name_bind за исключением выключенной политики:
# allow nsswitch_domain unreserved_port_t:tcp_socket name_bind;
# [ nis_enabled ]:True

# включим политику nis_enabled и попробуем запустить nginx
setsebool -P nis_enabled=true
systemctl start nginx

# отключим политику nis_enabled и перезапустим nginx
setsebool -P nis_enabled=false
systemctl restart nginx

# добавим порт 4881 в тип http_port_t и запустим nginx:
semanage port --list | grep '^http_port_t\b'
semanage port --add --type http_port_t --proto tcp 4881
semanage port --list | grep '^http_port_t\b'
systemctl start nginx

# удалим порт 4881 из типа http_port_t и перезапустим nginx:
semanage port --delete --type http_port_t --proto tcp 4881
systemctl restart nginx

# сгенерируем и запустим модуль, разрешающий работу nginx:
ausearch --input-logs --comm nginx --raw \
  | audit2allow --module-package my-nginx
semodule --priority="300" --install="my-nginx.pp"
semodule --list=full | grep my-nginx
systemctl start nginx

# удалим модуль и перезапустим nginx:
semodule --priority="300" --remove="my-nginx"
systemctl restart nginx

# добавим порт 4881 в тип http_port_t и запустим nginx:
semanage port --add --type http_port_t --proto tcp 4881
systemctl start nginx
