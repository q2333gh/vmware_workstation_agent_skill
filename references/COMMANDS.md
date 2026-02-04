# VMware Workstation CLI - Complete Command Reference

This document provides a comprehensive reference for all vmrun commands used with VMware Workstation.

## Environment Setup

### Default Installation Paths
VMware Workstation default installation locations:
- **64-bit systems**: `C:\Program Files\VMware\VMware Workstation\vmrun.exe`
- **32-bit systems**: `C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe`
- **Custom installations**: May be installed in other locations (use search commands to find)

**Note**: `vmrun.exe` is **not automatically added to PATH** by default. You must either:
- Use the full path to `vmrun.exe` in commands (recommended)
- Add VMware Workstation directory to system PATH environment variable

**Authentication flags** (must appear before the command):
- `-T ws` — host type: Workstation (use `fusion` or `player` for other products)
- `-gu <user>` / `-gp <pass>` — guest OS login (required for guest operations)
- `-vp <password>` — password for encrypted virtual machine (if the VM is encrypted)

### Finding vmrun.exe
```powershell
# Check common default locations
Test-Path "C:\Program Files\VMware\VMware Workstation\vmrun.exe"
Test-Path "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"

# Search for vmrun.exe
Get-ChildItem -Path "C:\Program Files*" -Filter vmrun.exe -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
```

### PowerShell Execution
Always use the `&` operator in PowerShell when executing vmrun with full path:
```powershell
# Using full path (recommended)
# Replace <path_to_vmrun.exe> with actual path (e.g., "C:\Program Files\VMware\VMware Workstation\vmrun.exe")
& "<path_to_vmrun.exe>" -T ws <command> "<vmx_path>" [options]

# Or if vmrun.exe is in PATH:
vmrun -T ws <command> "<vmx_path>" [options]
```

## VM Lifecycle Commands

### Default Behavior: Always Prefer Soft Operations

**IMPORTANT**: For stop, suspend, and reset commands, **always default to `soft`** unless:
- User explicitly requests `hard` operation
- Guest VM is unresponsive and soft operation fails
- User specifically mentions "force" or "hard" shutdown/restart

Soft operations are safer, allow graceful shutdown/preparation, and prevent data loss.

### Start VM
Start a virtual machine. Use `nogui` for headless operation.

```powershell
# Start with GUI
& "<path_to_vmrun.exe>" -T ws start "<vmx_path>"

# Start headless (no GUI)
& "<path_to_vmrun.exe>" -T ws start "<vmx_path>" nogui
```

### Stop VM
Stop a running virtual machine.

**Soft Stop:**
- Graceful shutdown: Sends shutdown signal to guest operating system
- Guest OS can execute normal shutdown procedures (save data, close services, etc.)
- Similar to clicking "Shutdown" button in the guest

**Hard Stop:**
- Force stop: Immediately terminates VM without notifying guest OS
- Similar to pulling the power cord, may cause data loss
- Use only when guest is unresponsive

```powershell
# DEFAULT: Always use soft unless user explicitly requests hard
& "<path_to_vmrun.exe>" -T ws stop "<vmx_path>" soft

# Only use hard when:
# - User explicitly requests hard operation
# - Guest VM is unresponsive and soft operation fails
& "<path_to_vmrun.exe>" -T ws stop "<vmx_path>" hard
```

### Suspend VM
Suspend a running virtual machine.

**Soft Suspend (Recommended):**
- Graceful suspend: Runs guest OS system scripts before suspending
- Windows guests: Scripts release IP address
- Linux guests: Scripts suspend networking
- Guest OS is notified of suspend operation and can gracefully prepare
- Network connectivity automatically restored on resume (Windows reacquires IP, Linux restarts networking)

**Hard Suspend:**
- Force suspend: No scripts run, similar to pulling power cord
- Guest OS is not notified of suspend operation
- Network connection maintained (corresponds to "Suspend" option in GUI)
- Network connection must be manually restored after resume

