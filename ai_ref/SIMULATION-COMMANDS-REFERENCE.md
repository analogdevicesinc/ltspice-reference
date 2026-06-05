---
layout: default
title: Simulation Commands Reference
parent: AI Reference
nav_order: 6
---

# LTspice Simulation Commands Reference

Complete reference for all dot commands (simulation directives) in LTspice.

---

## Table of Contents

1. [Analysis Types](#analysis-types)
   - [.TRAN — Transient Analysis](#tran--transient-analysis)
   - [.AC — AC Analysis](#ac--ac-analysis)
   - [.DC — DC Sweep](#dc--dc-sweep)
   - [.OP — DC Operating Point](#op--dc-operating-point)
   - [.NOISE — Noise Analysis](#noise--noise-analysis)
   - [.TF — Transfer Function](#tf--transfer-function)
   - [.FRA — Frequency Response Analysis](#fra--frequency-response-analysis)
   - [.FOUR — Fourier Analysis](#four--fourier-analysis)
2. [Measurement & Output](#measurement--output)
   - [.MEASURE — User-Defined Measurements](#measure--user-defined-measurements)
   - [.SAVE — Limit Saved Data](#save--limit-saved-data)
   - [.WAVE — Output WAV File](#wave--output-wav-file)
   - [.FOUR — Fourier Components](#four--fourier-analysis)
3. [Parameter Control](#parameter-control)
   - [.PARAM — User-Defined Parameters](#param--user-defined-parameters)
   - [.FUNC — User-Defined Functions](#func--user-defined-functions)
   - [.STEP — Parameter Sweeps](#step--parameter-sweeps)
   - [.TEMP — Temperature Sweeps](#temp--temperature-sweeps)
4. [Simulator Configuration](#simulator-configuration)
   - [.OPTIONS — Simulator Options](#options--simulator-options)
5. [Circuit Structure](#circuit-structure)
   - [.SUBCKT / .ENDS — Subcircuit Definition](#subckt--ends--subcircuit-definition)
   - [.MODEL — SPICE Model Definition](#model--spice-model-definition)
   - [.INCLUDE — Include File](#include--include-file)
   - [.LIB — Include Library](#lib--include-library)
   - [.GLOBAL — Global Nodes](#global--global-nodes)
   - [.END — End of Netlist](#end--end-of-netlist)
6. [State Management](#state-management)
   - [.SAVESTATE — Save Circuit State](#savestate--save-circuit-state)
   - [.LOADSTATE — Load Circuit State](#loadstate--load-circuit-state)
   - [.SAVEBIAS — Save Operating Point](#savebias--save-operating-point)
7. [Advanced](#advanced)
   - [.MACHINE — State Machine](#machine--state-machine)
   - [.NET — Network Parameters](#net--network-parameters)
   - [.BACKANNO — Pin Annotation](#backanno--pin-annotation)

---

## Analysis Types

### .TRAN — Transient Analysis

Simulates circuit behavior over time when powered up.

```spice
.tran <Tstop> [modifiers]
.tran <Tstep> <Tstop> [Tstart [dTmax]] [modifiers]
```

| Parameter | Description |
|-----------|-------------|
| Tstep | Plotting increment / initial step-size guess (can be 0) |
| Tstop | Duration of simulation (required) |
| Tstart | Start time for saving data (data before this discarded) |
| dTmax | Maximum time step |

**Modifiers**:

| Modifier | Description |
|----------|-------------|
| uic | Skip DC operating point, use initial conditions |
| steady | Stop when steady state reached |
| nodiscard | Keep data before steady state |
| startup | Solve with sources off, ramp on in first 20u |
| step | Compute step response |
| convreport | Add convergence scores to log |

**State file options**: `loadstate[=<file>]`, `savestate[=<file>]`, `savestatetime=<time>`

**Examples**:
```spice
.tran 5u
.tran 0 1m startup
.tran 10n 100u 0 10n
.tran 1m steady savestate
```

---

### .AC — AC Analysis

Small-signal AC analysis linearized about the DC operating point.

```spice
.ac <oct|dec|lin> <Nsteps> <StartFreq> <EndFreq>
.ac list <Freq1> [<Freq2> ...]
.ac file=<filename>
```

| Parameter | Description |
|-----------|-------------|
| oct | Logarithmic, Nsteps per octave |
| dec | Logarithmic, Nsteps per decade |
| lin | Linear, Nsteps total |
| Nsteps | Number of frequency points |
| StartFreq | Starting frequency |
| EndFreq | Ending frequency |

**Examples**:
```spice
.ac dec 100 1 1Meg
.ac oct 10 100 100K
.ac lin 1000 1K 10K
.ac list 60 120 1K 10K 100K
.ac file=freq_list.txt
```

---

### .DC — DC Sweep

Sweeps DC value of one or more sources. Up to 3 nested sweeps.

```spice
.dc <srcnam> <start> <stop> <incr>
.dc [oct|dec|lin] <srcnam> <start> <stop> <incr>
.dc <srcnam> list <val1> [<val2> ...]
.dc <srcnam> file=<filename>
```

**Nesting** (up to 3 sweeps):
```spice
.dc Vds 0 5 0.05 Vgs 0 5 1
```

**Examples**:
```spice
.dc V1 0 5 0.1
.dc Vds 3.5 0 -0.05 Vgs 0 3.5 0.5
.dc dec R1 1K 1Meg 10
```

---

### .OP — DC Operating Point

Finds DC operating point (capacitors open, inductors shorted).

```spice
.op
```

No parameters. Results appear in dialog and status bar. Usually performed automatically as part of other analyses.

**Operating point methods** (tried in order):
1. Direct Newton iteration
2. Adaptive Gmin stepping
3. Adaptive source stepping
4. Pseudo transient

Use `.options logopinfo` to log semiconductor operating point information.

---

### .NOISE — Noise Analysis

Computes noise spectral density (Johnson, shot, flicker sources).

```spice
.noise V(<out>[,<ref>]) <src> <oct|dec|lin> <Nsteps> <StartFreq> <EndFreq>
.noise V(<out>[,<ref>]) <src> list <Freq1> [<Freq2> ...]
.noise V(<out>[,<ref>]) <src> file=<filename>
```

| Parameter | Description |
|-----------|-------------|
| V(out[,ref]) | Output node(s) for noise calculation |
| src | Reference source (input-referred noise) |

**Output traces**:
- `V(onoise)` — output-referred noise voltage density
- `V(inoise)` — input-referred noise density

Ctrl+click on trace label to integrate noise over bandwidth.

**Example**:
```spice
.noise V(out) Vin dec 100 1 10Meg
```

---

### .TF — Transfer Function

DC small-signal transfer function analysis.

```spice
.TF V(<node>[,<ref>]) <source>
.TF I(<Vsource>) <source>
```

**Examples**:
```spice
.TF V(out) Vin
.TF V(5,3) Vin
.TF I(Vload) Vin
```

---

### .FRA — Frequency Response Analysis

Time-domain frequency response analysis for feedback loops (e.g., SMPS stability). Requires FRA device instance (prefix `@`).

```spice
.fra [Tstart=<val>] [dTmax=<val>] [Tstep=<val>] [Tstop=<val>]
+ [uic] [startup] [loadstate[=<file>]] [savestate[=<file>]]
```

All parameters optional, specified by keyword. FRA automatically stops when all FRA devices complete analysis.

See: File > Open Examples > Educational\FRA\

---

### .FOUR — Fourier Analysis

Computes Fourier series components after transient analysis. Output in .log file.

```spice
.four <frequency> [Nharmonics] [Nperiods] <trace1> [<trace2> ...]
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| frequency | Fundamental frequency | — |
| Nharmonics | Number of harmonics | 9 |
| Nperiods | Periods to analyze (-1 = all data) | 1 (last period) |

**Example**:
```spice
.four 1K V(out)
.four 60 15 V(output) I(Vsupply)
```

---

## Measurement & Output

### .MEASURE — User-Defined Measurements

Post-processing command to extract measurements from simulation results.

#### Single-Point Measurement

```spice
.meas [TRAN|AC|DC|NOISE] <name> <FIND|DERIV|PARAM> <expr>
+ [WHEN <condition> | AT=<value>]
+ [TD=<delay>] [RISE|FALL|CROSS=<count>|LAST]
```

#### Range Measurement

```spice
.meas [TRAN|AC|DC|NOISE] <name> <AVG|MAX|MIN|PP|RMS|INTEG> <expr>
+ [TRIG <expr> [VAL=]<val> [TD=<val>] [RISE|FALL|CROSS=<count>]]
+ [TARG <expr> [VAL=]<val> [TD=<val>] [RISE|FALL|CROSS=<count>]]
```

**Range operations**:

| Operation | Description |
|-----------|-------------|
| AVG | Average over range |
| MAX | Maximum value |
| MIN | Minimum value |
| PP | Peak-to-peak |
| RMS | Root mean square |
| INTEG | Integral |

**Examples**:
```spice
.meas TRAN Vmax MAX V(out)
.meas TRAN Trise TRIG V(out)=0.5 RISE=1 TARG V(out)=4.5 RISE=1
.meas TRAN Pwr AVG V(out)*I(Vout)
.meas TRAN Vfinal FIND V(out) AT=10u
.meas TRAN Vcross FIND V(out) WHEN V(clk)=2.5 CROSS=3
.meas TRAN delay PARAM Trise*2
.meas AC fc WHEN mag(V(out))=mag(V(out))/sqrt(2) FALL=1
.meas AC BW TRIG mag(V(out))=tmp/sqrt(2) RISE=1 TARG mag(V(out))=tmp/sqrt(2) FALL=LAST
.meas NOISE total_noise INTEG V(onoise)
```

**Output**: Results in .log file. With `.step`, results form tables. Data saved to SQLite `.db` file (see [MEASURE-DATABASE-REFERENCE.md](MEASURE-DATABASE-REFERENCE.md)).

**Note**: The output of one `.meas` statement can be used in other `.meas` statements (e.g., `PARAM Trise*2` references the `Trise` measurement).

**Viewing stepped .MEAS results in LTspice**:
1. After simulation completes, open **View > SPICE Output Log**
2. Right-click in the log file
3. Execute **Plot .step'ed .meas data** from the context menu

This plots the `.MEAS` results as waveforms indexed by step parameter value.

---

### .SAVE — Limit Saved Data

Restricts saved output to specified traces (reduces file size).

```spice
.save V(out) I(L1) I(R2)
.save V(*) Id(*)
.save V(x23:*)
```

Supports wildcards `*` and `?`. Use `:` for hierarchy (e.g., `V(x23:node1)`).

---

### .WAVE — Output WAV File

Writes simulation data to a .wav audio file.

```spice
.wave <filename.wav> <Nbits> <SampleRate> V(out) [V(out2) ...]
```

| Parameter | Range |
|-----------|-------|
| Nbits | 1–32 |
| SampleRate | 1–4,294,967,295 Hz |
| Channels | 1–65,535 |

Full-scale range: -1V to +1V (or -1A to +1A).

**Example**:
```spice
.wave C:\output.wav 16 44.1K V(left) V(right)
```

---

## Parameter Control

### .PARAM — User-Defined Parameters

Define constants and expressions for parameterized circuits.

```spice
.param <name>=<value>
.param <name>=<expression>
.param <name>="<string>"
```

**Built-in constants**:

| Name | Value |
|------|-------|
| pi | 3.14159265358979323846 |
| BOLTZ | 1.3806503e-23 |
| ECHARGE | 1.602176462e-19 |
| PLANCK | 6.62620e-34 |
| KELVIN | -273.15 |
| GMIN | 1e-12 |

**Available functions**: abs, acos, asin, atan, atan2, cos, sin, tan, cosh, sinh, tanh, exp, ln, log10, sqrt, cbrt, pow, pwr, pwrs, int, floor, ceil, round, buf, inv, u, uramp, sgn, if, limit, min, max, hypot, rand, flat, gauss, mc, mod, select, table, xor

**Operator precedence** (low to high): `& | ^` → `> < >= <= == !=` → `+ -` → `* / %` → `**`

**String parameters**: Can parameterize model/subcircuit names.
```spice
.param model_name = select(n, "1N4148", "1N4007")
```

**Examples**:
```spice
.param Rload=10K
.param freq=100K
.param RC_time=Rload*100n
.param pi2=2*pi
```

---

### .FUNC — User-Defined Functions

Create reusable functions.

```spice
.func <name>([args]) {<expression>}
```

**Example**:
```spice
.func Pythag(x,y) {sqrt(x*x+y*y)}
.func dBV(x) {20*log10(x)}

R1 a b {Pythag(300,400)}   ; = 500 ohms
```

Uses dynamic scoping: names resolved where function is called.

---

### .STEP — Parameter Sweeps

Repeatedly run analysis while sweeping a parameter. Up to 3 nested levels.

```spice
.step [oct|dec|lin] <item> <start> <end> <incr>
.step <item> list <val1> [<val2> ...]
.step <item> file=<filename>
```

**Item formats**:
- Source: `V1` or `I1`
- Parameter: `param RLOAD`
- Model parameter: `NPN 2N2222(VAF)`
- Temperature: `temp`

**Examples**:
```spice
.step param Rload 1K 10K 1K
.step param Rload list 1K 2.2K 4.7K 10K
.step V1 0 5 0.5
.step temp -40 125 5
.step NPN 2N2222(BF) 50 200 50
.step dec param freq 1K 1Meg 10
```

---

### .TEMP — Temperature Sweeps

Archaic shorthand for `.step temp list ...`.

```spice
.temp <T1> <T2> ...
```

**Example**:
```spice
.temp -55 25 85 125
```

---

## Simulator Configuration

### .OPTIONS — Simulator Options

Control simulator tolerances, integration method, waveform compression, and diagnostic output.

```spice
.options <keyword>=<value> [<keyword>=<value> ...]
.options <flag>
```

#### Convergence & Accuracy

| Option | Default | Description |
|--------|---------|-------------|
| abstol | 1p | Absolute current tolerance |
| vntol | 1u | Absolute voltage tolerance |
| reltol | 0.001 | Relative error tolerance |
| chgtol | 10f | Absolute charge tolerance |
| trtol | 2.0 | Transient truncation error factor |
| gmin | 1e-12 | Min conductance on PN junctions |
| method | trap | Integration: trap or gear |

#### Iteration Limits

| Option | Default | Description |
|--------|---------|-------------|
| itl1 | 100 | DC iteration limit |
| itl2 | 50 | DC transfer curve iteration limit |
| itl4 | 10 | Transient iteration limit per timepoint |
| gminsteps | 25 | Gmin stepping iterations (0=disable) |
| srcsteps | 25 | Source stepping iterations (0=disable) |
| ptrantau | 0.1 | Pseudo-transient time constant (0=disable) |

#### Time Step Control

| Option | Default | Description |
|--------|---------|-------------|
| maxstep | Infinite | Maximum transient step size |
| solver | — | Matrix solver: "norm" or "alt" |

#### Waveform Compression

| Option | Default | Description |
|--------|---------|-------------|
| plotreltol | 0.0025 | Relative tolerance |
| plotvntol | 10u | Absolute voltage tolerance |
| plotabstol | 1n | Absolute current tolerance |
| plotwinsize | 300 | Points per window (0=disable) |

#### Convergence Aids

| Option | Default | Description |
|--------|---------|-------------|
| gshunt | 0 | Conductance to ground from every node |
| cshunt | 0 | Capacitance to ground from every node |
| gfloat | 1e-12 | Conductance for floating nodes |

#### Temperature

| Option | Default | Description |
|--------|---------|-------------|
| temp | 27 | Default simulation temperature (C) |
| tnom | 27 | Model parameter measurement temperature (C) |

#### Diagnostics

| Option | Default | Description |
|--------|---------|-------------|
| numdgt | 6 | Significant digits (>6 = double precision) |
| measdgt | 6 | .MEASURE output digits |
| list | off | Expanded netlist in log |
| logparams | off | All parameters in log |
| logopinfo | off | Semiconductor OP info in log |
| debugtran | off | Convergence difficulty scores |
| topologycheck | 1 | Check floating nodes, voltage loops |

#### Steady-State Detection

| Option | Default | Description |
|--------|---------|-------------|
| sstol | 0.001 | Steady-state relative tolerance |
| ststdelay | 0 | Delay before detection starts |
| ststclocks | 10 | Clock cycles after steady state |

**Example**:
```spice
.options reltol=1e-4 method=gear
.options maxstep=1u gshunt=1e-12
.options numdgt=15 plotwinsize=0
```

---

## Circuit Structure

### .SUBCKT / .ENDS — Subcircuit Definition

```spice
.subckt <name> <port1> <port2> ... [params: p1=val1 p2=val2]
  [circuit elements]
.ends [<name>]
```

Instantiated with X element:
```spice
X1 node1 node2 node3 <subckt_name> [param1=val1]
```

**Example**:
```spice
.subckt divider A B C
.param top=1K bot=1K
R1 A B {top}
R2 B C {bot}
.ends divider

X1 in out 0 divider top=9K bot=1K
```

---

### .MODEL — SPICE Model Definition

```spice
.model <name> <type>[(<param1>=<val1> <param2>=<val2> ...)]
```

**Types**: D, NPN, PNP, NJF, PJF, NMOS, PMOS, NMF, PMF, SW, CSW, VDMOS, NIGBT, PIGBT, URC, LTRA

**Derived model** (inherit and override):
```spice
.model SLOW ako:FAST D(tt=10n)
```

---

### .INCLUDE — Include File

```spice
.include <filename>
```

Inserts entire file contents into netlist. Relative paths resolve from the directory containing the directive.

---

### .LIB — Include Library

```spice
.lib <filename>
.lib <filename> <section_name>
```

Like `.include` but ignores global-scope circuit elements (only imports models/subcircuits).

**Library section format**:
```spice
.lib <section_name>
  [definitions]
.endl
```

**Search order** (relative paths):
1. Directory of calling netlist
2. User libraries directory
3. User search paths
4. `%LOCALAPPDATA%\LTspice\lib\cmp`
5. `%LOCALAPPDATA%\LTspice\lib\sub`

**Encrypted libraries**: `ltspice.exe -encrypt <filename>` (irreversible — backup first!)

---

### .GLOBAL — Global Nodes

```spice
.global <node1> [<node2> ...]
```

Declares nodes as globally accessible (not local to subcircuits). Node `0` is always global. Nodes matching `$G_*` are automatically global.

```spice
.global VDD VCC RESET
```

---

### .END — End of Netlist

```spice
.end
```

All lines after `.end` are ignored. Can be omitted. Do not place on schematics (netlister adds it automatically).

---

## State Management

### .SAVESTATE — Save Circuit State

Saves complete transient simulation state in proprietary format.

```spice
.savestate [<filename>] [time=<value>]
```

- Default filename: schematic base name with `.state` extension
- Default time: saves final state on completion
- Multiple .savestate allowed in one simulation

---

### .LOADSTATE — Load Circuit State

Restores previously saved state to resume simulation.

```spice
.loadstate [<filename>] [reset]
```

- `reset`: Plot output starting at time zero
- Circuit must be identical to when state was saved

---

### .SAVEBIAS — Save Operating Point

Saves DC operating point as text file in `.nodeset` format.

```spice
.savebias <filename> [internal] [temp=<val>] [time=<val> [repeat]]
+ [step=<val>] [DC1=<val>] [DC2=<val>] [DC3=<val>]
```

Superseded by `.savestate`/`.loadstate` for transient simulations.

---

## Advanced

### .MACHINE — State Machine

Arbitrary state machine definition.

```spice
.machine [<tripdt>]
.state <name> <value>
.rule <old_state> <new_state> <condition>
.output (<node>[, <neg_node>]) <expression>
.endmachine
```

- First declared state is initial state
- Rules checked in order; only one fires per timestep
- `*` as old state matches any state
- Condition fires when expression > 0.5
- `state` keyword in expressions returns current state value

**Example — Divide by 2 with reset**:
```spice
.machine
.state S0a 0
.state S0b 0
.state S1a 1
.state S1b 1
.rule S0a S0b V(clk) < .5
.rule S0b S1a V(clk) > .5
.rule S1a S1b V(clk) < .5
.rule S1b S0a V(clk) > .5
.rule * S0a V(reset) > .5
.output (out) state
.endmachine
```

---

### .NET — Network Parameters

Computes S, Y, Z, H parameters during .AC analysis.

```spice
.net V(<out>[,<ref>]) <Vin> [Rin=<val>] [Rout=<val>]
.net I(<Rout>) <Vin> [Rin=<val>] [Rout=<val>]
```

Default termination impedances: 1 Ohm. Terminations don't affect normal .AC results.

**Example**:
```spice
.net V(out) V1 Rin=50 Rout=50
```

---

### .BACKANNO — Pin Annotation

```spice
.backanno
```

Automatically included in schematics. Enables cross-probing pin currents by clicking on symbol pins.

---

*See also: [CIRCUIT-ELEMENTS-REFERENCE.md](CIRCUIT-ELEMENTS-REFERENCE.md) for component syntax, [TROUBLESHOOTING-GUIDE.md](TROUBLESHOOTING-GUIDE.md) for convergence options*
