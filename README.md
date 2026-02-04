# VMware Workstation CLI Agent Skill

Control VMware Workstation VMs via `vmrun` CLI. Manage VM lifecycle, snapshots, guest operations, and shared folders.

## Install for LLM Agent

**Option 1: Install entire skill directory (recommended)**

Copy and paste this to your LLM agent:

```
Install this Agent Skill from GitHub: https://github.com/q2333gh/vmware_workstation_agent_skill
```

The agent will clone the repository and install the complete skill with all files (SKILL.md, references/COMMANDS.md, scripts/).

## Manual Installation

```bash
git clone https://github.com/q2333gh/vmware_workstation_agent_skill.git
cp -r vmware_workstation_agent_skill ~/.cursor/skills/vmware-workstation-cli
```

## Requirements

- VMware Workstation with `vmrun.exe`
- Windows PowerShell environment
- VMware Tools in guest VMs (for guest operations)

## Official vmrun help

To see the built-in help from your installed vmrun, run:

```powershell
& "C:\path\to\vmrun.exe"
```

(No `-help` flag; invalid arguments print version and usage.) The project may also include a saved copy as `vmrun_help.md` in the parent repo for reference (vmrun version 1.17.0 format).

## License

See LICENSE file for details.
