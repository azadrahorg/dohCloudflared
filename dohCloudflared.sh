#!/bin/bash -e

echo
echo "=== azadrah.org ==="
echo "=== https://github.com/azadrahorg ==="
echo "=== DOH Installer (Cloudflared Installer) ==="
echo
sleep 3

function exit_badly {
  echo "$1"
  exit 1
}

error() {
    echo -e " \n $red Something Bad Happen $none \n "
}

DISTRO="$(awk -F= '/^NAME/{print tolower($2)}' /etc/os-release|awk 'gsub(/[" ]/,x) + 1')"
DISTROVER="$(awk -F= '/^VERSION_ID/{print tolower($2)}' /etc/os-release|awk 'gsub(/[" ]/,x) + 1')"

valid_os()
{
    case "$DISTRO" in
    "debiangnu/linux"|"ubuntu"|"centosstream")
        return 0;;
    *)
        echo "OS $DISTRO is not supported"
        return 1;;
    esac
}
if ! valid_os "$DISTRO"; then
    echo "Bye."
    exit 1
else
[[ $(id -u) -eq 0 ]] || exit_badly "Please re-run as root (e.g. sudo ./path/to/this/script)"
fi

echo
echo "=== Update System ==="
echo
sleep 1

if [[ $DISTRO == "ubuntu" ]] || [[ $DISTRO == "debiangnu/linux" ]]; then
apt-get -o Acquire::ForceIPv4=true update
apt-get -o Acquire::ForceIPv4=true install -y software-properties-common
add-apt-repository --yes universe
add-apt-repository --yes restricted
add-apt-repository --yes multiverse
apt-get -o Acquire::ForceIPv4=true upgrade
apt-get -o Acquire::ForceIPv4=true install -y moreutils dnsutils tmux screen nano wget curl socat
else
dnf -y upgrade --refresh
dnf -y install epel-release
dnf -y install bind-utils tmux screen nano wget curl socat
fi

echo
echo "=== Configure Cloudflared ==="
echo
sleep 1

function deb_base {
  mkdir -p --mode=0755 /usr/share/keyrings
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg |  tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
}
if [[ $DISTRO == "ubuntu" ]] && [[ $DISTROVER == "22.04" ]]; then
deb_base
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | tee /etc/apt/sources.list.d/cloudflared.list
apt-get update && apt-get install cloudflared
elif [[ $DISTRO == "ubuntu" ]] && [[ $DISTROVER == "20.04" ]]; then
deb_base
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared focal main' |  tee /etc/apt/sources.list.d/cloudflared.list
apt-get update && apt-get install cloudflared
elif [[ $DISTRO == "debiangnu/linux" ]] && [[ $DISTROVER == "10" ]]; then
deb_base
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared buster main' |  tee /etc/apt/sources.list.d/cloudflared.list
apt-get update && apt-get install cloudflared
elif [[ $DISTRO == "debiangnu/linux" ]] && [[ $DISTROVER == "11" ]]; then
deb_base
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared bullseye main' |  tee /etc/apt/sources.list.d/cloudflared.list
apt-get update && apt-get install cloudflared
elif [[ $DISTRO == "centosstream" ]]; then
dnf config-manager --add-repo https://pkg.cloudflare.com/cloudflared-ascii.repo -y
dnf -y install cloudflared
else
error
fi



tee /etc/systemd/system/cloudflared-proxy-dns.service >/dev/null <<EOF
[Unit]
Description=DNS over HTTPS (DoH) proxy client
Wants=network-online.target nss-lookup.target
Before=nss-lookup.target

[Service]
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
DynamicUser=yes
ExecStart=/usr/local/bin/cloudflared proxy-dns

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now cloudflared-proxy-dns
rm -f /etc/resolv.conf
grep -Fq 'azadrah-org' /etc/resolv.conf || echo '
# https://github.com/azadrahorg
nameserver 127.0.0.1
nameserver 1.1.1.1
nameserver 2606:4700:4700::1111
' >> /etc/resolv.conf

echo
echo "=== Finished ==="
echo
sleep 1
