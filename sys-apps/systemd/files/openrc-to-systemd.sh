#!/bin/bash

ROOT="${ROOT:-/}"

sd_enable() {
    local arg=
    for arg in ${1}; do
        echo systemctl --root="${ROOT}" --no-reload enable "${arg}.service"
    done
}

# Service translation definitions.
# This list is incomplete and may only
# handle the services vital for a successful boot.
SRV_NetworkManager="NetworkManager"
SRV_bumblebee="bumblebeed"
SRV_cpufrequtils="cpufrequtils"
SRV_cupsd="cups"
SRV_syslog_ng="syslog-ng"
SRV_ufw="ufw"
SRV_vixie_cron="vixie-cron"
SRV_x_setup="x-setup"

# Display Manager is defined inside /etc/conf.d/xdm
SRV_xdm="_get_dm"
_get_dm() {
    ( . "${ROOT}/etc/conf.d/xdm" && echo "${DISPLAYMANAGER:-xdm}" )
}


CONFIGURED_SERVICES=(
    $(find "${ROOT}/etc/runlevels"/{boot,default} -type l \
        -printf "%f\n" | sort | uniq)
)

for srv in "${CONFIGURED_SERVICES[@]}"; do
    eval sd_service='$SRV'_$(echo ${srv} | tr "[\-\.]" "_")
    if [[ ${sd_service} =~ ^_.* ]]; then
        sd_enable $(${sd_service})
    elif [ -n "${sd_service}" ]; then
        sd_enable ${sd_service}
    fi
done