```powershell
# DEFAULT: Always use soft unless user explicitly requests hard
& "<path_to_vmrun.exe>" -T ws suspend "<vmx_path>" soft

# Only use hard when:
# - User explicitly requests hard operation
# - Guest VM is unresponsive and soft operation fails
& "<path_to_vmrun.exe>" -T ws suspend "<vmx_path>" hard
```

**Default Behavior:**
- **Always default to `soft`**: More safe, allows guest OS to gracefully prepare for suspension
- **Use `hard` only**: When user explicitly requests it or guest is unresponsive

### Reset VM
Reset (restart) a running virtual machine.

**Soft Reset:**
- Graceful restart: Sends restart signal to guest operating system
- Guest OS can execute normal restart procedures
- Similar to clicking "Restart" button in the guest

**Hard Reset:**
- Force restart: Immediately restarts VM without notifying guest OS
- Similar to pressing physical reset button, may cause data loss
- Use only when guest is unresponsive

```powershell
# DEFAULT: Always use soft unless user explicitly requests hard
& "<path_to_vmrun.exe>" -T ws reset "<vmx_path>" soft

# Only use hard when:
# - User explicitly requests hard operation
# - Guest VM is unresponsive and soft operation fails
& "<path_to_vmrun.exe>" -T ws reset "<vmx_path>" hard
```

### List Running VMs
List all currently running virtual machines.

```powershell
& "<path_to_vmrun.exe>" -T ws list
```

**Example output:**
```
Total running VMs: 1
<vmx_path> (running)
```

### Pause VM
Pauses a virtual machine (no soft/hard). Use **unpause** to resume.

```powershell
& "<path_to_vmrun.exe>" -T ws pause "<vmx_path>"
```

### Unpause VM
Resumes a paused virtual machine.

```powershell
& "<path_to_vmrun.exe>" -T ws unpause "<vmx_path>"
```

## Snapshot Commands

### Create Snapshot
Create a snapshot of the current VM state.

```powershell
& "<path_to_vmrun.exe>" -T ws snapshot "<vmx_path>" "<snapshot_name>"
```

**Example:**
```powershell
& "<path_to_vmrun.exe>" -T ws snapshot "<vmx_path>" "snap1"
```

### List Snapshots
List all snapshots for a VM. Use **showtree** to display in tree format (children indented).

```powershell
& "<path_to_vmrun.exe>" -T ws listSnapshots "<vmx_path>"
& "<path_to_vmrun.exe>" -T ws listSnapshots "<vmx_path>" showtree
```

### Revert to Snapshot
Revert the VM to a specific snapshot state.

```powershell
& "<path_to_vmrun.exe>" -T ws revertToSnapshot "<vmx_path>" "<snapshot_name>"
```

**Example:**
```powershell
& "<path_to_vmrun.exe>" -T ws revertToSnapshot "<vmx_path>" "snap1"
```

### Delete Snapshot
Delete a specific snapshot. VM must be powered off or suspended. Use **andDeleteChildren** to delete the snapshot and its children recursively.

```powershell
& "<path_to_vmrun.exe>" -T ws deleteSnapshot "<vmx_path>" "<snapshot_name>"
& "<path_to_vmrun.exe>" -T ws deleteSnapshot "<vmx_path>" "<snapshot_name>" andDeleteChildren
```

**Example:**
```powershell
& "<path_to_vmrun.exe>" -T ws deleteSnapshot "<vmx_path>" "snap1"
```

## Guest Operations

All guest operations require guest credentials:
- `-gu <username>`: Guest username
- `-gp <password>`: Guest password

**Note:** VMware Tools must be installed and running in the guest VM for these operations to work.

