#!/bin/bash
# shellcheck disable=SC2181,SC2002
#https://lists.linuxcontainers.org/pipermail/lxc-users/2013-December/005998.html
#https://stackoverflow.com/questions/20010199/how-to-determine-if-a-process-runs-inside-lxc-docker

if [[ "$EUID" -eq 0 ]]
then
        container=$(cat /proc/1/environ | tr '\0' '\n' | grep ^container=|cut -d '=' -f 2)
        if [ "$?" -ne 0 ]
        then
                unset -v container
        fi
fi

if [ -z "$container" ]; then
        container=$(systemd-detect-virt)
        if [ "$?" -ne 0 ]
        then
                unset -v container
        fi
fi


# Detect docker
if [ -z "$container" ]; then
    [ -f "/.dockerenv" ] && container=docker
fi
# Detect old-style libvirt
if [ -z "$container" ]; then
    [ -n "$LIBVIRT_LXC_UUID" ] && container=lxc-libvirt
fi
# Detect OpenVZ containers
if [ -z "$container" ]; then
    [ -d /proc/vz ] && [ ! -d /proc/bc ] && container=openvz
fi
 
# Detect vserver
if [ -z "$container" ]; then
    VXID="$(cat /proc/self/status | grep ^VxID | cut -f2)" || true
    [ "${VXID:-0}" -gt 1 ] && container=vserver
fi

if [ ! -z "$container" ]
then
        echo "$container "
        exit 0
else
        exit 1
fi
