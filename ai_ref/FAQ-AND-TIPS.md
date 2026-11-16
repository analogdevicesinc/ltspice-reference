---
title: LTspice FAQ and Tips
description: Updates, license, Linux, simulation speed, efficiency calculations, and SMPS Bode plots — frequently asked questions and practical tips.
version: "26+"
---

[← AI Reference](README.md)

# LTspice FAQ and Tips

Frequently asked questions, simulation speed, efficiency calculations, SMPS Bode plots, platform notes, and resources.

---

## Table of Contents

1. [Program Updates](#program-updates)
2. [License and Distribution](#license-and-distribution)
3. [Running Under Linux](#running-under-linux)
4. [Settings Overview](#settings-overview)
5. [Speeding Up Simulations](#speeding-up-simulations)
6. [Efficiency Calculation](#efficiency-calculation)
7. [SMPS Bode Plots (FRA)](#smps-bode-plots-fra)
8. [Additional Resources](#additional-resources)

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

## Speeding Up Simulations

Pointers to the measures documented elsewhere in this reference, grouped by what each one costs
you. Nothing here is a new setting — follow the links for syntax and caveats.

### Reduce the work the simulator does

These change how much gets simulated, not how accurately.

- **Skip the startup transient with `loadstate`.** Save the settled state once, then start every
  later run from it. For iterative work — tuning a compensation network, sweeping a component
  value, repeating an FRA sweep — this is usually the largest single saving available: the startup
  transient is often most of the run, and it is otherwise re-simulated from scratch every time.
  Component and parameter values may differ from those the state was saved with, and the run will
  usually still converge — see
  [Changing the Circuit Between Save and Load](SIMULATION-COMMANDS-REFERENCE.md#changing-the-circuit-between-save-and-load).
  See also [State Management](SIMULATION-COMMANDS-REFERENCE.md#state-management), and
  [Step 3](#step-3-run-the-automatic-fra) for starting repeated `.fra` runs this way.
- **For an FRA, give a higher `fstart`**: the lowest frequencies take the longest to analyze. Use
  `nobode` if only the crossover frequency and phase margin are needed. See
  [Step 3](#step-3-run-the-automatic-fra).
- **Stop the run when the circuit settles**, using the `steady` modifier rather than guessing a
  `Tstop` and overshooting it. See
  [Steady-State Detection](TROUBLESHOOTING-GUIDE.md#steady-state-detection).
- **Prefer LTspice's native devices and SMPS macromodels** over generic SPICE/PSpice equivalents —
  the native models exist largely for simulation speed. See
  [Speed Considerations](DEVICE-MODELS-GUIDE.md#speed-considerations).

### Trade accuracy for speed — validate the setup first

These change the simulation results. Establish a result you trust, then apply them and confirm the
answer did not move.

The cost need not apply to the whole run. `.options` take effect for an entire run, but a run can
be split into segments with `savestate`/`loadstate`, each with its own tolerances: loose through
the non-critical or troublesome portions — a startup transient, a settling interval, a
hard-to-converge transition — and tight through the portions you measure. See
[State Save/Load for Partial Relaxation](TROUBLESHOOTING-GUIDE.md#state-saveload-for-partial-relaxation).

- **Raised `trtol`** lets the simulator take larger time steps by tolerating more truncation error
  per step. Fast edges, ripple, and ringing are the first details to lose resolution, so compare
  them against a run at the default value. See
  [.OPTIONS](SIMULATION-COMMANDS-REFERENCE.md#options--simulator-options).
- **Relaxed `reltol`** loosens the error criterion every node and branch must meet at each time
  point, so the run both goes faster and gets through hard-to-converge stretches more easily. The
  accuracy loss is just as broad, which makes it a candidate for confining to the segments
  described above rather than setting for the whole run. See
  [Improve Transient Convergence](TROUBLESHOOTING-GUIDE.md#improve-transient-convergence) for
  typical values.

### Not run-time savings

`.save` and `Tstart` shrink the stored data, but the circuit is still simulated in full. Turning
off marching waveforms makes a negligible difference to both run time and memory. See
[Memory and Performance](TROUBLESHOOTING-GUIDE.md#memory-and-performance).

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

Frequency Response Analysis for measuring the loop gain, crossover frequency and phase margin of switched-mode power supplies, and their output impedance. There are two procedures below: [Loop Gain](#loop-gain-procedure), and [Output Impedance (zm)](#output-impedance-zm-procedure).

**The first thing to try is an FRA device with no parameters** — `@1 OUT FB`, and `.fra` in place of `.tran`. LTspice configures the analysis itself: it detects steady state, measures the switching frequency, finds the crossover, and chooses the frequencies, stimulus amplitudes and timing. Sometimes `delay` has to be given, when steady-state detection fails (Step 5). Other parameters are rarely needed: use the steps that set them (Steps 6 and 7) only if the automatic FRA fails for a reason other than steady-state detection. The exception is output impedance (`zm`), which requires a stimulus amplitude; see the [Output Impedance (zm) Procedure](#output-impedance-zm-procedure).

### Concept

Uses Middlebrook's method (voltage injection) to measure the loop transfer function of a feedback system in the time domain. A sinusoidal stimulus is injected at the feedback loop break point, and Fourier analysis extracts gain and phase at each frequency. The FRA device (`@`) and its parameters are described in [CIRCUIT-ELEMENTS-REFERENCE.md](CIRCUIT-ELEMENTS-REFERENCE.md#--frequency-response-analyzer).

### Example Circuits

**File > Open Examples > Educational\FRA\**

These examples use the automatic configuration: their FRA devices give no parameters beyond what the measurement needs, which is `zm` and a stimulus amplitude for output impedance, and a `delay` where steady-state detection needs help.

### Loop Gain Procedure

These steps measure loop gain, the default when the FRA device has no `zm` keyword. For output impedance, see the [Output Impedance (zm) Procedure](#output-impedance-zm-procedure).

#### Step 1: Verify Basic Operation
Before inserting the FRA device, run a standard `.tran` simulation to confirm that the SMPS starts up and reaches steady state. Any problem found here can then be fixed before the FRA device is involved. Note the settling time, the output voltage and the switching frequency. The settling time is what `delay` is set from if steady-state detection fails (Step 5).

Don't save a state from this run for the FRA: inserting the FRA device in Step 2 is a wiring change, and a state saved before it cannot be loaded into the circuit with it. Save the state on the first `.fra` run instead (Step 3).

#### Step 2: Insert FRA Component
Break the feedback loop and insert the FRA device (prefix `@`) at the injection point. Valid placement must satisfy two criteria:

1. **The device must completely interrupt the feedback.** Every feedback path has to pass through it. If any path bypasses the device — a feedforward capacitor around the divider, a second sense connection, an auxiliary loop — part of the loop stays closed and what you measure is not the loop gain.
2. **The device must point from lower impedance to higher impedance.** Connect the **OUT** terminal to the low-impedance side of the break and the **IN** terminal to the high-impedance side — typically OUT toward the converter output and IN toward the feedback divider or error-amplifier input. If the source impedance at the break is not small compared with the load impedance, the injection loads the loop and the measured response is corrupted.

Where the loop gain has to be measured somewhere other than across the FRA device — a micromodule with integrated feedback resistors, an inverting converter, a current loop — add an [FRA probe](CIRCUIT-ELEMENTS-REFERENCE.md#--frequency-response-analysis-probe) (`&`, symbol `fraprobe`) there and mark it `loopgain`. This is part of the placement, not a sign that the automatic FRA needs help.

#### Step 3: Run the Automatic FRA
Give the device no parameters, and replace the `.tran` directive with `.fra`:

- **Drop the `.tran` timing values**: stop time, time step, start time and maximum time step. `.fra` takes keywords, not positions, and its `Tstop=` is not the length of the run: it is the maximum time to wait for steady state, 5 ms if left out. Give it only if the circuit needs longer than that to settle.
- **Keep `startup`** if the `.tran` had it, and likewise `uic`.
- **Add `savestate`**, which saves the settled circuit, just before the first stimulus, to `<circuit>.state`.

```spice
* was: .tran 0 2m 0 10n startup
@1 OUT FB
.fra startup savestate
```

LTspice detects steady state, measures the switching frequency, finds the crossover, and produces a Bode plot. Read the results from the log (`get_spice_log` through MCP):

```
FRA @1: f0dB = 94452.6 Hz, phase margin = 63.628 deg, slope -20.61 dB/decade
FRA Instance @1: F(0dB) = 94.249 kHz, Phase Margin = 63.8 degrees, Gain Margin = 13.2 dB at 261.651 kHz
```

The `FRA Instance` line holds the figures on the Bode plot. The Bode data is in `<circuit>.fra_<instance>.raw` (`fra_1` for `@1`), signal `gain_1`. The main `.raw` holds the time-domain simulation, not the sweep: the start-up, then exactly one stimulus, at a frequency near f0dB, which the log names, as in `FRA - the .raw file shows @1's tone of 93806.6 Hz from 0.00010653 to 0.000270171 seconds, one of the frequencies it measured.`

If only the crossover frequency and phase margin are needed, add `nobode` (`@1 OUT FB nobode`). It takes less time; the result is the `FRA @1: f0dB = …` line, there is no Bode plot, and the main `.raw` ends at steady state, with no stimulus.

**To reduce the simulation time, give `fstart` (Minimum Frequency in the FRA device's dialog), or raise it if it is already given.** The lowest frequencies take the longest to analyze. Without `fstart`, a loop gain Bode plot starts at fsw/1000 or 1 kHz, whichever is higher, but no higher than f0dB/10, so that it always reaches a decade below the crossover: min(f0dB/10, max(fsw/1000, 1 kHz)). An impedance (`zm`) sweep, and a fully specified sweep (Step 7), start at fsw/1000. For loop gain, keep `fstart` well below f0dB, for example at f0dB/10 from an earlier run: `@1 OUT FB fstart=10k` for f0dB near 100 kHz. Everything else is still set automatically.

**For later runs, change `savestate` to `loadstate`** (`.fra startup loadstate`). Each run then starts from the settled circuit instead of repeating the start-up; with no `delay`, LTspice detects steady state again from there, which takes far less time. Component values may be changed between runs. Save the state again after any wiring change, or after a change large enough to move the operating point. A `delay` is absolute simulation time from t=0, also after `loadstate`: a state saved at 1.2 ms already satisfies `delay=1m`, so the analysis starts as soon as it loads. See [State Management](SIMULATION-COMMANDS-REFERENCE.md#state-management).

#### Step 4: Check the Log
Read every `Warning:` and `Error:` line before trusting a result, and any line saying that the loop gain or impedance `could not be measured`, which has neither prefix. The common ones:

| Log message | Cause | Fix |
|-------------|-------|-----|
| `Error: FRA @1 did not reach steady state …, so the analysis was not started.` | With no `delay`, the circuit had not settled by the time limit (the `.fra` `Tstop`, else 5 ms) | Set `delay` (Step 5), or give `.fra` a longer `Tstop` |
| `Warning: FRA @1: the analysis started at its delay of … seconds, but the circuit had not reached steady state by then …` | The `delay` is too early. Reported only with an ADI model that supports steady-state detection | Set a later `delay`, or leave it out |
| `… waveform changes at … seconds, during the analysis …` | A one-off source change, such as a load step, falls inside the analysis | Move the change outside the analysis, or set `delay` after it |
| `… independent sources run at different frequencies …` | Independent sources repeat at different frequencies, with no `delay` and no ADI model that supports steady-state detection | Drive the circuit from one clock, or set `delay` |
| `… the circuit switches at more than one frequency …` | Several FRA devices measure loop gain, the circuit switches at more than one frequency, and fewer of its converters than that are ADI models that support steady-state detection | Measure one loop at a time: one FRA device measuring loop gain, the others disabled (`enabled=0`) |
| `… has a grounded terminal and several fraprobes …` | The measurement point is ambiguous | Mark one probe `loopgain` |
| `Warning: no frequencies of FRA instance @1 were analysed …` | The device's `delay` is later than the `.fra` `Tstop` | Raise `Tstop` past the `delay`, or give an earlier `delay` |
| `FRA @1: the loop gain could not be measured: no 0 dB crossover was found. …` | The FRA device is not in the loop, or the loop is not closed | Check the placement (Step 2) |

A Bode plot that opens blank, or margins taken at the wrong point, means the measurement point is not the one intended: see [Results and Bode Plot](CIRCUIT-ELEMENTS-REFERENCE.md#results-and-bode-plot), and mark the intended probe `loopgain`.

#### Step 5: Check Steady State in the Waveform
A clean log does not prove that the analysis started at steady state. Check it in the transient waveform:

1. Find in the log the time the analysis started: the `from` time in `FRA - the .raw file shows @1's tone of … Hz from … to … seconds, …`. With `nobode` there is no such line; use the time in `FRA - steady state reached at … seconds.` (circuits using an ADI model that supports steady-state detection) or in `FRA - switching frequency at … seconds: …` (other switching circuits). A circuit that does not switch logs `FRA @1: … frequencies analyzed, … starting at t = … seconds.`
2. Read the output voltage, the inductor current and the compensation voltage, where the model makes it available, from the main `.raw` (`get_raw_info`, then `read_raw_waveforms` or `export_raw_waveforms`). The main `.raw` holds the start-up, then the one stimulus (Step 3).
3. Up to that time, each should have finished its start-up: steady apart from the switching ripple, with no soft-start ramp or slow drift still in progress.

**If detection fired too early** (the output is still moving at that time) **or not at all** (an `Error:` that steady state was not reached), set `delay` on the FRA device (Start Analysis at Time in its dialog) to a time after the circuit has settled, taken from Step 1 or from this waveform, or increase it if it is already set:

```spice
@1 OUT FB delay=1m
```

Leave every other parameter out. LTspice checks a `delay` in only two kinds of circuit: one using an ADI model that supports steady-state detection gets a warning if it had not settled by then, and one that does not switch gets an error. Other switching circuits are not checked, so confirm in the waveform that the output had settled by `delay`. If steady-state detection was the only problem, the analysis is now complete.

#### Step 6: If the Automatic FRA Still Fails — Constrain Only What Is Needed
Use this step only if the result is still wrong for a reason other than steady-state detection — for example, a crossover outside the frequencies analyzed, or a response distorted by the stimulus amplitude. Add only the parameter that addresses the problem:

| Problem | Add to the `@` line |
|---------|---------------------|
| The crossover, or a feature of interest, lies outside the frequencies analyzed | `fstart`, `fend` |
| A specific frequency must be included | `flist` |
| The stimulus amplitude LTspice chose distorts the response | `pp0` (or `pp0`, `pp1`, `f0`, `f1`) — applied exactly, at every frequency |

Leave `oct` and `dec` out: giving either replaces LTspice's choice of frequencies, including the points it adds where the response changes quickly. They belong to a fully specified sweep (Step 7).

#### Step 7 (Rarely Needed): Fully Specified Sweep
Giving a resolution (`oct` or `dec`), an amplitude and `tsettle` makes LTspice apply the sweep exactly as specified. Use it only when Step 6 is not enough, or to cross-check an automatic result. A procedure, using f0dB from Step 3:

1. **Three frequencies around the crossover** — `fstart` = f0dB/8, `fend` = 2 × f0dB, `oct=0.5`. Start with `pp0` at 1-2% of the voltage at the FRA device, and `tsettle` and `tavgmin` at 100-200 switching periods. For a 5 V, 2 MHz converter with f0dB near 100 kHz:
   ```spice
   @1 OUT FB fstart=12.5k fend=200k oct=0.5 pp0=50m tsettle=100u tavgmin=100u
   ```
2. **Check the stimulus** — analyze one frequency near f0dB (`fstart` = `fend`) and inspect the main `.raw`: the voltage at both FRA terminals, the inductor current, the control voltage. The response should be sinusoidal and symmetric. Distortion means the amplitude is too large. If the stimulus must be small to stay linear, increase `tavgmin` (up to ~1000/fsw) so it can still be resolved.
3. **Make the amplitude frequency-dependent** — `pp0` = VCM/25-50, `pp1` = `pp0`/4, `f0` = f0dB/4, `f1` = f0dB, where VCM is the voltage at the FRA device. Where loop gain is high, the loop suppresses the injected perturbation, so a larger stimulus is needed to get a measurable response; near and above crossover the loop no longer attenuates it, so the same amplitude would disturb the operating point and distort the result.
   ```spice
   * 2mV up to 1kHz, tapering to 1mV above 2kHz
   @1 A B fstart=1k fend=500k oct=2 pp0=2m pp1=1m f0=1k f1=2k tsettle=200u
   ```
4. **Full sweep** — `fstart` = f0dB/10-20, `fend` = 10 × f0dB, `oct=2` or `oct=3`, `fcoarse` = 2 × `fstart`.
5. **Speed up (optional)** — raise `fcoarse` (2-10 × `fstart`), reduce `tavgmin` to 50-100/fsw if the switching ripple is small relative to the stimulus, and reduce `tsettle` to 2/f0dB. Change one at a time and compare against the previous result. Phase is more sensitive to errors than gain.

### Output Impedance (zm) Procedure

These steps measure a converter's closed-loop output impedance, with the `zm` keyword. They differ from the loop gain procedure: the loop is not broken, and a stimulus amplitude is required.

1. **Verify basic operation**, as in [Step 1](#step-1-verify-basic-operation), before inserting the FRA device.
2. **Leave the feedback loop closed.** Remove any loop gain FRA device, or disable it with `enabled=0`.
3. **Connect an FRA device with `zm` from the converter output to ground**: `out` (the flat side of the symbol) to the output, `in` (the pointy side) to ground.
4. **Load the output with 50% of the expected maximum load current**, using a DC current source. A load resistor would be part of what is measured: the result would be the output impedance in parallel with the resistor.
5. **Set the stimulus amplitude, `pp`, to 10% of the expected maximum load current.** It is required, in amps peak-to-peak. Leave every other parameter out.

   ```spice
   * converter rated for 2 A
   I1 OUT 0 1 load         ; 50% of the 2 A maximum
   @z1 OUT 0 zm pp=200m    ; 10% of the 2 A maximum
   .fra
   ```

6. **Run, and read the result.** Convert the `.tran` and add `savestate` as in [Step 3](#step-3-run-the-automatic-fra), and use `loadstate` for later runs. The log reports the frequencies measured, for example `FRA @z1: impedance measured at 24 frequencies, 2019.95 Hz to 2.01389e+07 Hz`. By default they run from fsw/1000 to 10 × fsw. A higher `fstart` (Minimum Frequency) reduces the simulation time, since the lowest frequencies take the longest to analyze. The data is `impedance_z1` in `<circuit>.fra_z1.raw`. There is no crossover frequency or margin. The main `.raw` holds the start-up, then one stimulus, near the middle of the frequency range.
7. **Check the log and steady state**, as in [Step 4](#step-4-check-the-log) and [Step 5](#step-5-check-steady-state-in-the-waveform). If steady-state detection fired too early or too late, set `delay`.
8. **Only if the result is still wrong for another reason**, change the range with `fstart` and `fend`, or add frequencies with `flist`. Leave `oct` and `dec` out.

`nobode` and FRA probes (`&`) cannot be used with `zm` (both are errors), and `refnode` does not apply. Parameters: [Impedance Analysis (zm)](CIRCUIT-ELEMENTS-REFERENCE.md#impedance-analysis-zm). Example: `fra_eg7_LT8618_zout.asc` in **Educational\FRA\**.

### Circuits That Do Not Switch

The same device line works for an op-amp loop or a linear regulator. LTspice measures a circuit that does not switch by small-signal AC analysis at its steady-state operating point, which takes a fraction of the time, from 1 Hz to 1 GHz by default. See [Circuits That Do Not Switch](CIRCUIT-ELEMENTS-REFERENCE.md#circuits-that-do-not-switch).

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
