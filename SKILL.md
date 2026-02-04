---
name: vmware-workstation-cli
description: Control VMware Workstation virtual machines via vmrun CLI commands. Use when users need to start, stop, suspend, manage snapshots, run guest operations, or copy files between host and guest VMs. Handles Windows PowerShell execution of vmrun.exe commands.
compatibility: Requires VMware Workstation installed with vmrun.exe accessible. Designed for Windows PowerShell environments.
metadata:
  author: vmware-agent-skill
  version: "1.0"
---

# VMware Workstation CLI Control

This skill enables agents to control VMware Workstation virtual machines using the `vmrun` command-line tool. It provides commands for VM lifecycle management, snapshot operations, guest operations, and file transfers.

## When to Use

Activate this skill when users need to:
- Start, stop, suspend, or reset virtual machines
- Manage VM snapshots (create, list, revert, delete)
- Run programs or scripts inside guest VMs
- Copy files between host and guest
- Query VM status (running VMs, guest IP addresses)
- Perform guest operations (list processes, kill processes)

## Prerequisites

- VMware Workstation must be installed
- `vmrun.exe` must be accessible. Default installation locations:
  - `C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe` (32-bit systems)
  - `C:\Program Files\VMware\VMware Workstation\vmrun.exe` (64-bit systems)
  - Custom installation paths (check with search commands above)
- **Note**: `vmrun.exe` is **not automatically added to PATH** by default. You can either:
  - Use the full path to `vmrun.exe` in commands (recommended for scripts)
  - Add VMware Workstation directory to system PATH environment variable
- VMX file path for the target virtual machine
- For guest operations: guest credentials (username and password)

## Required: Check vmrun.exe Path First

**CRITICAL: Before executing any vmrun command, you MUST first check if vmrun.exe exists at default locations. If not found, STOP execution and ask the user to provide the path.**

### Step 1: Check Default Paths

Before executing any vmrun command, check these default locations in order:

```powershell
# Check 64-bit default location first
$vmrunPath = "C:\Program Files\VMware\VMware Workstation\vmrun.exe"
if (Test-Path $vmrunPath) {
    # Found at default 64-bit location
    # Use $vmrunPath in commands
}

# If not found, check 32-bit default location
if (-not (Test-Path $vmrunPath)) {
    $vmrunPath = "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"
    if (Test-Path $vmrunPath) {
        # Found at default 32-bit location
        # Use $vmrunPath in commands
    }
}
```

### Step 2: If Not Found, STOP and Ask User

**If vmrun.exe is NOT found at either default location, you MUST:**

1. **STOP execution immediately**
2. **DO NOT attempt to search for it automatically**
3. **Ask the user to provide the full path to vmrun.exe**

Example message to user:
```
vmrun.exe was not found at the default installation paths:
- C:\Program Files\VMware\VMware Workstation\vmrun.exe
- C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe

Please provide the full path to vmrun.exe (e.g., C:\Apps\vmware\vmrun.exe)
```

### Step 3: Use Provided Path

Once the user provides the path, verify it exists and use it in all commands:

```powershell
# Verify user-provided path exists
$userProvidedPath = "<user_provided_path>"
if (Test-Path $userProvidedPath) {
    # Use $userProvidedPath in all vmrun commands
} else {
    # Path doesn't exist, ask user again
}
```

## Basic Usage Pattern

All commands follow this pattern:
```powershell
# Using full path (required - vmrun.exe is not in PATH by default)
& "<path_to_vmrun.exe>" -T ws <command> "<vmx_path>" [options]
```

**Replace `<path_to_vmrun.exe>` with:**
- The path found in Step 1 (default locations), OR
- The path provided by the user in Step 2

Common default paths:
- `C:\Program Files\VMware\VMware Workstation\vmrun.exe` (64-bit default)
- `C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe` (32-bit default)

Where:
- `-T ws` specifies VMware Workstation type
- `<vmx_path>` is the full path to the `.vmx` file
- `<command>` is the operation to perform

## Default Behavior Guidelines

**CRITICAL: Always default to `soft` operations for stop, suspend, and reset commands.**

- **Default**: Use `soft` for all stop, suspend, and reset operations unless:
  - User explicitly requests `hard` operation
  - Guest VM is unresponsive and soft operation fails
  - User specifically mentions "force" or "hard" shutdown/restart

- **Rationale**: Soft operations are safer, allow graceful shutdown/preparation, prevent data loss, and properly notify the guest OS. Hard operations should only be used as a last resort.

## Common Operations

### VM Lifecycle

**Start VM (headless):**
```powershell
& "<path_to_vmrun.exe>" -T ws start "<vmx_path>" nogui
```

**List running VMs:**
```powershell
& "<path_to_vmrun.exe>" -T ws list
```

**Stop VM (default: soft):**
```powershell
# Default: Always use soft unless user explicitly requests hard
& "<path_to_vmrun.exe>" -T ws stop "<vmx_path>" soft
```

**Suspend VM (default: soft):**
```powershell
# Default: Always use soft unless user explicitly requests hard
& "<path_to_vmrun.exe>" -T ws suspend "<vmx_path>" soft
```

**Reset VM (default: soft):**
```powershell
# Default: Always use soft unless user explicitly requests hard
& "<path_to_vmrun.exe>" -T ws reset "<vmx_path>" soft
```

