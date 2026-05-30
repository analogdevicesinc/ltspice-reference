# LTspice Waveform Viewer Guide

Complete reference for viewing, analyzing, and exporting simulation results.

---

## Table of Contents

1. [Trace Selection](#trace-selection)
2. [Zooming and Navigation](#zooming-and-navigation)
3. [Waveform Arithmetic](#waveform-arithmetic)
4. [User-Defined Functions](#user-defined-functions)
5. [Axis Control](#axis-control)
6. [Plot Panes](#plot-panes)
7. [Cursors](#cursors)
8. [Color Control](#color-control)
9. [Plot Configurations](#plot-configurations)
10. [Fast Access File Format](#fast-access-file-format)
11. [Exporting Data](#exporting-data)

---

## Trace Selection

### Probing from Schematic

| Action | Result |
|--------|--------|
| Click wire | Plot node voltage |
| Click component body (2-terminal) | Plot current through component |
| Click component pin | Plot current into that pin |
| Double-click same trace | Isolate it (erase other traces) |
| Alt+Click component body | Plot instantaneous power (Watts) |
| Alt+Click wire | Plot wire current |
| Click node, drag to another | Differential voltage V(a,b) |

Mouse cursor icons indicate measurement type (voltage probe, current clamp, thermometer for power).

### From Menu

- **Plot Settings > Visible Traces** — Select initial traces; pattern matching filter available
- **View > Add Trace** — Add traces without removing existing ones; click trace names to build expressions

### Managing Traces

- Click trace label with Delete command active to remove individual traces
- Undo/Redo work across all trace selection methods

---

## Zooming and Navigation

| Action | Result |
|--------|--------|
| Drag box | Zoom to enclosed region |
| Esc before release | Cancel zoom |
| Toolbar zoom out | Step back to previous zoom |
| Auto-range | Reset to automatic scaling |
| Undo/Redo | Navigate zoom history |
| Ctrl+Mouse wheel | Preview zoom (bitmap, fast for large files) |

- Zoom box dimensions shown on status bar (quick measurement without cursors)
- Time differences automatically converted to frequency display

---

## Waveform Arithmetic

Right-click on a trace label or use **View > Add Trace** to enter expressions.

### Available Functions

| Category | Functions |
|----------|-----------|
| Trig | sin, cos, tan, asin, acos, atan, atan2, sinh, cosh, tanh, asinh, acosh, atanh |
| Log/Exp | ln, log, log10, exp |
| Power | sqrt, pow, pwr (abs(x)^y), pwrs (sgn(x)*abs(x)^y) |
| Abs/Round | abs, ceil, floor, round, int |
| Logic | buf, inv, u (unit step), uramp |
| Conditional | if(x,y,z), limit, max, min |
| Calculus | d() (derivative via finite difference) |
| Lookup | table(x, a,b, c,d, ...) |
| Distance | hypot(x,y) |
| Noise | rand, random, white |
| Complex | Re, Im, Ph, Mag, conj |

### Operators (ascending precedence)

| Operator | Description |
|----------|-------------|
| `&`, `\|`, `^` | Boolean AND, OR, XOR |
| `>`, `<`, `>=`, `<=` | Comparison |
| `+`, `-`, `*`, `/`, `**` | Arithmetic |
| `!` | Boolean NOT |
| `@` | Step run selector (e.g., `V(out)@3`) |

### Built-in Constants

| Name | Value |
|------|-------|
| E | 2.71828... |
| pi | 3.14159... |
| K | 1.3806503e-23 (Boltzmann) |
| Q | 1.602176462e-19 (electron charge) |

### Keywords

- `time` — horizontal axis for transient analysis
- `omega` or `w` — angular frequency for AC analysis

### Dimensional Analysis

The viewer performs dimensional analysis on expressions and labels results with calculated units (V, A, W, Ohm, etc.). Traces with the same units share a vertical axis.

Example: `-2*pi*pow(V(out),2)/abs(V(n001))/Ie(x1:Q1)` → identified as Ohm

### Average and RMS

Zoom to a region of interest, then **Ctrl+Left-click** on the trace label to compute average and RMS over the visible window. RMS only reported for V or A units.

### FFT (Fourier Transform)

**View > FFT** to compute frequency spectrum.

- Proprietary algorithm: works with arbitrary number of datapoints (not limited to power of 2)
- Noise floor exceeds 300dB
- Enter desired number of bins directly

**For best FFT results:**
```spice
.options plotwinsize=0   ; disable compression
.tran 0 10m 0 1u        ; specify max timestep
.options numdgt=15       ; double precision
```

---

## User-Defined Functions

Custom functions and parameters for the waveform viewer.

**Menu**: Plot Settings > Edit Plot Defs File

**File location**: `%LOCALAPPDATA%\LTspice\plot.defs`

**Syntax** (same as SPICE `.param` and `.func`):
```
.func Pythag(x,y) {sqrt(x*x+y*y)}
.func dBV(x) {20*log10(abs(x))}
.param twopi = 2*pi
```

---

## Axis Control

- Move cursor beyond the data area until it changes to a ruler icon
- **Left-click** on the ruler to open axis configuration dialog

### Horizontal Axis (Real Data)

- Manually set range and scale type
- Enables parametric plots (plot one trace vs another)

### Vertical Axis (Complex/AC Data)

- Left-click left vertical axis to switch between:
  - Bode plot
  - Nyquist plot
  - Cartesian plot
- Right vertical axis options: phase, group delay, or none

---

## Plot Panes

Multiple plot panes can be displayed in one window for better trace organization.

| Action | Result |
|--------|--------|
| Right-click plot area | Add pane above/below, move panes |
| Drag trace label to another pane | Move trace |
| Ctrl+release in another pane | Copy trace to that pane |

Each pane has independent autoscaling.

---

## Cursors

### Attaching Cursors

| Action | Result |
|--------|--------|
| Left-click trace label | Attach single cursor |
| Right-click label > "1st & 2nd" | Attach both cursors to one trace |
| Right-click label > Attached Cursor | Choose 1st, 2nd, or both |

### Moving Cursors

- Drag with mouse
- Arrow keys for fine positioning
- Up/Down keys navigate between .step/.dc/.temp runs

### Readout

- Cursor position shown in readout window
- Difference between cursors reported
- Right-click cursor to see step information for that run

### Status Bar Readout (No Cursor Needed)

- Mouse position always displayed on status bar
- Drag-zoom box size shown (quick measurement)
- Time differences converted to frequency

---

## Color Control

**Menu**: Tools > Color Preferences

- Click objects in sample plot to select them
- Adjust colors with RGB sliders

---

## Plot Configurations

### File Format

- Extension: `.plt` (text files)
- Default name: same as `.raw` file with `.plt` extension
- Automatically loaded when data file opens (if file exists)

### Per-Analysis Settings

Each analysis type (.tran, .ac, .noise, etc.) has its own section. Cannot load settings from one analysis type to another, but can load `.plt` from a different simulation of the same analysis type.

### Menu Commands

- **Plot Settings > Save Plot Settings**
- **Plot Settings > Open Plot Settings**

---

## Fast Access File Format

Optimizes random-access performance for large waveform files.

### When to Use

- After simulation completes
- For files with many traces where you only view a few at a time
- Example: 5GB file with 2000 traces — load time drops from 4 minutes to ~1 second

### How to Convert

- **GUI**: Make waveform window active > Files > Convert to Fast Access
- **Command line**: `ltspice.exe -FastAccess <file>`

### Characteristics

- File size increase: only 11 bytes larger
- Speed improvement: factor roughly equal to number of saved traces
- Requires disk space equal to file size during conversion
- Can use up to 1/4 of physical RAM
- Conversion time may exceed original simulation time

### Limitations

- Real data only (not complex data from .AC analysis)
- Cannot append new data after conversion
- Standard format required during simulation

---

## Exporting Data

### Image Export

| Method | Format | How |
|--------|--------|-----|
| Clipboard bitmap | BMP | Right-click > Copy Image to Clipboard |
| Metafile (vector) | EMF | Tools > Write image to .emf file |

For metafile: use Arial font (Tools > Settings > Waveform > Font) — system fonts don't scale.

### Numerical Data Export

**Built-in**: Waveform menu > **File > Export** (ASCII file)

### Getting Equally-Spaced Timesteps

LTspice uses variable timesteps. To get uniform spacing:
1. Perform FFT on desired trace
2. Perform FFT on the FFT result (recovers equally-spaced time data)
3. Export that result

This is bit-accurate to double precision.

### Third-Party Tools

Helmut Sennewald's free utility (http://groups.io/g/LTspice) supports data manipulation including merging waveforms from different simulation runs.

---

*See also: [SIMULATION-COMMANDS-REFERENCE.md](SIMULATION-COMMANDS-REFERENCE.md) for .MEASURE automated measurements, [TROUBLESHOOTING-GUIDE.md](TROUBLESHOOTING-GUIDE.md) for compression settings*
