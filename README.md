### Requirements (Choco)

```
choco install docker docker-compose putty
```

You should be on at least Windows 10 version 2004 or a later version of Windows 11.
Run `winver` to confirm.
**Windows Features**: **Virtual Machine Platform** and **Hyper-V** must be enabled in Windows. This can be done via the "Turn Windows features on or off" in the Control Panel.

### Prepare Windows

```powershell
New-Item -ItemType Directory -Path "C:\Users\$env:USERNAME\GitHub" -Force; `
cd "$env:USERPROFILE\GitHub"; `
git clone https://github.com/WSHAPER/qemu-docker-ssh.git; `
cd .\qemu-docker-ssh\
```

Create `storage` directory and follow instructions.
Make sure that check directory paths match in `first-setup.yml` and `docker-compose.yml` with your local system.

Before running any of the following Docker commands, make sure the Docker Desktop application is running. You can start it from the Start Menu or ensure it's set to start automatically with Windows.

### Start first setup:
```bash
docker-compose -f first-setup.yml up -d
```


After Debian Installation, run the following `docker-compose.yml` with the following command:
```bash
docker-compose up -d
```

```yml
# version: "3.8"
services:
  qemu:
    container_name: qemu
    image: qemux/qemu-docker
    environment:
      HOST_PORTS: "22"
      BOOT: "debian-12.5.0-amd64-netinst.iso"
      RAM_SIZE: "16G"
      CPU_CORES: "7"
      DISK_SIZE: "32G"
    devices:
      - /dev/kvm
    cap_add:
      - NET_ADMIN
    ports:
      - "8006:8006"
      - "2222:22"
      - "2223:22"
    volumes:
      - ~/github/qemu-docker/storage:/storage
    stop_grace_period: 2m
    restart: on-failure
```

### Test Networking Internally

```bash
docker exec -it qemu /bin/bash
ssh -p 22 localhost
```

```bash
Permission denied, please try again.
```

## Docker Exec Commands

### 1. Initial SSH Connection Test
This command tests an SSH connection to the local server on the default port 22.
```bash
ssh -p 22 localhost
```

### 2. Installation of SSH Client and Server
These commands update the package list and install both the SSH client and the server packages.
Since you'll be running from `root@5c0682bae42b:/#`, `sudo` won't be required.
```bash
apt update -y && \
apt install -y openssh-client && \
apt install -y openssh-server && \
apt install -y nano && \
# Checking and Managing SSH Service
service ssh start && \
ps aux | grep sshd
```

Review SSH Configuration:
```bash
grep -E 'PasswordAuthentication|PermitRootLogin' /etc/ssh/sshd_config
```

> [!info]- Editing SSH Configuration in Nano
> First, install `nano` if it's not already installed, and then edit the SSH daemon configuration file.
> ```bash
> sudo apt install -y nano
> sudo nano /etc/ssh/sshd_config
> ```

```bash
# Enable Password Authentication by uncommenting and setting it to 'yes'
sed -i '/^#PasswordAuthentication yes/s/^#//g' /etc/ssh/sshd_config && \
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
# ow Root Login with password by uncommenting any PermitRootLogin and setting it to 'yes'
sed -i 's/^#PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
sed -i 's/^PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config && \

# Restart SSH service to apply changes
service ssh restart && \

# Display the current settings for PasswordAuthentication and PermitRootLogin
grep -E 'PasswordAuthentication|PermitRootLogin' /etc/ssh/sshd_config && \

# Verification of SSH Daemon
which sshd && \
# Checking and Managing SSH Service
service ssh status && \
# Check if ports are listening on the system, particularly looking for port 22.
ss -tuln | grep 22
```

**Change Root Password for the QEMU virtual machine inside the Docker container:**

```bash
# Make sure you're running from `docker exec -it qemu /bin/bash`
passwd root
```

Confirm you're in the right place with:
```bash
cat /etc/debian_version
```

```bash
cd /storage && ls -l | grep qemu
```

Only contains `qemu.mac` file as indicated by the following. Therefore, the `ip` has to be determined via `localhost:8006` (VNC in Chrome).

```
root@b75d82e83bf7:~# cd /storage && ls -l | grep qemu
-rw-r--r-- 1 root root          18 Apr 25 20:24 qemu.mac
```

