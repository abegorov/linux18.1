# Практика с SELinux

## Задание

Запустить **nginx** на нестандартном порту 3-мя разными способами:

- переключатели **setsebool**;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля **SELinux**.

## Реализация

После загрузки запускается скрипт **[provision.sh](provision.sh)**, который выполняет действия в задании (в скрипте присутствуют комментарии). Лог выполнения скрипта представлен в файле **[provision.log](provision.log)**. В [Vagrantfile](Vagrantfile) изначально проброшен порт **4881** гостевой системы на адрес **127.0.0.1:4881** хоста. Поэтому, доступность **nginx** можно проверить открыв на хосте адрес [http://127.0.0.1:4881](http://127.0.0.1:4881).

## Запуск

Необходимо скачать **VagrantBox** для **almalinux/9** версии **v9.4.20240805** и добавить его в **Vagrant** под именем **almalinux/9/v9.4.20240805'**. Сделать это можно командами:

```shell
curl -OL https://app.vagrantup.com/almalinux/boxes/9/versions/9.4.20240805/providers/virtualbox/amd64/vagrant.box
vagrant box add vagrant.box --name "almalinux/9/v9.4.20240805"
rm vagrant.box
```

После этого нужно сделать **vagrant up**.

Протестировано в **OpenSUSE Tumbleweed**:

- **Vagrant 2.3.7**
- **VirtualBox 7.0.20_SUSE r163906**
- **Ansible 2.17.3**
- **Python 3.11.9**
- **Jinja2 3.1.4**
