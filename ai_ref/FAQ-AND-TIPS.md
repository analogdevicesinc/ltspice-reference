---
title: LTspice FAQ and Tips
description: Updates, license, Linux, efficiency calculations, and SMPS Bode plots — frequently asked questions and practical tips.
version: "24+"
---

[← AI Reference](README.md)

# LTspice FAQ and Tips

Frequently asked questions, efficiency calculations, SMPS Bode plots, platform notes, and resources.

---

## Table of Contents

1. [Program Updates](#program-updates)
2. [License and Distribution](#license-and-distribution)
3. [Running Under Linux](#running-under-linux)
4. [Settings Overview](#settings-overview)
5. [Efficiency Calculation](#efficiency-calculation)
6. [SMPS Bode Plots (FRA)](#smps-bode-plots-fra)
7. [Additional Resources](#additional-resources)

---

## Program Updates

### Updating LTspice

Three methods:
1. Download latest from https://www.analog.com/ltspice
2. **Help > Check for LTspice updates**
3. Windows Start Menu shortcut

### Updating Components and Models

**Tools > Update components** downloads the latest component libraries and models.

### Change Logs

- **Help > Show LTspice Change Log** — program changes
- **Help > Show Model Change Log** — model/component updates

### Important Warnings

- Older versions cannot be recovered after update
- All library databases are overwritten automatically
- **Do not edit files in `%LOCALAPPDATA%\LTspice`** — they may be overwritten on update
- Store custom files in `Documents\LTspice\` (user library directory)

---

## License and Distribution

- **Classification**: EAR99 (no export restrictions)
- **License**: Non-exclusive, non-transferable for internal use and circuit simulation
- **Free**: No cost, no license limits
- **Restrictions**:
  - No modification, reverse engineering, or decompilation
  - Not licensed for semiconductor manufacturers for product design/promotion (requires special permission from ADI)
  - Not suitable for high-risk applications (nuclear, aircraft, life support, weapons, autonomous driving)
- **Jurisdiction**: Massachusetts, USA

### Third-Party Components

LTspice includes code from:
- Berkeley SPICE (University of California)
- NXP MEXTRAM model
- Hiroshima University HiSIM
- ZLIB compression
- SQLiteC++ database

---

## Running Under Linux

Analog Devices does not provide an official Linux version. LTspice runs under WINE.

### Installation

```bash
# Install WINE
# (from http://www.winehq.com)

# Download LTspice
wget https://LTspice.analog.com/download/latest/LTspice64.msi

# Install
wine msiexec /i LTspice64.msi
```

### Running

Launch from desktop icon or:
```bash
wine ltspice.exe
```

### Known Issues

- Font scaling less smooth than on Windows
- PWL editor display issues — fix with native Windows DLLs:
  ```bash
  wine -dll commctrl,comctl32=n ltspice.exe
  ```

---

## Settings Overview

Access via gear icon or **Tools > Settings**. Configuration sections:

| Tab | Purpose |
|-----|---------|
| Compression | Waveform data compression tolerances |
| Save Defaults | Default trace saving behavior |
| SPICE | General-purpose simulation settings |
| Schematic | Drafting options (grid, snap, pen, undo) |
| Netlist | Netlist generation options |
| Search Paths | Symbol and library paths |
| Waveforms | Waveform viewer appearance |
| Operation | Application behavior (marching waveforms, auto-delete, etc.) |
| Hacks | Internal development settings (deprecated) |
| Internet | Update behavior |

---

## Efficiency Calculation

### Quick Method

Add `steady` keyword to `.tran` command:
```spice
.tran 10m steady
```

### Requirements

- Exactly **one voltage source** (identifies as input)
- Exactly **one current source** or **Rload resistor** (identifies as output)

### How It Works

1. Simulation runs until steady state is detected (via switching regulator macromodel)
2. Energy stored in reactances noted at clock edges
3. Efficiency = output power / input power, adjusted for reactance energy changes
4. Report displayed as comment block on schematic

### Viewing Results

**View > Efficiency Report** after simulation completes.

### Manual Adjustment

If automatic detection is too aggressive or not critical enough:
```spice
.options sstol=0.0001      ; tighter steady-state tolerance
.options ststdelay=100u    ; wait before starting detection
```

### Checking Individual Losses

After efficiency report, check individual device power dissipation by Alt+clicking on component bodies in the schematic.

### Detailed Efficiency Analysis

For more precise efficiency estimates including switching and parasitic losses, use **LTpowerCAD**: https://www.analog.com/en/design-center/ltpowercad.html

---

## SMPS Bode Plots (FRA)

Frequency Response Analysis for measuring loop gain and phase margin of switched-mode power supplies.

### Concept

Uses Middlebrook's method (voltage injection) to measure the loop transfer function of a feedback system in the time domain. A sinusoidal stimulus is injected at the feedback loop break point, and Fourier analysis extracts gain and phase at each frequency.

### Example Circuits

**File > Open Examples > Educational\FRA\**

### Procedure

#### Step 1: Verify Basic Operation
Run a standard `.tran` simulation to confirm the SMPS starts up and reaches steady state.

#### Step 2: Insert FRA Component
Break the feedback loop and insert the FRA device (prefix `@`) at the injection point. Valid placement must satisfy two criteria:

1. **The device must completely interrupt the feedback.** Every feedback path has to pass through it. If any path bypasses the device — a feedforward capacitor around the divider, a second sense connection, an auxiliary loop — part of the loop stays closed and what you measure is not the loop gain.
2. **The device must point from lower impedance to higher impedance.** Connect the **OUT** terminal to the low-impedance side of the break and the **IN** terminal to the high-impedance side — typically OUT toward the converter output and IN toward the feedback divider or error-amplifier input. If the source impedance at the break is not small compared with the load impedance, the injection loads the loop and the measured response is corrupted.

#### Step 3: Initial Exploratory FRA
Start with 2-3 frequencies to verify the setup works — use `flist` on the FRA device to apply just those frequencies individually:
```spice
.fra
```

Key FRA device parameters (see [CIRCUIT-ELEMENTS-REFERENCE.md](CIRCUIT-ELEMENTS-REFERENCE.md#--frequency-response-analyzer) for the full list):
- **fstart**: Starting frequency (typically 100Hz-1kHz for SMPS)
- **fend**: Ending frequency (typically 100kHz-1MHz)
- **tsettle**: Settling time at each frequency before analysis begins. Start at `2/fcross`, where fcross is the expected 0dB crossover. Defaults to `10/fend`.
- **tavgmin**: Minimum analysis time per frequency. For an SMPS, start at `100/fsw`, where fsw is the switching frequency.

#### Step 4: Check for Nonlinearity
Inspect FRA transient waveforms — stimulus should be small enough to not disturb the operating point significantly.

#### Step 5: Initial Bode Plot
Analyze the gain/phase plot. Identify the 0dB crossover frequency (f0dB).

#### Step 6: Adjust Stimulus Amplitude
Use the frequency-dependent amplitude parameters (`pp0`, `pp1`, `f0`, `f1` — the recommended method) to inject a larger stimulus at low frequencies and a smaller one at high frequencies. Where loop gain is high, the loop suppresses the injected perturbation, so a larger stimulus is needed to get a measurable response; near and above crossover the loop no longer attenuates it, so the same amplitude would disturb the operating point and distort the result.

```spice
* 2mV up to 1kHz, tapering to 1mV above 2kHz
@1 A B fstart=1k fend=500k pp0=2m pp1=1m f0=1k f1=2k
```

#### Step 7: Add More Frequencies
Use 2-3 points per octave (`oct=2` or `oct=3`) for a smooth Bode plot.

#### Step 8: Speed Up (Optional)
Reduce `tsettle` and `tavgmin` where the circuit responds quickly, and use `fcoarse` (set to 2-10× `fstart`) to coarsen the sweep at low frequencies, where each point is most expensive.

Only at this point — with the setup already validated by the steps above — consider raising `nmax` above its default of 1 to inject harmonics alongside the fundamental. It trades accuracy for speed, because the circuit's own harmonic distortion then falls on the measured frequencies and cannot be separated from the real response. See [`nmax`](CIRCUIT-ELEMENTS-REFERENCE.md#--frequency-response-analyzer) before using it.

### Reference

R.D. Middlebrook, "Measurement of Loop Gain in Feedback Systems," International Journal of Electronics, 1975.

---

## Additional Resources

### Official

| Resource | URL |
|----------|-----|
| LTspice downloads & training | https://www.analog.com/ltspice |
| EngineerZone support forum | https://ez.analog.com/design-tools-and-calculators/ltspice/ |
| LTpowerCAD efficiency tool | https://www.analog.com/en/design-center/ltpowercad.html |

### Community

| Resource | URL |
|----------|-----|
| Independent users' group | https://groups.io/g/LTspice |
| Simon Bramble tutorials | http://www.simonbramble.co.uk |

The groups.io Files section contains tutorials, additional component libraries, and user-contributed example circuits.

---

*See also: [TROUBLESHOOTING-GUIDE.md](TROUBLESHOOTING-GUIDE.md) for convergence solutions, [SIMULATION-COMMANDS-REFERENCE.md](SIMULATION-COMMANDS-REFERENCE.md) for .FRA command details*
---

*Documentation source: [github.com/analogdevicesinc/ltspice-reference](https://github.com/analogdevicesinc/ltspice-reference)*
