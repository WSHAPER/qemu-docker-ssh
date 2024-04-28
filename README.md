### Start first setup:

- Create `storage/` directory in root directory
- Move your `debian.iso` into it

For initial setup run:

```bash
docker-compose -f first-setup.yml up -d
```

Log in to `localhost:8006` via Browser and setup your server using the GUI.


After Installation, run the following command:
```bash
docker-compose up -d
```

Check `ssh` status by running:
```bash
systemctl status sshd
```

### Test Networking Internally

```bash
docker exec -it qemu /bin/bash
ssh ikv@20.20.20.21 -p 22
```

Confirm you're in the right place with (Output should not include `trixie`)
```bash
cat /etc/debian_version
```

### Troubleshooting Docker SSH

```bash
docker exec -it qemu /bin/bash
service ssh start && \
ps aux | grep sshd
```

Review SSH Configuration:
```bash
grep -E 'PasswordAuthentication|PermitRootLogin' /etc/ssh/sshd_config
```

The SSH Configuration should be handled by `.src/setup-ssh.sh`, which is sourced in the Dockerfile.

```bash
sudo nano /etc/ssh/sshd_config
```

**Change Root Password for the QEMU virtual machine inside the Docker container:**

```bash
# Make sure you're running from `docker exec -it qemu /bin/bash`
passwd root
```
