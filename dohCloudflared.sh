#!/bin/bash -e


echo
echo "=== azadrah.org ==="
echo "=== https://github.com/azadrah-org ==="
echo "=== DOH Installer (Cloudflared For Ubuntu 22.04 Server) ==="
echo
sleep 3

function exit_badly {
  echo "$1"
  exit 1
}

if [[ dist1=$(lsb_release -rs) == "18.04" ]] || [[ dist2=$(lsb_release -rs) == "20.04" ]]; then exit_badly "This script is for Ubuntu 22.04 only: aborting (if you know what you're doing, try deleting this check)"
else
[[ $(id -u) -eq 0 ]] || exit_badly "Please re-run as root (e.g. sudo ./path/to/this/script)"
fi

DEBIAN_FRONTEND=noninteractive



echo
echo "=== Update System ==="
echo
sleep 1

apt-get -o Acquire::ForceIPv4=true update
apt-get -o Acquire::ForceIPv4=true install -y software-properties-common
add-apt-repository --yes universe
add-apt-repository --yes restricted
add-apt-repository --yes multiverse
apt-get -o Acquire::ForceIPv4=true install -y moreutils dnsutils tmux screen nano wget curl socat

echo
echo "=== Configure Cloudflared ==="
echo
sleep 1

sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
sudo apt-get update && sudo apt-get install cloudflared
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
echo nameserver 127.0.0.1 | sudo tee /etc/resolv.conf >/dev/null

echo
echo "=== Finished ==="
echo
sleep 1