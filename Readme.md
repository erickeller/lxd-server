# LXD server

The intension of these vagrant boxes is to setup a lxd server where lxc clients can get there images from.
With the help of Stephan Graber https://github.com/lxc/lxd/issues/1581 I setup this little playground.

# Prerequisites

Install vagrant: https://www.vagrantup.com/downloads.html

# Getting started

`vagrant up --provider virtualbox --provision`

After some time (grabbing Ubuntu virtual box) you should be able to have both client and server automatically configured.
Notice: select the appropriate interface to bridge if vagrant ask. 

lxcserver:
192.168.33.8:8443

lxcclient:
192.168.33.9

# Provision

both provision scripts do the basic installation and configuration of lxd on both server and client side.
have a look at the script for more information.

# Playing around

use `vagrant ssh lxcclient` in order to ssh to the client box.

1) [lxcclient] create a jessie 64bit container

`sudo MIRROR=http://httpredir.debian.org/debian lxc-create -n jessie64 -t debian -- -r jessie -a amd64`

2) [lxcclient] add some metadata

```
sudo bash -c 'cat << EOF > /var/lib/lxc/jessie64/metadata.yaml
{
    "architecture": "x86_64",
    "creation_date": 1455748920,
    "properties": {
        "architecture": "x86_64",
        "description": "debian jessie x86_64 (default) (20160217_22:42)",
        "name": "debian-jessie-x86_64-default-20160217_22:42",
        "os": "debian",
        "release": "jessie",
        "variant": "default"
    },
    "templates": {
        "/etc/hostname": {
            "template": "hostname.tpl",
            "when": [
                "create"
            ]
        },
        "/etc/hosts": {
            "template": "hosts.tpl",
            "when": [
                "create"
            ]
        }
    }
}
EOF'
```

let's create the templates

```
sudo bash -c "mkdir -p /var/lib/lxc/jessie64/templates && echo '{{ container.name }}' > /var/lib/lxc/jessie64/templates/hostname.tpl"
sudo bash -c 'cat << EOF > /var/lib/lxc/jessie64/templates/hosts.tpl
127.0.0.1   localhost
127.0.1.1   {{ container.name }}

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF'
```

3) [lxcclient] package the lxc to an lxd image

```
sudo bash -c 'cd /var/lib/lxc/jessie64/ && tar caf /tmp/jessie64.tar.gz * && chown ubuntu:ubuntu /tmp/jessie64.tar.gz'
```

4) [lxcclient] add lxd server as remote

```
lxc remote add mylxd 192.168.33.8 --accept-certificate --password=unsecret
```

5) [lxcclient] import the jessie64 tarball to the local image store

```
lxc image import /tmp/jessie64.tar.gz --alias jessie64 --public
lxc image list
```

5.1) [lxcclient] import the jessie64 tarball to the remote image store

```
lxc image import /tmp/jessie64.tar.gz mylxd: --alias jessie64 --public
```

6) [lxcclient] copy image to the server

Note: This is optional if you used executed the 5.1 step

```
lxc image copy jessie64 mylxd: --copy-aliases --public
lxc image list mylxd:
```

7) [lxcclient] remove local image

```
lxc image delete jessie64
lxc image copy mylxd:jessie64 local: --copy-aliases
lxc image list
```

8) [lxcclient] create new container from image

```
lxc launch jessie64 mylxc
```

9) [lxcclient] execute bash in container

```
lxc exec mylxc /bin/bash
```

The End!
