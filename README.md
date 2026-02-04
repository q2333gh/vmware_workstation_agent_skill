# VMware Workstation CLI Agent Skill

An Agent Skill for controlling VMware Workstation virtual machines via `vmrun` CLI commands. This skill enables AI agents to manage VM lifecycle, snapshots, guest operations, and shared folders.

## Features

- **VM Lifecycle Management**: Start, stop, suspend, reset virtual machines
- **Snapshot Operations**: Create, list, revert, and delete snapshots
- **Guest Operations**: Run programs/scripts, manage processes, copy files
- **Shared Folders**: Query and configure shared folder auto-mounting
- **VM Information**: Get guest IP addresses, check VMware Tools status

## Installation

Copy this skill directory to your agent's skills location:

```bash
# For Cursor
cp -r vmware-workstation-cli ~/.cursor/skills/

# For other agents supporting Agent Skills format
cp -r vmware-workstation-cli <agent-skills-directory>/
```

## Prerequisites

- VMware Workstation installed
- `vmrun.exe` accessible (typically at `C:\Apps\vmware\vmrun.exe` or VMware installation directory)
- For guest operations: VMware Tools installed in guest VMs

## Quick Start

### Basic VM Operations

```powershell
# Start VM (headless)
& "C:\Apps\vmware\vmrun.exe" -T ws start "<vmx_path>" nogui

# List running VMs
& "C:\Apps\vmware\vmrun.exe" -T ws list

# Stop VM (graceful)
& "C:\Apps\vmware\vmrun.exe" -T ws stop "<vmx_path>" soft

# Suspend VM
& "C:\Apps\vmware\vmrun.exe" -T ws suspend "<vmx_path>" soft
```

### Shared Folders Auto-Mount (Ubuntu)

The skill includes a script to automatically mount VMware shared folders on boot:

```bash
# Copy script to guest VM
# Then run:
sudo bash /tmp/setup-shared-folders-auto-mount.sh
```

Or manually configure:

```bash
# 1. Enable user_allow_other in /etc/fuse.conf
echo "user_allow_other" | sudo tee -a /etc/fuse.conf

# 2. Add to /etc/fstab
echo ".host:/ /mnt/hgfs fuse.vmhgfs-fuse uid=$(id -u),gid=$(id -g),allow_other,defaults,nofail 0 0" | sudo tee -a /etc/fstab

# 3. Test mount
sudo mount /mnt/hgfs
```

## File Structure

```
vmware-workstation-cli/
├── SKILL.md                    # Main skill file with usage instructions
├── README.md                   # This file
├── references/
│   └── COMMANDS.md            # Complete command reference
└── scripts/
    └── setup-shared-folders-auto-mount.sh  # Auto-mount setup script
```

## Documentation

- **SKILL.md**: Main skill instructions and common operations
- **references/COMMANDS.md**: Complete command reference with examples
- **scripts/**: Utility scripts for common tasks

## Default Behavior

- **Soft Operations**: Always defaults to `soft` for stop, suspend, and reset commands unless explicitly requested otherwise
- **Safety**: Uses `nofail` option for shared folder mounts to prevent boot hangs
- **Permissions**: Configures shared folders for normal user access (not just root)

## License

See LICENSE file for details.

## Contributing

Contributions welcome! Please ensure any changes follow the Agent Skills specification format.