Here's the output of ip addr show of the debian vm inside qemu. How to connect to it from the docker exec trixie?

```bash
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s36: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:63:e8:2a:d4:77 brd ff:ff:ff:ff:ff:ff
    inet 20.20.20.21/24 brd 20.20.20.255 scope global enp0s36
       valid_lft forever preferred_lft forever
    inet6 fe80::a3:e8ff:fe2a:d477/64 scope link 
       valid_lft forever preferred_lft forever
```

When trying to connect via root (since it's not configured to accept root ssh, the following error is thrown):
```bash
root@b75d82e83bf7:/storage# ssh root@20.20.20.21 -p 22
The authenticity of host '20.20.20.21 (20.20.20.21)' can't be established.
ED25519 key fingerprint is SHA256:1UY6MMi/K18ukH0MjE/1hBnJv33HxMmqaYjtOrJ7Tdg.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '20.20.20.21' (ED25519) to the list of known hosts.
root@20.20.20.21's password: 
Permission denied, please try again.
root@20.20.20.21's password: 
Permission denied, please try again.
root@20.20.20.21's password: 
root@20.20.20.21: Permission denied (publickey,password).
```

Solution:
Make sure to ssh into it with ikv@localhost
```bash
ssh ikv@20.20.20.21 -p 22
```

Verify you're in the right place, output should be `12.5` or similar, not `trixie`.
```bash
cat /etc/debian_version
```

Possible issue when troubleshooting might be that you have to be in `/storage`
```bash
ikv@qemu:~$ cat /etc/debian_version  
12.5  
ikv@qemu:~$ exit  
logout  
Connection to 20.20.20.21 closed.  
root@b75d82e83bf7:/storage# exit  
logout  
Connection to localhost closed.  
root@b75d82e83bf7:/# exit  
exit
```


> [!error] `ssh -p 2222 localhost` output
> Related: [[Error Resolution for ssh -p 2222 localhost]]
> ```bash
> @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
> @    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
> @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
> IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
> Someone could be eavesdropping on you right now (man-in-the-middle attack)!
> It is also possible that a host key has just been changed.
> The fingerprint for the ED25519 key sent by the remote host is
> SHA256:80/qPvs1zL4DBqfrMTRt+Hi1/poQftdmY0GlNXHCyjE.
> Please contact your system administrator.
> Add correct host key in /home/admin/.ssh/known_hosts to get rid of this message.
> Offending ED25519 key in /home/admin/.ssh/known_hosts:21
> Host key for [localhost]:2222 has changed and you have requested strict checking.
> Host key verification failed.
> ```

Based on the output you provided, it seems that the SSH server is running inside the Docker container (specifically, inside the QEMU virtual machine that's running a Debian installation), but it's not forwarding the SSH port (22) to the host machine.

The `docker-compose.yml` file you provided has the following port mapping:

```yaml
ports:
  - "8006:8006"
  - "2222:22"
```

This maps the host's port 2222 to port 22 inside the container. However, the SSH server is running inside the QEMU virtual machine, not directly inside the Docker container itself.

To connect to the SSH server running in the QEMU virtual machine, you'll need to first connect to the Docker container, and then from within the container, connect to the QEMU virtual machine.

Here are the steps you can follow:

1. Start the Docker container if it's not already running:

```bash
docker-compose up -d
```

2. Connect to the Docker container:

```bash
docker exec -it qemu /bin/bash
```

3. Inside the Docker container, connect to the QEMU virtual machine using the `ssh` command with the appropriate port (22 in your case):

```bash
ssh -p 22 localhost
```

This should connect you to the SSH server running inside the QEMU virtual machine.

Alternatively, you can try forwarding the SSH port from the QEMU virtual machine to the Docker host by modifying the `docker-compose.yml` file. Add the following line under the `ports` section:

```yaml
ports:
  - "8006:8006"
  - "2222:22"
  - "2223:22"
```

This will map the host's port 2223 to port 22 inside the QEMU virtual machine. After restarting the container, you should be able to connect to the SSH server running in the QEMU virtual machine using:

```bash
ssh -p 2223 localhost
```

Keep in mind that this assumes the SSH server is properly configured and running inside the QEMU virtual machine.
