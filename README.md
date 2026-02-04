# VMware Workstation CLI Agent Skill

Control VMware Workstation VMs via `vmrun` CLI. Manage VM lifecycle, snapshots, guest operations, and shared folders.

## Install for LLM Agent

**Option 1: Install entire skill directory (recommended)**

Copy and paste this to your LLM agent:

```
Install this Agent Skill from GitHub: https://github.com/q2333gh/vmware_workstation_agent_skill
```

The agent will clone the repository and install the complete skill with all files (SKILL.md, references/COMMANDS.md, scripts/).

**Option 2: Install from raw URL (SKILL.md only)**

If you only need the main skill file:

```
https://raw.githubusercontent.com/q2333gh/vmware_workstation_agent_skill/master/SKILL.md
```

Note: This installs only SKILL.md. For full functionality including command references, use Option 1.

## Manual Installation

```bash
git clone https://github.com/q2333gh/vmware_workstation_agent_skill.git
cp -r vmware_workstation_agent_skill ~/.cursor/skills/vmware-workstation-cli
```

## Requirements

- VMware Workstation with `vmrun.exe`
- Windows PowerShell environment
- VMware Tools in guest VMs (for guest operations)

## License

See LICENSE file for details.