### Run Program in Guest
Execute a program inside the guest VM. Optional flags (before program path): **-noWait** (return immediately, don't wait for program to finish; useful for interactive apps), **-activeWindow** (ensure Windows GUI is visible; no effect on Linux), **-interactive** (force interactive guest login; useful for Windows Vista/7+ to show program in console).

```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> runProgramInGuest "<vmx_path>" "<program_path>"
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> runProgramInGuest "<vmx_path>" -noWait "<program_path>"
```

**Example (Windows guest):**
```powershell
& "<path_to_vmrun.exe>" -T ws -gu user -gp pass runProgramInGuest "<vmx_path>" "C:\Windows\System32\notepad.exe"
```

### Run Script in Guest
Execute a script or command inside the guest VM. Same optional flags as runProgramInGuest: **-noWait**, **-activeWindow**, **-interactive** (before interpreter path).

```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> runScriptInGuest "<vmx_path>" "<interpreter>" "<script>"
```

**Example (Windows guest):**
```powershell
& "<path_to_vmrun.exe>" -T ws -gu user -gp pass runScriptInGuest "<vmx_path>" "C:\Windows\System32\cmd.exe" "dir C:\"
```

**Example (Linux guest):**
```powershell
& "<path_to_vmrun.exe>" -T ws -gu user -gp pass runScriptInGuest "<vmx_path>" "/bin/bash" "ls -la /home"
```

**Important:** `runScriptInGuest` does **not** return guest stdout to the host. Output will not appear in the terminal. Use the workaround below to get script/command output.

### Getting Script Output from Guest (Workaround)

Because `runScriptInGuest` does not return stdout to the host, capture output by redirecting to a file in the guest, then copying that file to the host.

**Steps:**

1. Run the script/command in the guest with output redirected to a temp file (e.g. `/tmp/guest_out.txt` on Linux).
2. Copy the file from guest to host with `copyFileFromGuestToHost`.
3. Read the file on the host to get the output.

**Example (Linux guest — run `ls ~` and get output):**
```powershell
$vmrun = "<path_to_vmrun.exe>"
$vmx = "<vmx_path>"
$gu = "<guest_user>"
$gp = "<guest_password>"
$guestTmp = "/tmp/guest_out.txt"
$hostOut = "C:\path\to\output.txt"

# 1. Run command in guest, redirect to file
& $vmrun -T ws -gu $gu -gp $gp runScriptInGuest $vmx "/bin/bash" "ls -la ~ > $guestTmp 2>&1"

# 2. Copy file from guest to host
& $vmrun -T ws -gu $gu -gp $gp copyFileFromGuestToHost $vmx $guestTmp $hostOut

# 3. Read output on host
Get-Content $hostOut
```

Use a unique temp path per run if you run multiple commands. Optionally delete the guest temp file with a follow-up `runScriptInGuest` (e.g. `rm /tmp/guest_out.txt`) or leave it for next run.

### List Processes in Guest
List all running processes in the guest VM.

```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> listProcessesInGuest "<vmx_path>"
```

### Kill Process in Guest
Terminate a specific process in the guest VM.

```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> killProcessInGuest "<vmx_path>" <pid>
```

**Example:**
```powershell
& "<path_to_vmrun.exe>" -T ws -gu user -gp pass killProcessInGuest "<vmx_path>" 1234
```

### Guest File and Directory Operations
All require `-gu` and `-gp`. VMware Tools and valid guest login required.

**fileExistsInGuest** — Check if a file exists in the guest:
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> fileExistsInGuest "<vmx_path>" "<guest_file_path>"
```

**directoryExistsInGuest** — Check if a directory exists in the guest:
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> directoryExistsInGuest "<vmx_path>" "<guest_dir_path>"
```

**listDirectoryInGuest** — List contents of a directory in the guest:
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> listDirectoryInGuest "<vmx_path>" "<guest_dir_path>"
```

**createTempfileInGuest** — Create a temporary file in the guest; returns the path:
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> createTempfileInGuest "<vmx_path>"
```

**deleteFileInGuest** — Delete a file in the guest:
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> deleteFileInGuest "<vmx_path>" "<guest_file_path>"
```

**createDirectoryInGuest** — Create a directory in the guest:
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> createDirectoryInGuest "<vmx_path>" "<guest_dir_path>"
```

**deleteDirectoryInGuest** — Delete a directory in the guest:
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> deleteDirectoryInGuest "<vmx_path>" "<guest_dir_path>"
```

**renameFileInGuest** — Rename or move a file in the guest:
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> renameFileInGuest "<vmx_path>" "<original_path>" "<new_path>"
```

### Capture Screen
Capture the guest screen to a PNG file on the host. Requires `-gu` and `-gp`.

```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> captureScreen "<vmx_path>" "<host_output.png>"
```

### Type Keystrokes in Guest
Send keystrokes to the guest OS (e.g. for automation). Requires `-gu` and `-gp`.

```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> typeKeystrokesInGuest "<vmx_path>" "<keystroke_string>"
```

Use standard key names (e.g. `ctrl+tab`, `ctrl+c`; modifier+key). Useful for GUI automation when combined with runProgramInGuest.

**Troubleshooting — "Insufficient permissions in the host operating system":**  
This error is common with `typeKeystrokesInGuest` on Windows. Try:

1. **Run the host as Administrator** — Start PowerShell or CMD **as Administrator**, then run the vmrun command again. On some systems this still does **not** resolve the error (VIX/Workstation limitation).
2. **Guest credentials** — Ensure `-gu` and `-gp` are correct and the guest has VMware Tools running (e.g. `checkToolsState` returns `running`). Using root in the guest does not fix a host-side permission error.
3. **Known limitation** — Even with host Administrator and valid guest login, `typeKeystrokesInGuest` can fail with this error. vmrun uses the deprecated VIX API; keystroke injection is not reliably supported on all Workstation/Windows setups. **Recommendation:** Prefer **runScriptInGuest** / **runProgramInGuest** for automation where possible; reserve typeKeystrokesInGuest for environments where it is known to work.

## File Operations

### Copy File from Host to Guest
Copy a file from the host system to the guest VM.

```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> copyFileFromHostToGuest "<vmx_path>" "<host_path>" "<guest_path>"
```

**Example:**
```powershell
& "<path_to_vmrun.exe>" -T ws -gu user -gp pass copyFileFromHostToGuest "<vmx_path>" "<host_path>" "<guest_path>"
```

### Copy File from Guest to Host
Copy a file from the guest VM to the host system.

```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> copyFileFromGuestToHost "<vmx_path>" "<guest_path>" "<host_path>"
```

**Example:**
```powershell
& "<path_to_vmrun.exe>" -T ws -gu user -gp pass copyFileFromGuestToHost "<vmx_path>" "<guest_path>" "<host_path>"
```

## Shared Folder Commands (Runtime)
VM must be running for add/remove to take effect. Changes may require VM restart to apply.

**addSharedFolder** — Add a shared folder (share name = mount point in guest; path = host directory):
```powershell
& "<path_to_vmrun.exe>" -T ws addSharedFolder "<vmx_path>" "<share_name>" "<host_path>"
```

**removeSharedFolder** — Remove guest access to a shared folder:
```powershell
& "<path_to_vmrun.exe>" -T ws removeSharedFolder "<vmx_path>" "<share_name>"
```

**enableSharedFolders** — Enable shared folders for the VM. Optional **runtime** limits to current run:
```powershell
& "<path_to_vmrun.exe>" -T ws enableSharedFolders "<vmx_path>" [runtime]
```

**disableSharedFolders** — Disable shared folders. Optional **runtime** limits to current run:
```powershell
& "<path_to_vmrun.exe>" -T ws disableSharedFolders "<vmx_path>" [runtime]
```

**setSharedFolderState** — Set writability: **writable** or **readonly**:
```powershell
& "<path_to_vmrun.exe>" -T ws setSharedFolderState "<vmx_path>" "<share_name>" "<host_path>" writable
& "<path_to_vmrun.exe>" -T ws setSharedFolderState "<vmx_path>" "<share_name>" "<host_path>" readonly
```

## Host Network Commands (Windows Only)
Workstation Pro on Windows only. Linux host does not support these.

**listHostNetworks** — List all host networks:
```powershell
& "<path_to_vmrun.exe>" -T ws listHostNetworks
```

**listPortForwardings** — List port forwardings for a host network:
```powershell
& "<path_to_vmrun.exe>" -T ws listPortForwardings "<host_network_name>"
```

**setPortForwarding** — Set port forwarding (protocol, host port, guest IP, guest port; optional description). May require **sudo**:
```powershell
& "<path_to_vmrun.exe>" -T ws setPortForwarding "<host_network_name>" <protocol> <host_port> <guest_ip> <guest_port> [description]
```

**deletePortForwarding** — Delete port forwarding. May require **sudo**:
```powershell
& "<path_to_vmrun.exe>" -T ws deletePortForwarding "<host_network_name>" <protocol> <host_port>
```

## Device Commands
Connect or disconnect devices (e.g. sound, serial0, Ethernet0, sata0:1). VM must be powered on.

**connectNamedDevice** — Connect a device to the guest:
```powershell
& "<path_to_vmrun.exe>" -T ws connectNamedDevice "<vmx_path>" "<device_name>"
```

**disconnectNamedDevice** — Disconnect a device from the guest:
```powershell
& "<path_to_vmrun.exe>" -T ws disconnectNamedDevice "<vmx_path>" "<device_name>"
```

## Variable Commands
**writeVariable** — Write guestVar (runtime-only), runtimeConfig (.vmx), or guestEnv (guest environment). guestEnv requires -gu -gp; Linux guestEnv may require root:
```powershell
& "<path_to_vmrun.exe>" -T ws [-gu <user> -gp <pass>] writeVariable "<vmx_path>" guestVar|runtimeConfig|guestEnv "<name>" "<value>"
```

**readVariable** — Read guestVar, runtimeConfig, or guestEnv. guestEnv requires -gu -gp:
```powershell
& "<path_to_vmrun.exe>" -T ws [-gu <user> -gp <pass>] readVariable "<vmx_path>" guestVar|runtimeConfig|guestEnv "<name>"
```

## General Commands
**checkToolsState** — Check VMware Tools status (unknown, installed, running):
```powershell
& "<path_to_vmrun.exe>" -T ws checkToolsState "<vmx_path>"
```

**upgradevm** — Upgrade VM to current virtual hardware version. Power off VM first. No effect if already latest:
```powershell
& "<path_to_vmrun.exe>" -T ws upgradevm "<vmx_path>"
```

**installTools** — Prepare to install VMware Tools (mounts Tools ISO; Windows may auto-start installer; Linux requires manual steps):
```powershell
& "<path_to_vmrun.exe>" -T ws installTools "<vmx_path>"
```

**deleteVM** — Delete the virtual machine:
```powershell
& "<path_to_vmrun.exe>" -T ws deleteVM "<vmx_path>"
```

**clone** — Clone VM (Workstation Pro only). **full** or **linked**; optional **-snapshot=Snapshot Name**, **-cloneName=Name**:
```powershell
& "<path_to_vmrun.exe>" -T ws clone "<vmx_path>" "<destination_vmx_path>" full|linked [-snapshot=Snapshot Name] [-cloneName=Name]
```

## VM Information Commands

### Get Guest IP Address
Retrieve the IP address of the guest VM.

```powershell
# Get IP immediately (may return empty if not available)
& "<path_to_vmrun.exe>" -T ws getGuestIPAddress "<vmx_path>"

# Wait for IP address to become available
& "<path_to_vmrun.exe>" -T ws getGuestIPAddress "<vmx_path>" -wait
```

**Example:**
```powershell
& "<path_to_vmrun.exe>" -T ws getGuestIPAddress "<vmx_path>" -wait
```

### List Shared Folders
**Note**: vmrun does not have a direct `listSharedFolders` command. However, you can query shared folders by reading the `.vmx` file.

**Query shared folders from VMX file:**
```powershell
# Get all shared folder entries
Get-Content "<vmx_path>" | Select-String -Pattern "^sharedFolder" | ForEach-Object { $_.Line }
```

**Formatted output (PowerShell script):**
```powershell
$vmxPath = "<vmx_path>"
$sharedFolders = @{}
$maxNum = 0

# Read VMX file and parse shared folder entries
Get-Content $vmxPath | ForEach-Object {
    if ($_ -match "^sharedFolder\.maxNum\s*=\s*""(\d+)""") {
        $maxNum = [int]$matches[1]
    }
    elseif ($_ -match "^sharedFolder(\d+)\.(\w+)\s*=\s*""([^""]+)""") {
        $index = $matches[1]
        $property = $matches[2]
        $value = $matches[3]
        
        if (-not $sharedFolders[$index]) {
            $sharedFolders[$index] = @{}
        }
        $sharedFolders[$index][$property] = $value
    }
}

# Display formatted results
Write-Host "Shared Folders (Total: $maxNum):" -ForegroundColor Cyan
Write-Host ""
for ($i = 0; $i -lt $maxNum; $i++) {
    if ($sharedFolders[$i] -and $sharedFolders[$i]['present'] -eq 'TRUE') {
        Write-Host "Folder $i:" -ForegroundColor Yellow
        Write-Host "  Guest Name: $($sharedFolders[$i]['guestName'])"
        Write-Host "  Host Path:   $($sharedFolders[$i]['hostPath'])"
        Write-Host "  Enabled:     $($sharedFolders[$i]['enabled'])"
        Write-Host "  Read Access: $($sharedFolders[$i]['readAccess'])"
        Write-Host "  Write Access:$($sharedFolders[$i]['writeAccess'])"
        Write-Host "  Expiration:  $($sharedFolders[$i]['expiration'])"
        Write-Host ""
    }
}
```

**Example:**
```powershell
Get-Content "<vmx_path>" | Select-String -Pattern "^sharedFolder" | ForEach-Object { $_.Line }
```

## Utility Commands

### Find VMX Files
Locate VMX files in a directory (PowerShell command):

```powershell
Get-ChildItem -LiteralPath "<vm_directory>" -Filter *.vmx | Select-Object -First 5 FullName
```

**Example:**
```powershell
Get-ChildItem -LiteralPath "<vm_directory>" -Filter *.vmx | Select-Object -First 5 FullName
```

## Common Patterns

### Complete Workflow Example

```powershell
# 1. Find VMX file
$vmx = Get-ChildItem -LiteralPath "<vm_directory>" -Filter *.vmx | Select-Object -First 1 -ExpandProperty FullName

# 2. Start VM headless
& "<path_to_vmrun.exe>" -T ws start $vmx nogui

# 3. Wait for VM to boot and get IP
$ip = & "<path_to_vmrun.exe>" -T ws getGuestIPAddress $vmx -wait

# 4. Copy file to guest
& "<path_to_vmrun.exe>" -T ws -gu user -gp pass copyFileFromHostToGuest $vmx "<host_script_path>" "<guest_script_path>"

# 5. Run script in guest
& "<path_to_vmrun.exe>" -T ws -gu user -gp pass runScriptInGuest $vmx "/bin/bash" "/home/user/script.sh"

# 6. Stop VM
& "<path_to_vmrun.exe>" -T ws stop $vmx soft
```

## Troubleshooting

### vmrun.exe Not Found
- Check VMware Workstation installation directory
- Common locations:
  - `C:\Program Files\VMware\VMware Workstation\vmrun.exe` (64-bit default)
  - `C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe` (32-bit default)
  - Use search commands in Environment Setup section to find custom installations

### Guest Operations Fail
- Verify VMware Tools is installed in the guest VM
- Ensure VMware Tools service is running
- Check guest credentials are correct
- Confirm guest VM is powered on

### VM Operations Fail
- Verify VM is in the correct state (can't start an already running VM)
- Check VMX file path is correct and accessible
- Ensure no other process is using the VM

## Shared Folders Auto-Mount Setup (Ubuntu)

### Problem
Modern Ubuntu versions use `open-vm-tools` instead of traditional VMware Tools, and shared folders are **not automatically mounted** by default. You need to manually configure auto-mounting.

### Solution: Set up automatic mounting via /etc/fstab

**Method 1: Using provided script (recommended)**

1. Copy the setup script to the guest VM:
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> copyFileFromHostToGuest "<vmx_path>" "C:\path\to\setup-shared-folders-auto-mount.sh" "/tmp/setup-shared-folders-auto-mount.sh"
```

2. Make script executable and run it:
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> runScriptInGuest "<vmx_path>" "/bin/bash" "chmod +x /tmp/setup-shared-folders-auto-mount.sh && sudo /tmp/setup-shared-folders-auto-mount.sh"
```

**Method 2: Manual setup (Recommended approach - mount all shares)**

For modern Ubuntu with `open-vm-tools` (Ubuntu 16.04+), use `fuse.vmhgfs-fuse`:

1. Create mount point:
```bash
sudo mkdir -p /mnt/hgfs
```

2. Add to /etc/fstab (mounts ALL shared folders):
```bash
# allow_other: let normal users access /mnt/hgfs
# nofail: prevent boot hang if shared folder is unavailable
echo ".host:/ /mnt/hgfs fuse.vmhgfs-fuse uid=1000,gid=1000,allow_other,defaults,nofail 0 0" | sudo tee -a /etc/fstab
```

**Important**: The `nofail` option ensures that if the shared folder is unavailable (e.g., host folder deleted, VM not fully booted), the system will still boot successfully instead of hanging. The `allow_other` option, together with `user_allow_other` in `/etc/fuse.conf`, allows normal users (not just root) to read and write under `/mnt/hgfs`.

3. Test mount:
```bash
sudo mount /mnt/hgfs
```

4. Verify:
```bash
ls -la /mnt/hgfs/
```

**Method 3: Manual setup (Mount specific share)**

If you want to mount only a specific share:

1. Create mount point:
```bash
sudo mkdir -p /mnt/hgfs/share_folder1
```

2. Add to /etc/fstab (for shares with spaces, use quotes):
```bash
# For share names without spaces:
# allow_other: let normal users access /mnt/hgfs/share_folder1
# nofail: prevent boot hang if shared folder is unavailable
echo ".host:/share_folder1 /mnt/hgfs/share_folder1 fuse.vmhgfs-fuse allow_other,default_permissions,uid=1000,nofail 0 0" | sudo tee -a /etc/fstab

# For share names with spaces:
echo ".host:/\"Share Name\" /mnt/hgfs/\"Share Name\" fuse.vmhgfs-fuse allow_other,default_permissions,uid=1000,nofail 0 0" | sudo tee -a /etc/fstab
```

3. Test mount:
```bash
sudo mount /mnt/hgfs/share_folder1
```

**Important Notes:**
- **Modern Ubuntu (16.04+)**: Use `fuse.vmhgfs-fuse` filesystem type (not `vmhgfs`)
- **Older Ubuntu**: Use `vmhgfs` filesystem type
- Replace `uid=1000,gid=1000` with your user's UID/GID (check with `id` command)
- **Recommended**: Mount all shares (`.host:/`) rather than individual shares
- **Safety**: Always include `nofail` option to prevent boot hang if shared folder is unavailable
- VMware Tools (`open-vm-tools`) must be installed: `sudo apt-get install open-vm-tools`
- After adding to /etc/fstab, the folder(s) will mount automatically on boot
- You can list available shares with: `vmware-hgfsclient`

**About `nofail` option:**
- Prevents system boot hang if shared folder is unavailable (e.g., host folder deleted, VMware Tools not ready)
- System will boot normally even if mount fails
- Mount failure will be logged but won't stop boot process
- **Highly recommended** for VMware shared folders to ensure system stability

## Documentation References

- Official vmrun documentation (PDF format, may require access)
- Readable mirror: https://pdf4pro.com/view/using-vmrun-to-control-virtual-machines-vmware-71a573.html