### Snapshots

**Create snapshot:**
```powershell
& "<path_to_vmrun.exe>" -T ws snapshot "<vmx_path>" "<snapshot_name>"
```

**List snapshots:**
```powershell
& "<path_to_vmrun.exe>" -T ws listSnapshots "<vmx_path>"
```

**Revert to snapshot:**
```powershell
& "<path_to_vmrun.exe>" -T ws revertToSnapshot "<vmx_path>" "<snapshot_name>"
```

**Delete snapshot:**
```powershell
& "<path_to_vmrun.exe>" -T ws deleteSnapshot "<vmx_path>" "<snapshot_name>"
```

### Guest Operations

Guest operations require credentials (`-gu` for username, `-gp` for password):

**Run program in guest:**
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> runProgramInGuest "<vmx_path>" "<program_path>"
```

**Run script in guest:**
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> runScriptInGuest "<vmx_path>" "<interpreter>" "<script>"
```

**List processes in guest:**
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> listProcessesInGuest "<vmx_path>"
```

**Kill process in guest:**
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> killProcessInGuest "<vmx_path>" <pid>
```

### File Operations

**Copy file from host to guest:**
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> copyFileFromHostToGuest "<vmx_path>" "<host_path>" "<guest_path>"
```

**Copy file from guest to host:**
```powershell
& "<path_to_vmrun.exe>" -T ws -gu <user> -gp <pass> copyFileFromGuestToHost "<vmx_path>" "<guest_path>" "<host_path>"
```

### VM Information

**Get guest IP address:**
```powershell
& "<path_to_vmrun.exe>" -T ws getGuestIPAddress "<vmx_path>" [-wait]
```

The `-wait` flag waits for the guest to obtain an IP address if it's not yet available.

**List shared folders:**
```powershell
# Query shared folders from VMX file (vmrun has no direct list command)
Get-Content "<vmx_path>" | Select-String -Pattern "^sharedFolder" | ForEach-Object { $_.Line }
```

**Note**: vmrun does not provide a `listSharedFolders` command. Shared folder information is stored in the `.vmx` file and can be queried by reading the file.

### Linux shared folder permissions (non-root access)

On Linux guests (e.g. Ubuntu), VMware shared folders are mounted via FUSE. To allow **normal users** (not just root) to freely read and write under `/mnt/hgfs`:

1. **Enable `allow_other` in FUSE config (once per VM image):**

   Edit `/etc/fuse.conf` inside the guest and ensure this line is present (uncommented):
   ```bash
   user_allow_other
   ```

2. **Use `allow_other` + `uid/gid` in `/etc/fstab`:**

   For modern Ubuntu with `open-vm-tools`, a typical entry to mount all shared folders is:
   ```bash
   .host:/ /mnt/hgfs fuse.vmhgfs-fuse uid=1000,gid=1000,allow_other,defaults,nofail 0 0
   ```
   - `uid` / `gid`: set ownership to the normal user (check with `id`).
   - `allow_other`: lets other users (not just the mounter) access the FS.
   - `nofail`: VM still boots even if the shared folder is unavailable.

After this, the normal user can run `ls -la /mnt/hgfs` and read/write shared files without `sudo`.

## Finding VMX Files

To locate VMX files in a directory:
```powershell
Get-ChildItem -LiteralPath "<vm_directory>" -Filter *.vmx | Select-Object -First 5 FullName
```

## Important Notes

1. **vmrun.exe Path Validation (REQUIRED)**: 
   - **MUST check default paths first** before executing any command (see "Required: Check vmrun.exe Path First" section above)
   - `vmrun.exe` is **not automatically added to PATH** by default
   - Default installation locations:
     - `C:\Program Files\VMware\VMware Workstation\vmrun.exe` (64-bit)
     - `C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe` (32-bit)
   - **If not found at default paths**: STOP execution and ask user to provide the full path
   - Always use full path in commands (never assume it's in PATH)

2. **VMX Path**: Always use the full path to the `.vmx` file, enclosed in quotes if it contains spaces.

3. **Guest Credentials**: Guest operations require valid credentials. Ensure VMware Tools is installed in the guest VM.

4. **PowerShell Execution**: Use `&` operator in PowerShell to execute the command, especially when the path contains spaces.

5. **Default to Soft Operations**: **ALWAYS prefer `soft` operations by default** for stop, suspend, and reset commands. Use `hard` only when explicitly requested by the user or when the guest is unresponsive. Soft operations are safer, allow graceful shutdown/preparation, and prevent data loss.

## Error Handling

- **If `vmrun.exe` is not found at default paths**: STOP execution immediately and ask the user to provide the full path to vmrun.exe. Do NOT attempt automatic search.
- **If user-provided path doesn't exist**: Verify the path and ask the user to provide the correct path again.
- **If guest operations fail**: Verify VMware Tools is installed and running in the guest
- **If VM operations fail**: Ensure the VM is in the correct state (e.g., can't start an already running VM)

## Reference

For detailed command reference and additional operations, see [COMMANDS.md](references/COMMANDS.md).

## Documentation Links

- Official vmrun documentation (PDF format, may require access)
- Readable mirror: https://pdf4pro.com/view/using-vmrun-to-control-virtual-machines-vmware-71a573.html
