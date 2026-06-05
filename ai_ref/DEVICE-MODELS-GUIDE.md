---
layout: default
title: Device Models Guide
parent: AI Reference
nav_order: 9
---

# LTspice Device Models Guide

Using, creating, and integrating device models — MOSFETs, inductors, op-amps, transformers, and third-party models.

---

## Table of Contents

1. [MOSFET Models](#mosfet-models)
2. [Inductor Models](#inductor-models)
3. [Universal Op-Amp Models](#universal-op-amp-models)
4. [Simulating Transformers](#simulating-transformers)
5. [Third-Party Models](#third-party-models)
6. [Model Compatibility](#model-compatibility)

---

## MOSFET Models

### Intrinsic VDMOS

LTspice includes a proprietary MOSFET model that directly encapsulates the charge behavior of vertical double-diffused MOS transistors. Power devices are modeled as intrinsic VDMOS devices (no subcircuit wrapper needed), giving faster simulation than generic SPICE approaches.

### Standard SPICE MOSFETs

All standard SPICE MOSFET levels (1–73) are also available. See [CIRCUIT-ELEMENTS-REFERENCE.md](CIRCUIT-ELEMENTS-REFERENCE.md) for the full level table.

### Adding Custom MOSFET Models

Create the file:
```
Documents\LTspice\user.mos
```

Use the same format as the standard library at `%LOCALAPPDATA%\LTspice\lib\cmp\standard.mos`.

**Do not edit `standard.mos`** — it is overwritten on updates.

### Using Subcircuit-Based MOSFET Models

For third-party MOSFET models provided as `.subckt`:
1. Change the component Prefix attribute from `M` to `X` (Ctrl+right-click on symbol)
2. Set the Value attribute to match the subcircuit name
3. Include the model file via `.include` or `.lib` directive

---

## Inductor Models

### Default Parasitic Resistance

LTspice adds a default series resistance to inductors for SMPS transient analysis:
- Default Rser: **1 milliohm** (for inductors NOT in a mutual inductance statement)
- This allows integration as Norton equivalent (smaller matrix, faster simulation)

**To disable**: Set `Rser=0` explicitly on the inductor instance (forces Thevenin equivalent integration).

**To disable globally**: Tools > Settings > Hacks! → uncheck "Supply a min. inductor damping if no Rpar is given"

### Adding Custom Inductor Models

Create: `Documents\LTspice\user.ind`

Access custom inductors: right-click inductor on schematic > "Select Inductor"

**Do not edit** `%LOCALAPPDATA%\LTspice\lib\cmp\standard.ind`.

### Coupled Inductors

Draw independent inductors, then add a mutual inductance statement:
```spice
K1 L1 L2 1
```

See [CIRCUIT-ELEMENTS-REFERENCE.md](CIRCUIT-ELEMENTS-REFERENCE.md) for K element syntax and hysteretic core model parameters.

---

## Universal Op-Amp Models

LTspice provides four levels of universal op-amp models with increasing fidelity:

### UniversalOpAmp1 — Simple Gain Block

- Single pole in gain/phase response
- Nearly ideal gain stage with realistic rise/fall times
- Input voltage noise and current noise

### UniversalOpAmp2 — With Limits

Level 1 features plus:
- Slew rate limiting
- Output voltage limiting
- Output current limiting

Useful as a realistic gain block or for voltage/current limiting applications.

### UniversalOpAmp3a / 3b — Two-Pole Response

Level 2 features plus:
- Second pole in gain/phase response (both 3a and 3b)
- Propagation delay (3b only)

Useful for basic small-signal stability or gain/phase analysis.

### UniversalOpAmp4 — Full Intermediate Model

Level 3 features plus:
- Input capacitance
- Output resistance
- Virtual ground support

Useful for:
- Intermediate stability analysis across loads and feedback networks
- Floating power supply applications (e.g., 4-20mA transmitters)

### Parameters

All levels include input voltage noise and input current noise parameters. Complete parameter documentation is in the example circuit:
```
File > Open Examples > Educational > UniversalOpAmp.asc
```

---

## Simulating Transformers

### Basic Transformer

Draft two or more inductors, then add a mutual inductance SPICE directive:

```spice
K1 L1 L2 1
```

- Inductors in a K statement display phasing dots
- Coupling coefficient K=1 means zero leakage inductance
- Turns ratio = sqrt(L1/L2). Example: 1:3 turns ratio → 1:9 inductance ratio

### Practical Transformer Modeling

| Parameter | How to Measure | How to Use |
|-----------|---------------|------------|
| Winding inductance | DC LCR meter | Use directly as L value |
| Winding ESR | Ohmmeter | Use 2x DC value (frequency effects) |
| Leakage inductance | Short all but one winding, measure with LCR meter | Adjust K coefficient |
| Resonant frequency & Q | Measure | Set Cpar and Rpar on most inductive winding |

### Calculating Coupling Coefficient from Leakage

```
K = sqrt(1 - Lleak / sqrt(L1 * L2))
```

Or equivalently:
```
Lleak = sqrt(L1 * L2) * (1 - K^2)
```

### Example

```spice
* 1:3 transformer (1:9 inductance ratio) with K=0.99
L1 pri1 pri2 10u
L2 sec1 sec2 90u
K1 L1 L2 0.99
```

### Non-Linear Transformer

See example: File > Open Examples > Educational > NonLinearTransformer.asc

Uses the hysteretic core model parameters (Hc, Br, Bs, Lm, Lg, A, N) on the inductor element.

---

## Third-Party Models

### Type 1: .MODEL Statements (Intrinsic Devices)

For diodes, transistors, and other primitive SPICE elements where the model is a `.model` statement.

**Usage**:
1. Edit component Value to match the model name
2. Include the model definition via one of:
   - SPICE directive pasted on schematic
   - `.include <filename>` directive
   - Add to user library (e.g., `Documents\LTspice\user.bjt`)

**Example — NPN Transistor**:
```spice
* On schematic: set Q1 Value = "BC547C"
* Then add directive:
.model BC547C NPN(Is=1.8e-14 Bf=400 Vaf=80)
```

Or:
```spice
.include "C:\models\BC547C.mod"
```

### Type 2: .SUBCKT Statements (Complex Models)

For op-amps, regulators, and other models composed of multiple internal devices.

**Usage**:
1. Edit component Value to match the subcircuit name
2. Change component Prefix to `X` (Ctrl+right-click)
3. Include the subcircuit definition:
   - Paste full `.subckt ... .ends` as multi-line SPICE directive
   - `.include <filename>` directive

**Example — Op-Amp**:
```spice
* Set component Value = "TL072", Prefix = "X"
.include "TL072.sub"
```

### Creating Symbols for Third-Party Models

**Recommended approach for subcircuit models**:
1. Open the netlist file containing the `.subckt` definition
2. Place cursor on the `.subckt` line
3. Right-click > **Create Symbol**
4. LTspice generates the `.asy` file automatically with correct pin order

**For auto-include library symbols**:
Set symbol attributes:
```
Prefix: X
SpiceModel: <library_filename>
Value2: <subcircuit_name>
```

### Pin Order

**Critical**: Symbol pin netlist order must match the `.subckt` port order. Automatic symbol generation handles this correctly. If creating symbols manually, verify pin order matches.

### User Library Files

| Device Type | User Library File |
|-------------|-------------------|
| Diodes | `Documents\LTspice\user.dio` |
| BJTs | `Documents\LTspice\user.bjt` |
| MOSFETs | `Documents\LTspice\user.mos` |
| JFETs | `Documents\LTspice\user.jft` |
| Inductors | `Documents\LTspice\user.ind` |
| Resistors | `Documents\LTspice\user.res` |

**Never edit** files in `%LOCALAPPDATA%\LTspice\lib\cmp\` — they are overwritten on update.

---

## Model Compatibility

### LTspice SMPS Models

LTspice switching regulator macromodels use proprietary native devices for optimal simulation speed. These models are **not compatible** with PSpice or other simulators.

### PSpice Models in LTspice

LTspice can run PSpice semiconductor and behavioral models. Standard SPICE model statements (`.model`) and most subcircuit models work without modification.

### Speed Considerations

- LTspice native SMPS models: fastest simulation speed
- Generic SPICE/PSpice macromodels: functional but slower
- LTspice can often run third-party switching regulator models faster than their original simulator

---

*See also: [CIRCUIT-ELEMENTS-REFERENCE.md](CIRCUIT-ELEMENTS-REFERENCE.md) for component syntax and model parameters, [SIMULATION-COMMANDS-REFERENCE.md](SIMULATION-COMMANDS-REFERENCE.md) for .MODEL and .LIB directives*
