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
