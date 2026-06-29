---
title: LTspice Troubleshooting Guide
description: Convergence failures, debugging, and simulator options — diagnosing and fixing common simulation problems.
version: "24+"
---

[← AI Reference](README.md)

# LTspice Troubleshooting Guide

Diagnosing and fixing convergence failures, performance issues, and common simulation problems.

---

## Table of Contents

1. [Diagnostic Information Collection](#diagnostic-information-collection)
2. [Convergence Problems — Symptoms](#convergence-problems--symptoms)
3. [Common Sources of Convergence Failure](#common-sources-of-convergence-failure)
4. [Debugging with Convergence Reports](#debugging-with-convergence-reports)
5. [Fix the Circuit](#fix-the-circuit)
6. [Improve DC Operating Point Convergence](#improve-dc-operating-point-convergence)
7. [Improve Transient Convergence](#improve-transient-convergence)
8. [Integration Methods](#integration-methods)
9. [Use Initial Conditions (UIC)](#use-initial-conditions-uic)
10. [Waveform Compression](#waveform-compression)
11. [Steady-State Detection](#steady-state-detection)
12. [Memory and Performance](#memory-and-performance)

---

## Diagnostic Information Collection

When troubleshooting LTspice issues (especially FRA, convergence, or model-related problems), collect this diagnostic information first:

### 1. LTspice Version
- Go to **Help → About LTspice**
- Note the full version string (e.g., "Version (x64): 26.0.2")

### 2. Component Library Update Status
- Check date of most recent model update by going to **Help → Show Model Change Log**
  - The most recent entry shows the last update date
- Note the date of the last successful update
- If outdated (>30 days), run the update (**Tools → Update Components**) before continuing troubleshooting

### 3. SPICE Settings
- Go to **Tools → Settings**
- Click the **SPICE** settings tab
- Screenshot or document all settings, especially:
  - Integration method (Trapezoidal vs. Gear)
  - Maximum timestep
  - Any custom tolerance settings (abstol, reltol, gmin, etc.)
  - Convergence-related options (cshunt, gshunt, itl4)

### 4. Error Messages and Logs
- Go to **View → SPICE Output Log** (Ctrl+L)
- Copy the full error output, especially:
  - Convergence failure messages
  - Time step information
  - Problem instance/node names
  - Any warnings about models or components

### 5. Circuit Context
- Note what analysis is failing (DC op point, transient, AC, etc.)
- If transient: at what simulation time does failure occur?
- Recent changes to circuit before problem appeared
- Whether the issue is reproducible

---

## Convergence Problems — Symptoms

### Simulation Stops with Errors

| Error Message | Meaning |
|---------------|---------|
| `Time step too small` | Simulator cannot find a solution at the current timepoint |
| `Singular matrix` | Circuit topology problem (floating node, voltage source loop) |
| `Iteration limit reached` | Exceeded max Newton-Raphson iterations |
| `Failure to find initial operating point` | Cannot solve DC bias point |

Example error output:
```
Convergence Failure: Time step too small; time = 1.0005e-06, timestep = 1.25e-19: trouble with instance "A2"
Simulation Failed: Iteration limit reached
```

### Simulation Runs but is Slow

- Very small time steps / slow transient speed
- Very slow pseudo-transient while finding operating point
- Borderline circuits may converge or fail depending on minor changes

---

## Common Sources of Convergence Failure

1. **Discontinuities in I-V curve** — abrupt changes in device behavior
2. **Instantaneous changes** — zero rise/fall times
3. **Discontinuities in first derivative** — kinks in device characteristics
4. **Extremely high-impedance nodes** — nodes with zero capacitance to ground
5. **Immediate local feedback** — behavioral sources feeding back instantaneously

---

## Debugging with Convergence Reports

Enable convergence reporting to identify problem devices and nodes:

```spice
.tran 10u convreport
```

Or add as a simulator option:
```spice
.options debugtran
```

### Reading the Report

The report assigns difficulty scores to devices and nodes:

```
Device Convergence Difficulty Score:
  m5:gcapgd      : 55.276382
  m3:gcapgd      : 54.522613

Node Convergence Difficulty Score:
  s3#current     : 76.884422
  s4#current     : 61.557789
```

**Interpretation**:
- Scores below 1: negligible, ignore
- Scores above ~50: problematic, investigate these devices/nodes
- Higher scores = more convergence difficulty

**Note**: Enabling convergence reports slows the simulation.

---

## Fix the Circuit

These circuit-level changes resolve most convergence problems:

### 1. Add Capacitance to High-Impedance Nodes

Even tiny capacitance (1f to 1p) helps the simulator:
```spice
C_fix high_z_node 0 1f
```

### 2. Avoid Discontinuities

**Ideal diodes**: Add/increase the `epsilon` parameter or increase `Ron`:
```spice
.model MySwitch SW(Vt=0 Vh=-0.1 Ron=10m)
```

**Logic gates**: Always define `trise` (10n is a good starting point):
```spice
A1 in 0 0 0 0 out 0 0 BUF Trise=10n
```

**Avoid extreme non-physical values** (e.g., diode emission coefficient n=0.001).

### 3. Avoid Instantaneous Feedback

- Don't model a capacitor with a behavioral current source — use Nonlinear Capacitor (`Q=` syntax)
- Don't connect logic gate output directly back to its input without delay

### 4. Add Series Resistance to Signal Sources

```spice
V1 in 0 PULSE(0 5 0 1n 1n 0.5u 1u) Rser=1 Cpar=1p
```

Not recommended for power supplies or when monitoring source current.

---

## Improve DC Operating Point Convergence

Try these in order (least to most aggressive):

### Circuit Directives

| Method | Syntax | Description |
|--------|--------|-------------|
| Nodeset | `.nodeset V(node)=<val>` | Suggest initial guess (recommendation only) |
| Initial condition | `.ic V(node)=<val>` | Force initial node voltage |
| Startup ramp | `.tran 1m startup` | Ramp external sources from zero over first 20u |

### Simulator Options

| Option | Default | Try | Effect |
|--------|---------|-----|--------|
| `solver` | norm | alt | Higher precision (slower) |
| `abstol` | 1e-12 | 1e-10 | Loosen current tolerance |
| `reltol` | 0.001 | 0.005 | Loosen relative tolerance |
| `gmin` | 1e-12 | 1e-10 | More conductance on PN junctions |
| `gshunt` | 0 | 1e-15 | Conductance from every node to ground |

**Example**:
```spice
.options gshunt=1e-15 reltol=0.003
.ic V(vout)=3.3 V(sw_node)=12
```

---

## Improve Transient Convergence

### Simulator Options (listed in recommended order to try)

Increasing the value of these numerical options (except `itl4`) sacrifices accuracy for the sake of convergence.

| Option | Default | Try | Effect |
|--------|---------|-----|--------|
| `method` | trap | gear | Gear dampens oscillations (slower) |
| `itl4` | 10 | 50 | More iterations per timepoint |
| `cshunt` | 0 | 1e-15 | Capacitance from every node to ground |
| `abstol` | 1e-12 | 1e-10 | Loosen current tolerance |
| `gshunt` | 0 | 1e-15 | Conductance from every node to ground |
| `reltol` | 0.001 | 0.005 | Loosen relative tolerance |
| `maxstep` | tstop/1024 | explicit | Limit maximum step size |
| `solver` | norm | alt | Higher precision solver |

**Example**:
```spice
.options method=gear itl4=50 cshunt=1f
```

### State Save/Load for Partial Relaxation

Temporarily loosen tolerances for startup, then reload state and continue with tight tolerances. Only one `.tran` command can be active at a time — comment out the previous one for each run:

```spice
; Run 1: loose tolerances to get past startup
.options reltol=0.01
.tran 1m savestate

; Run 2: comment out the above .tran, then use:
; .options reltol=0.001
; .tran 10m loadstate
```

---

## Integration Methods

LTspice offers two integration methods (set via `.options method=`):

### Trapezoidal (trap) — Default

- Fastest for equivalent accuracy
- Most accurate
- Can produce "trap ringing" — oscillations timestep-to-timestep around true solution

### Gear

- Requires more time steps for same accuracy
- Generally slower
- Imposes artificial numerical dampening
- **Warning**: Can make unstable circuits appear stable in simulation
- Use when trap ringing is problematic

**Recommendation**: Start with default (trap). Switch to `gear` if you see ringing artifacts or need additional convergence help.

---

## Use Initial Conditions (UIC)

```spice
.tran 1m uic
```

**What it does**: Skips DC operating point analysis and uses user-specified initial conditions on components.

**Why it's NOT recommended**:
- Creates nonphysical initial state
- Voltage source in parallel with uncharged capacitor → infinite current in first timestep
- Often results in "time step too small" errors
- **Not a viable workaround for DC operating point convergence problems**

**When to use**: Only when you specifically need to study startup behavior from a known initial state and have properly set all initial conditions.

**Better alternatives for operating point problems**:
- `.nodeset` / `.ic` directives
- `startup` modifier
- `.options` adjustments (see above)
- `loadstate` from a previous successful simulation

---

## Waveform Compression

LTspice optionally uses lossy compression at runtime to keep `.raw` files manageable.

### Configuration

```spice
.options plotwinsize=<N>       ; Points per compression window (0=disable)
.options plotreltol=<val>      ; Relative tolerance (default 0.0025)
.options plotvntol=<val>       ; Voltage tolerance (default 10u)
.options plotabstol=<val>      ; Current tolerance (default 1n)
```

### When to Disable Compression

Turn off compression (`plotwinsize=0`) when:
- Using `.four` statements
- Doing FFT in post-analysis
- Need exact sample-by-sample data

```spice
.options plotwinsize=0
```

### Important Notes

- To configure settings for a specific schematic, add `.options` directive to schematic
- Leave disabled (default) for most simulations

---

## Steady-State Detection

Stop simulation automatically when steady state is reached.

```spice
.tran 10m steady
```

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `sstol` | 0.001 | Fraction of peak current considered "zero" |
| `ststdelay` | 0 | Time to wait before starting detection |
| `ststclocks` | 10 | Clock cycles after detection before stopping |

### Interactive Steady-State Specification

1. Start simulation
2. **Simulate > Efficiency Calculation > Mark Start** — tells LTspice you're specifying limits manually
3. Wait for circuit to reach steady state visually
4. Execute **Mark Start** again — clears history, restarts efficiency calculation
5. Wait 10+ clock cycles
6. **Simulate > Efficiency Calculation > Mark End**

### Tips

- Use `.ic` to set initial node voltages and inductor currents to reduce startup time
- Each Mark Start execution clears waveform history (helps limit file size)
- Required for efficiency calculation reports

---

## Memory and Performance

### System Requirements

If you can run Windows, you can run LTspice. Significant effort is spent minimizing memory usage.

### Waveform Storage

- All waveform data stored on **disk** during simulation
- Only plotted traces loaded into RAM
- No particular file size limit — can handle multi-gigabyte `.raw` files
- Can turn off marching waveforms to reduce memory during simulation

### Reducing Data Size

1. **Disable subcircuit internals** in Settings > Save Defaults: uncheck "Save Subcircuit Node Voltages" and "Save Subcircuit Device Currents"

2. **Use `.save`** to limit saved traces:
   ```spice
   .save V(out) V(fb) I(L1)
   ```

3. **Limit simulation time** or use `Tstart` parameter:
   ```spice
   .tran 0 10m 9m    ; only save last 1ms of 10ms simulation
   ```

4. **Enable waveform compression** (default is disabled)

### Emergency: Running Out of Disk Space

During transient analysis, press the **`0` key** to discard past waveform data and reset the time axis to t=0 at the current simulation time. This frees disk space immediately.

---

*See also: [SIMULATION-COMMANDS-REFERENCE.md](SIMULATION-COMMANDS-REFERENCE.md) for .OPTIONS details, [CIRCUIT-ELEMENTS-REFERENCE.md](CIRCUIT-ELEMENTS-REFERENCE.md) for component parameters*
