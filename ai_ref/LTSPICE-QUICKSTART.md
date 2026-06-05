---
layout: default
title: Quickstart Guide
parent: AI Reference
nav_order: 1
---

# LTspice Quickstart Guide

Getting started with LTspice — installation, interface, command line, and first simulation.

---

## About LTspice

LTspice is a general-purpose SPICE simulator with built-in schematic capture, developed by Analog Devices (originally Linear Technology). It is freely distributed without license or limits, with a large collection of component models for simulating analog circuits with high confidence.

- Website: https://www.analog.com/ltspice
- Training materials: https://www.analog.com/ltspice (videos, articles, tips)
- Change log: Help > Show LTspice Change Log

---

## Installation


**Download**: https://www.analog.com/ltspice

**Updates**:
- Program: **Help > Check for LTspice updates**
- Components/models: **Tools > Update components**

**Important**: Files in `%LOCALAPPDATA%/LTspice` are replaced on update. Do not place or edit files in this directory. To add custom symbols or simulation files, place them in the user files directory (default `Documents\LTspice\`), or in directories listed under **Settings > Search Paths** (symbol search paths for symbols, simulation library search paths for model/subcircuit files).

---

## Basic Workflow

1. Draw a circuit (or open an example: **File > Open Examples...**)
2. Place simulation command (`.tran`, `.ac`, etc.) as text on schematic
3. Run simulation (**Run** button or default shortcut Alt+R)
4. Click nodes on schematic to plot voltages; click components to plot currents
5. Iterate the circuit until desired behavior is achieved

---

## File Types

| Extension | Description |
|-----------|-------------|
| `.asc` | Schematic file (graphical circuit) |
| `.net`, `.cir`, `.sp` | SPICE netlist (text circuit description) |
| `.raw` | Simulation output waveform data |
| `.log` | Simulation log (errors, measurements, operating point) |

A schematic is converted to a netlist (`.net`) automatically when simulated. You can also open and simulate text netlists directly.

---

## Editing Modes

### Assisted Mode — Specialized Component Editors

Right-click on the **body** of a component to open its specialized editor. Works for: resistors, capacitors, inductors, diodes, BJTs, MOSFETs, JFETs, voltage/current sources, and hierarchical blocks. These editors provide access to component databases.

### Expert Mode — Edit Visible Attributes

Point at a visible attribute (value, name) and right-click. The cursor changes to a text caret, allowing direct editing. Convenient for quickly changing component values.

### Super Expert Mode — Full Attribute Editor

Hold **Ctrl** and right-click on the component body. Opens a dialog showing ALL available symbol attributes with visibility checkboxes.

Key attributes:
| Attribute | Purpose |
|-----------|---------|
| InstName | Reference designator (R1, C2, U1) |
| Value | Primary value (resistance, source waveform, etc.) |
| Value2 | Secondary value |
| SpiceModel | Model name |
| SpiceLine | Additional SPICE parameters |
| SpiceLine2 | More SPICE parameters |
| Prefix | Netlist prefix character |

---

## Keyboard Shortcuts

- View shortcuts: **Help > Keyboard Shortcut Cheat Sheet** (always-on-top window)
- Customize: Click **Edit Keyboard Shortcuts** button in cheat sheet
- Save/load shortcut sets from files
- Shortcuts persist between sessions

---

## Command Line Switches

**Executable path** (depends on installation method):
- Per-user install: `C:\Users\<username>\AppData\Local\Programs\ADI\LTspice\LTspice.exe`
- System-wide install: `C:\Program Files\ADI\LTspice\LTspice.exe`

```
LTspice.exe [options] [filename]
```

| Switch | Description |
|--------|-------------|
| `-b` | Batch mode (e.g., `ltspice.exe -b deck.cir`) |
| `-Run` | Open and immediately simulate |
| `-netlist` | Convert schematic to netlist (batch) |
| `-PCBnetlist` | Convert schematic to PCB netlist (batch) |
| `-big` / `-max` | Start maximized |
| `-alt` | Use alternate solver |
| `-norm` | Use normal solver |
| `-ascii` | ASCII .raw files (degrades performance) |
| `-FastAccess` | Convert .raw to Fast Access format |
| `-encrypt` | Encrypt a model library |
| `-ini <path>` | Specify alternate .ini file |
| `-I<path>` | Add symbol/file search path |
| `-sync` | Update component libraries |
| `-version` | Print version |
| `-FixUpSchematicFonts` | Fix old schematic font sizes |
| `-FixUpSymbolFonts` | Fix old symbol font sizes |

**Environment variables**:
- `PASTE_OMEGA` — paste Unicode Ω instead of "Ohm"
- `CAPITAL_KILO` — prefer uppercase for multipliers > 1

---

## Example Circuits

Access via **File > Open Examples...**

| Directory | Content |
|-----------|---------|
| `Educational/` | Non-commercial examples illustrating analysis types and features |
| `Applications/` | Example circuits for ADI products (verify component values for your design) |

Location on disk: `%LOCALAPPDATA%\LTspice\examples\`

LTspice includes Windows Explorer preview handlers for `.asc` files.

---

## Settings

Access via **Tools > Settings**. Items marked with `*` persist between sessions.

| Setting | Description |
|---------|-------------|
| Marching Waveforms | Incrementally plot during simulation |
| Generate Expanded Listing | Dump flat netlist to log file |
| Save all open files on start | Sync in-memory and disk schematics |
| Automatically delete .raw files | Clean up waveform data on close |
| Background image | Custom JPEG at `%USERPROFILE%\LTspice.jpg` |
| Toolbar Style | New (2026) or legacy icons |
| Toolbar icon size | Larger or smaller icons |
| RAM for Fast Access | Tune memory for file conversion |
| Directory for Temporary Files | Location for update downloads |

---

## First Simulation — RC Low-Pass Filter

### As Schematic

1. **File > New Schematic**
2. Place components: voltage source, resistor, capacitor, ground
3. Wire them together
4. Set values: V1 = `PULSE(0 1 0 1n 1n 0.5u 1u)`, R1 = `1K`, C1 = `100n`
5. Add simulation command as text: `.tran 5u`
6. Click **Run**
7. Click the output node to see the waveform

### As Netlist

Create a file `rc_filter.cir`:
```spice
* RC Low-Pass Filter
V1 in 0 PULSE(0 1 0 1n 1n 0.5u 1u)
R1 in out 1K
C1 out 0 100n
.tran 5u
.end
```

Run from command line:
```
ltspice.exe -b "C:\path\to\rc_filter.cir"
```

Or open in LTspice and press Run.

---

## Critical Conventions

### Unit Notation

**Always use `u` for micro (1e-6), never the μ symbol in netlists.**

```spice
C1 out 0 1u        ; correct: 1 microfarad
.tran 100u          ; correct: 100 microseconds
```

See [SPICE-SYNTAX-REFERENCE.md](SPICE-SYNTAX-REFERENCE.md) for the full multiplier table.

### Common Pitfall

`1M` = 1 **milli** (1e-3), not 1 mega. Use `1Meg` for megaohms.

### File Paths

Always use complete absolute paths when opening files from command line:
```
ltspice.exe "C:\Projects\MyCircuit\filter.asc"
```

---

*See also: [SIMULATION-COMMANDS-REFERENCE.md](SIMULATION-COMMANDS-REFERENCE.md) for all dot commands, [CIRCUIT-ELEMENTS-REFERENCE.md](CIRCUIT-ELEMENTS-REFERENCE.md) for component syntax, [TROUBLESHOOTING-GUIDE.md](TROUBLESHOOTING-GUIDE.md) for fixing simulation problems*
