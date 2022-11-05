# DOH Cloudflared Installer For Ubuntu 22.04 Server
![](https://img.shields.io/github/issues/azadrahorg/dohCloudflared)

### Install
```bash
bash -c "$(curl -L https://raw.githubusercontent.com/azadrahorg/dohCloudflared/main/dohCloudflared.sh)"
```
### Manage
```bash
systemctl start cloudflared-proxy-dns
systemctl stop cloudflared-proxy-dns
systemctl restart cloudflared-proxy-dns
systemctl status cloudflared-proxy-dns
```
### Check Working
```bash
dig google.com | grep 127.0.0.1
```
You should see something like this

`;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)`
