# DOH Cloudflared Installer For Debian Ubuntu and CentOS

Cloudflare DOH Installer For Debian Ubuntu and CentOS

### Install
```bash
bash -c "$(curl -L https://raw.githubusercontent.com/azadrahorg/dohCloudflared/main/dohCloudflared.sh)"
```
### How to Manage
Start the service.
```
systemctl start cloudflared
```
View the status of the service.
```
systemctl status cloudflared
```
Restart the service.
```
systemctl restart cloudflared
```
Enable service.
```
systemctl enable cloudflared
```
Disable service.
```
systemctl disable cloudflared
```

### How to test DNS:
Run This Comamnd
```
dig google.com | grep 127.0.0.1
```
The output should be like below
```
From 127.0.0.1@53(UDP) in 0.2 ms
```

