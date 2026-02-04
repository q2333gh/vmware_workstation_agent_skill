# VMware Workstation CLI Agent Skill

Control VMware Workstation VMs via `vmrun` CLI. Manage VM lifecycle, snapshots, guest operations, and shared folders.

## Install for LLM Agent

Copy and paste this to your LLM agent:

```
install this skill: https://raw.githubusercontent.com/q2333gh/vmware_workstation_agent_skill/master/SKILL.md
```

The agent will automatically download and install this skill.

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
