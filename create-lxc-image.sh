#!/bin/sh
# this script uses lxc to create one initial container
# The second part is to generate all the required metadata for lxd
DISTRIBUTION=jessie
ARCH=amd64
IMAGE_NAME=${DISTRIBUTION}64

sudo MIRROR=http://httpredir.debian.org/debian lxc-create -n ${IMAGE_NAME} -t debian -- -r ${DISTRIBUTION} -a ${ARCH}
mkdir -p ./${IMAGE_NAME}/templates
cat << EOF > ./${IMAGE_NAME}/metadata.yaml
{
    "architecture": "x86_64",
    "creation_date": 1455748920,
    "properties": {
        "architecture": "x86_64",
        "description": "debian ${DISTRIBUTION} x86_64 (default) (20160217_22:42)",
        "name": "debian-${DISTRIBUTION}-x86_64-default-20160217_22:42",
        "os": "debian",
        "release": "${DISTRIBUTION}",
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
EOF
echo '{{ container.name }}' > ./${IMAGE_NAME}/templates/hostname.tpl
cat << EOF > ./${IMAGE_NAME}/templates/hosts.tpl
127.0.0.1   localhost
127.0.1.1   {{ container.name }}

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

cd ./${IMAGE_NAME}/ && tar caf /tmp/${IMAGE_NAME}-lxd.tar.xz *
sudo bash -c "cd /var/lib/lxc/${IMAGE_NAME}/ && tar caf /tmp/${IMAGE_NAME}-rootfs.tar.xz *"
sudo chown ubuntu:ubuntu /tmp/${IMAGE_NAME}-*.tar.xz

