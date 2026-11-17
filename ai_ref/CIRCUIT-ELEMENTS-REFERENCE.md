---
title: LTspice Circuit Elements Reference
description: Component syntax (R, L, C, V, I, D, Q, M, sources, switches) — parameters and models for every circuit element type.
version: "24+"
---

[← AI Reference](README.md)

# LTspice Circuit Elements Reference

Complete reference for all circuit element types in LTspice, including syntax, parameters, and models.

---

## Table of Contents

1. [Element Overview](#element-overview)
2. [R — Resistor](#r--resistor)
3. [C — Capacitor](#c--capacitor)
4. [L — Inductor](#l--inductor)
5. [D — Diode](#d--diode)
6. [Q — Bipolar Transistor](#q--bipolar-transistor)
7. [M — MOSFET](#m--mosfet)
8. [J — JFET](#j--jfet)
9. [Z — MESFET and IGBT](#z--mesfet-and-igbt)
10. [V — Voltage Source](#v--voltage-source)
11. [I — Current Source](#i--current-source)
12. [E — Voltage-Dependent Voltage Source](#e--voltage-dependent-voltage-source)
13. [G — Voltage-Dependent Current Source](#g--voltage-dependent-current-source)
14. [H — Current-Dependent Voltage Source](#h--current-dependent-voltage-source)
15. [F — Current-Dependent Current Source](#f--current-dependent-current-source)
16. [S — Voltage-Controlled Switch](#s--voltage-controlled-switch)
17. [W — Current-Controlled Switch](#w--current-controlled-switch)
18. [K — Mutual Inductance](#k--mutual-inductance)
19. [T — Lossless Transmission Line](#t--lossless-transmission-line)
20. [O — Lossy Transmission Line](#o--lossy-transmission-line)
21. [U — Uniform RC-Line](#u--uniform-rc-line)
22. [B — Behavioral Source](#b--behavioral-source)
23. [A — Special Functions](#a--special-functions)
24. [X — Subcircuit](#x--subcircuit)
25. [@ — Frequency Response Analyzer](#--frequency-response-analyzer)
26. [& — Frequency Response Analysis Probe](#--frequency-response-analysis-probe)

---

## Element Overview

The first character of a netlist line determines the element type. Some elements use **flags** as parameters — a flag is active if present, or you can assign a value (>=0.5 = on, <0.5 = off).

**Dynamic Nodes**: Node names can be expressions using parameters, e.g., `I1 {CONNECT} 0 2m`.

---

## R — Resistor

**Symbols**: RES, RES2

```spice
Rxxx n1 n2 <value> [tc=tc1, tc2, ...] [temp=<value>]
```

**Temperature dependence**:
```
R = R0 * (1 + dt*tc1 + dt^2*tc2 + dt^3*tc3 + ...)
```
Where R0 is resistance at nominal temperature, dt is temperature difference from nominal.

**Parameters**:
- `tc`: Temperature coefficients (comma-separated list)
- `temp`: Instance temperature

**Example**:
```spice
R1 in out 10K tc=0.01, 0.001
```

---

## C — Capacitor

**Symbols**: CAP, POLCAP

```spice
Cxxx n1 n2 <capacitance> [ic=<value>]
+ [Rser=<value>] [Lser=<value>] [Rpar=<value>]
+ [Cpar=<value>] [m=<value>] [RLshunt=<value>] [temp=<value>]
```

| Parameter | Description |
|-----------|-------------|
| Rser | Equivalent series resistance (ESR) |
| Lser | Equivalent series inductance (ESL) |
| Rpar | Equivalent parallel resistance |
| Cpar | Equivalent parallel capacitance |
| RLshunt | Shunt resistance across Lser |
| m | Number of parallel units (m=0 removes from simulation) |
| ic | Initial voltage |
| temp | Instance temperature |

### Nonlinear Capacitor

```spice
Cxxx n1 n2 Q=<expression> [ic=<value>] [m=<value>]
```

Where `x` = voltage across device. Examples:
```spice
C1 n1 n2 Q=100p*x          ; constant 100pF
C2 n1 n2 Q=x*if(x<0,100p,300p)  ; voltage-dependent
```

---

## L — Inductor

**Symbols**: IND, IND2

```spice
Lxxx n+ n- <inductance> [ic=<value>]
+ [Rser=<value>] [Rpar=<value>] [Cpar=<value>]
+ [m=<value>] [temp=<value>]
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| Rser | Equivalent series resistance | 1m (for SMPS; set Rser=0 to disable) |
| Rpar | Equivalent parallel resistance | — |
| Cpar | Equivalent parallel capacitance | — |
| m | Number of parallel units | 1 |
| ic | Initial current | — |
| tc1, tc2 | Temperature coefficients | 0 |

### Behavioral Inductance (Flux-Based)

```spice
L1 N001 0 Flux=1m*tanh(5*x)
```
Where `x` = inductor current.

### Hysteretic Core Model

```spice
L1 N001 0 Hc=16 Bs=.44 Br=.10 A=0.0000251 Lm=0.0198 Lg=0.0006858 N=1000
```

| Parameter | Description | Units |
|-----------|-------------|-------|
| Hc | Coercive force | A-turns/meter |
| Br | Remnant flux density | Tesla |
| Bs | Saturation flux density | Tesla |
| Lm | Magnetic length (excluding gap) | meter |
| Lg | Gap length | meter |
| A | Cross-sectional area | meter^2 |
| N | Number of turns | — |

---

## D — Diode

**Symbols**: DIODE, ZENER, SCHOTTKY, VARACTOR, LED, TVS

```spice
Dxxx anode cathode <model> [area] [off] [m=<val>] [n=<val>] [temp=<value>]
```

| Parameter | Description |
|-----------|-------------|
| area | Multiple parallel devices |
| m | Number of parallel devices |
| n | Number of series devices |
| off | Initial condition hint |
| temp | Instance temperature |

### Idealized Diode Model (Region-Wise Linear)

| Parameter | Description | Default |
|-----------|-------------|---------|
| Ron | Forward conduction resistance (mOhm) | 1.0 |
| Roff | Off-state resistance | 1/Gmin |
| Vfwd | Forward threshold voltage | 0.0 V |
| Vrev | Reverse breakdown voltage | Infinite |
| Rrev | Breakdown impedance | Ron |
| Ilimit | Forward current limit | Infinite |
| Revilimit | Reverse current limit | Infinite |
| Epsilon | Quadratic region width | 0.0 V |
| Revepsilon | Reverse quadratic region width | 0.0 V |

### Berkeley SPICE Diode Model (Key Parameters)

| Parameter | Description | Units | Default |
|-----------|-------------|-------|---------|
| Is | Saturation current | A | 1e-14 |
| Rs | Ohmic resistance | Ohm | 0 |
| N | Emission coefficient | — | 1.0 |
| Tt | Transit time | sec | 0 |
| Cjo | Zero-bias junction capacitance | F | 0 |
| Vj | Junction potential | V | 1.0 |
| M | Grading coefficient | — | 0.5 |
| BV | Reverse breakdown voltage | V | Infinite |
| Ibv | Current at breakdown | A | 1e-10 |
| Eg | Activation energy (Si=1.11, Sbd=0.69) | eV | 1.11 |
| Xti | Saturation current temp exponent | — | 3.0 |
| Kf | Flicker noise coefficient | — | 0 |
| Af | Flicker noise exponent | — | 1 |
| Tnom | Parameter measurement temperature | C | 27 |
| Vp | Soft reverse recovery parameter | — | 0 |

---

## Q — Bipolar Transistor

**Symbols**: NPN, PNP, NPN2, PNP2

```spice
Qxxx Collector Base Emitter [Substrate] <model> [area] [off] [temp=<T>]
```

### Key Gummel-Poon Parameters

| Parameter | Description | Units | Default |
|-----------|-------------|-------|---------|
| Is | Transport saturation current | A | 1e-16 |
| Bf | Ideal maximum forward beta | — | 100 |
| Nf | Forward emission coefficient | — | 1 |
| Vaf | Forward Early voltage | V | Infinite |
| Ikf | Forward beta roll-off corner | A | Infinite |
| Br | Ideal maximum reverse beta | — | 1 |
| Var | Reverse Early voltage | V | Infinite |
| Rb | Zero-bias base resistance | Ohm | 0 |
| Re | Emitter resistance | Ohm | 0 |
| Rc | Collector resistance | Ohm | 0 |
| Cje | B-E zero-bias depletion cap | F | 0 |
| Cjc | B-C zero-bias depletion cap | F | 0 |
| Tf | Forward transit time | sec | 0 |
| Tr | Reverse transit time | sec | 0 |
| BVcbo | Collector-base breakdown | V | Infinite |
| BVbe | Base-emitter breakdown | V | Infinite |
| Tnom | Measurement temperature | C | 27 |

Set **Level=9** for VBIC (Vertical Bipolar Inter Company) model.

---

## M — MOSFET

**Symbols**: NMOS, NMOS3, PMOS, PMOS3

### Monolithic MOSFET

```spice
Mxxx Nd Ng Ns Nb <model> [m=<value>] [L=<len>] [W=<width>]
+ [AD=<area>] [AS=<area>] [PD=<perim>] [PS=<perim>]
+ [NRD=<value>] [NRS=<value>] [off] [IC=<Vds,Vgs,Vbs>] [temp=<T>]
```

### VDMOS Power MOSFET

```spice
Mxxx Nd Ng Ns <model> [L=<len>] [W=<width>] [M=<area>] [m=<value>]
+ [off] [IC=<Vds,Vgs,Vbs>] [temp=<T>]
```

### MOSFET Levels

| Level | Model |
|-------|-------|
| 1 | Shichman-Hodges (default) |
| 2 | MOS2 |
| 3 | MOS3 (semi-empirical) |
| 4 | BSIM |
| 5 | BSIM2 |
| 6 | MOS6 |
| 7, 8, 49 | BSIM3v3.3 |
| 9 | BSIMSOI3.2 (SOI) |
| 12, 44, 55 | EKV 2.6 |
| 14, 54 | BSIM4.6.1 |
| 73 | HiSIMHV 1.2 |

### Key Level 1/2/3 Parameters

| Parameter | Description | Units | Default |
|-----------|-------------|-------|---------|
| Vto | Threshold voltage | V | 0 |
| Kp | Transconductance parameter | A/V^2 | 2e-5 |
| Gamma | Bulk threshold parameter | V^0.5 | 0 |
| Phi | Surface inversion potential | V | 0.6 |
| Lambda | Channel-length modulation | 1/V | 0 |
| Rd | Drain resistance | Ohm | 0 |
| Rs | Source resistance | Ohm | 0 |
| Tox | Oxide thickness | m | 1e-7 |
| Uo | Surface mobility | cm^2/V/s | 600 |
| Tnom | Measurement temperature | C | 27 |

### Key VDMOS Parameters

| Parameter | Description | Units | Default |
|-----------|-------------|-------|---------|
| Vto | Threshold voltage | V | 0 |
| Kp | Transconductance | A/V^2 | 1 |
| Lambda | Channel-length modulation | 1/V | 0 |
| mtriode | Triode region multiplier | — | 1 |
| Ksubthres | Subthreshold parameter | — | 0 |
| BV | Breakdown voltage | V | Infinite |
| Rd | Drain resistance | Ohm | 0 |
| Rs | Source resistance | Ohm | 0 |
| Rg | Gate resistance | Ohm | 0 |
| Rds | Drain-source shunt resistance | Ohm | Infinite |
| Cgs | Gate-source capacitance | F | 0 |
| Cgdmin | Min gate-drain capacitance | F | 0 |
| Cgdmax | Max gate-drain capacitance | F | 0 |
| Cjo | Body diode junction cap | F | 0 |
| Is | Body diode saturation current | A | 1e-14 |
| Bex | Kp temperature exponent | — | -1.5 |
| vtotc | Vto temperature coefficient | V/C | 0 |

---

## J — JFET

**Symbols**: NJF, PJF

```spice
Jxxx Drain Gate Source <model> [area] [off] [temp=T]
```

### Key Parameters

| Parameter | Description | Units | Default |
|-----------|-------------|-------|---------|
| Vto | Threshold voltage | V | -2.0 |
| Beta | Transconductance parameter | A/V^2 | 1e-4 |
| Lambda | Channel-length modulation | 1/V | 0 |
| Rd | Drain resistance | Ohm | 0 |
| Rs | Source resistance | Ohm | 0 |
| Cgs | Gate-source capacitance | F | 0 |
| Cgd | Gate-drain capacitance | F | 0 |
| Is | Gate junction saturation current | A | 1e-14 |
| Tnom | Measurement temperature | C | 27 |

---

## Z — MESFET and IGBT

**Symbols**: MESFET, NIGBT, PIGBT

### MESFET

```spice
Zxxx D G S <model> [area] [m=<value>] [off] [temp=<value>]
```

Model keywords: NMF, PMF

| Parameter | Description | Units | Default |
|-----------|-------------|-------|---------|
| Vto | Pinch-off voltage | V | -2.0 |
| Beta | Transconductance | A/V^2 | 1e-4 |
| Alpha | Saturation voltage parameter | 1/V | 2.0 |
| Lambda | Channel-length modulation | 1/V | 0 |
| Rd | Drain resistance | Ohm | 0 |
| Rs | Source resistance | Ohm | 0 |

### IGBT

```spice
Zxxx C G E <model> [area] [m=<value>] [off] [temp=<value>]
```

Model keyword: NIGBT (or PIGBT)

| Parameter | Description | Units | Default |
|-----------|-------------|-------|---------|
| Vt | Threshold voltage | V | 4.7 |
| KP | Transconductance | A/V^2 | 0.38 |
| WB | Base width | m | 9e-5 |
| Tau | Recombination lifetime | sec | 7.1e-6 |
| NB | Base doping | 1/cm^3 | 2e14 |
| MUN | Electron mobility | cm^2/(V*s) | 1500 |
| MUP | Hole mobility | cm^2/(V*s) | 450 |

---

## V — Voltage Source

**Symbols**: VOLTAGE, BATTERY

### Constant

```spice
Vxxx n+ n- <voltage> [AC=<amplitude>] [Rser=<value>] [Cpar=<value>]
```

### PULSE

```spice
Vxxx n+ n- PULSE(V1 V2 Tdelay Trise Tfall Ton Tperiod Ncycles)
```

| Parameter | Description | Units |
|-----------|-------------|-------|
| V1 (Voff) | Initial value | V |
| V2 (Von) | Pulsed value | V |
| Tdelay | Delay time | sec |
| Trise | Rise time | sec |
| Tfall | Fall time | sec |
| Ton | On time | sec |
| Tperiod | Period | sec |
| Ncycles | Number of cycles | — |

### SINE

```spice
Vxxx n+ n- SINE(Voffset Vamp Freq Td Theta Phi Ncycles)
```

| Parameter | Description | Units |
|-----------|-------------|-------|
| Voffset | DC offset | V |
| Vamp | Amplitude | V |
| Freq | Frequency | Hz |
| Td | Delay | sec |
| Theta | Damping factor | 1/sec |
| Phi | Phase | degrees |
| Ncycles | Number of cycles | — |

**Formula** (for t >= Td):
```
V = Voffset + Vamp * exp(-(t-Td)*Theta) * sin(2*pi*Freq*(t-Td) + pi*Phi/180)
```

### EXP

```spice
Vxxx n+ n- EXP(V1 V2 Td1 Tau1 Td2 Tau2)
```

| Parameter | Description | Units |
|-----------|-------------|-------|
| V1 | Initial value | V |
| V2 | Pulsed value | V |
| Td1 | Rise delay | sec |
| Tau1 | Rise time constant | sec |
| Td2 | Fall delay | sec |
| Tau2 | Fall time constant | sec |

### SFFM (Single Frequency FM)

```spice
Vxxx n+ n- SFFM(Voff Vamp Fcar MDI Fsig)
```

**Formula**: `Voff + Vamp*sin(2*pi*Fcar*t + MDI*sin(2*pi*Fsig*t))`

### PWL (Piece-Wise Linear)

```spice
Vxxx n+ n- PWL(t1 v1 t2 v2 t3 v3 ...)
Vxxx n+ n- PWL REPEAT FOR <n> (t1 v1 t2 v2 ...) ENDREPEAT
Vxxx n+ n- PWL REPEAT FOREVER (t1 v1 t2 v2 ...) ENDREPEAT
Vxxx n+ n- PWL FILE=<filename>
```

Options: `TIME_SCALE_FACTOR=<val>`, `VALUE_SCALE_FACTOR=<val>`

### WAV File

```spice
Vxxx n+ n- wavefile=<filename> [chan=<nnn>]
```

Full-scale range: -1V to 1V. Valid channels: 0-65535.

### Trigger Parameter

All time-dependent sources support:
```spice
Vxxx n+ n- PULSE(...) Trigger=<expr> [tripdv=<val>] [tripdt=<val>]
```

The expression is continuously evaluated; the source restarts its time sequence when the expression transitions from false to true.

---

## I — Current Source

**Symbol**: CURRENT

Same waveform types as voltage source (PULSE, SINE, EXP, SFFM, PWL, WAV), with current units instead of voltage.

### Additional Current Source Features

**Load flag**:
```spice
Ixxx n+ n- <current> [load]
```
Forces dissipative behavior — current reduces to zero if voltage drops below 0.5V. Final impedance: 0.25 Ohm/A * current.

**Lookup table**:
```spice
Ixxx n+ n- tbl=(<voltage, current>, <voltage, current>, ...)
```

**Step load**:
```spice
Ixxx n+ n- <value> step(<val1>, <val2>, <val3>, ...)
```
Advances to next current value at steady state.

**Resistive load**:
```spice
Ixxx n+ n- R=<value>
```

---

## E — Voltage-Dependent Voltage Source

**Symbols**: E, E2

### Linear Gain
```spice
Exxx n+ n- nc+ nc- <gain>
```

### Lookup Table
```spice
Exxx n+ n- nc+ nc- table=(<vin, vout>, <vin, vout>, ...)
```

### Laplace Transfer Function
```spice
Exxx n+ n- nc+ nc- Laplace=<func(s)> [window=<time>] [nfft=<number>] [mtol=<number>]
```

### Behavioral Expression
```spice
Exxx n+ n- value={<expression>}
```

### Polynomial (legacy)
```spice
Exxx n+ n- POLY(N) (n1+,n1-) (n2+,n2-) ... c0 c1 c2 ...
```

---

## G — Voltage-Dependent Current Source

**Symbols**: G, G2

Same forms as E source (linear gain, table, Laplace, behavioral, polynomial), but output is current. Gain units: A/V (transconductance).

```spice
Gxxx n+ n- nc+ nc- <transconductance>
Gxxx n+ n- nc+ nc- table=(<vin, iout>, ...)
Gxxx n+ n- nc+ nc- Laplace=<func(s)> [window=<time>] [nfft=<n>] [mtol=<n>]
Gxxx n+ n- value={<expression>}
```

---

## H — Current-Dependent Voltage Source

**Symbol**: H

```spice
Hxxx n+ n- <Vnam> <transresistance>
```

Output voltage = transresistance * current through voltage source Vnam.

Also supports behavioral and polynomial forms.

---

## F — Current-Dependent Current Source

**Symbol**: F

```spice
Fxxx n+ n- <Vnam> <gain>
```

Output current = gain * current through voltage source Vnam.

Also supports behavioral and polynomial forms.

---

## S — Voltage-Controlled Switch

**Symbol**: SW

```spice
Sxxx n1 n2 nc+ nc- <model> [on,off]
```

### Model Parameters

| Parameter | Description | Units | Default |
|-----------|-------------|-------|---------|
| Vt | Threshold voltage | V | 0 |
| Vh | Hysteresis voltage | V | 0 |
| Ron | On resistance | Ohm | 1 |
| Roff | Off resistance | Ohm | 1/Gmin |
| Lser | Series inductance | H | 0 |
| Vser | Series voltage | V | 0 |
| Ilimit | Current limit | A | Infinite |

### Hysteresis Modes

- **Vh = 0**: Hard switch at Vt
- **Vh > 0**: Hysteresis; trips at Vt+Vh and Vt-Vh
- **Vh < 0**: Smooth transition between Vt-|Vh| and Vt+|Vh| (recommended — avoids discontinuity)

---

## W — Current-Controlled Switch

**Symbol**: CSW

```spice
Wxxx n1 n2 Vnam <model> [on,off]
```

Control current sensed through voltage source Vnam.

| Parameter | Description | Units | Default |
|-----------|-------------|-------|---------|
| It | Threshold current | A | 0 |
| Ih | Hysteresis current | A | 0 |
| Ron | On resistance | Ohm | 1 |
| Roff | Off resistance | Ohm | 1/Gmin |

---

## K — Mutual Inductance

```spice
Kxxx L1 L2 [L3 ...] <coefficient>
```

Coupling coefficient range: -1 to 1. Listing multiple inductors creates all pairwise couplings:
```spice
K1 L1 L2 L3 L4 1.0   ; creates 6 mutual couplings for all pairs
```

Start with coefficient = 1.0 to eliminate leakage inductance ringing.

---

## T — Lossless Transmission Line

**Symbol**: TLINE

```spice
Txxx L+ L- R+ R- Zo=<value> Td=<value>
```

- Zo: Characteristic impedance
- Td: Propagation delay

---

## O — Lossy Transmission Line

**Symbol**: LTLINE

```spice
Oxxx L+ L- R+ R- <model>
```

### Model Parameters

| Parameter | Description | Units | Default |
|-----------|-------------|-------|---------|
| R | Resistance per unit length | Ohm | 0 |
| L | Inductance per unit length | H | 0 |
| G | Conductance per unit length | 1/Ohm | 0 |
| C | Capacitance per unit length | F | 0 |
| Len | Line length | — | 0 |

---

## U — Uniform RC-Line

**Symbol**: URC

```spice
Uxxx N1 N2 Ncom <model> L=<len> [N=<lumps>]
```

- N1, N2: Element nodes
- Ncom: Common node for capacitances
- L: Line length in meters
- N: Number of lumped segments (auto if omitted)

| Parameter | Description | Units | Default |
|-----------|-------------|-------|---------|
| K | Propagation constant | — | 2.0 |
| Fmax | Max frequency of interest | Hz | 1G |
| Rperl | Resistance per unit length | Ohm | 1K |
| Cperl | Capacitance per unit length | F | 1e-15 |
| Isperl | Saturation current per length | A | 0 |
| Rsperl | Diode series R per length | Ohm | 0 |

---

## B — Behavioral Source

**Symbols**: BV (voltage), BI (current)

### Voltage Source
```spice
Bxxx n+ n- V=<expression> [ic=<value>] [tripdv=<val>] [tripdt=<val>]
+ [laplace=<expr> [window=<time>] [nfft=<n>] [mtol=<n>]]
```

### Current Source
```spice
Bxxx n+ n- I=<expression> [ic=<value>] [tripdv=<val>] [tripdt=<val>] [Rpar=<value>]
+ [laplace=<expr> [window=<time>] [nfft=<n>] [mtol=<n>]]
```

### Resistor
```spice
Bxxx n+ n- R=<expression>
```
Acts as current = voltage/resistance.

### Power Source
```spice
Bxxx n+ n- P=<expression> [vprx=<value>]
```
Acts as current = power/voltage.

### Supported Operators (ascending precedence)

| Operator | Description |
|----------|-------------|
| `&`, `\|`, `^` | Boolean AND, OR, XOR |
| `>`, `<`, `>=`, `<=`, `==`, `!=` | Comparison |
| `+`, `-` | Addition, subtraction |
| `*`, `/`, `%` | Multiplication, division, modulo |
| `**` | Exponentiation |
| `!`, `~` | Logical NOT |

### Supported Functions

| Category | Functions |
|----------|-----------|
| Trig | sin, cos, tan, asin, acos, atan, atan2, sinh, cosh, tanh |
| Exp/Log | exp, ln, log10, sqrt, cbrt, pow, pwr, pwrs |
| Limiting | limit, max, min, dnlim, uplim |
| Logic | buf, inv, if, u (unit step), uramp |
| Calculus | ddt (derivative), idt/sdt (integrate), absdelay, delay |
| Noise | rand, random, white, noise |
| Rounding | int, round, ceil, floor, sgn |
| Other | table (lookup), hypot, mod, idtmod |

### Variables

- `V(node)` — node voltage
- `V(n1,n2)` — voltage difference
- `I(Vname)` — current through voltage source
- `time` — current simulation time
- `pi` — 3.14159265358979323846

---

## A — Special Functions

**Symbols**: INV, BUF, AND, OR, XOR, SCHMITT, SCHMTBUF, SCHMTINV, DFLOP, VARISTOR, MODULATE

```spice
Axxx in1 in2 in3 in4 in5 out+ out- com <model> [params]
```

Terminals 1-5: inputs. Terminals 6-7: complementary outputs. Terminal 8: device common. Unused terminals connected to terminal 8 are optimized out.

### Gate Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| Vhigh | 1 | Logic high level (V) |
| Vlow | 0 | Logic low level (V) |
| Trise | 0 | Rise time (sec) — highly recommended to set non-zero (e.g., 10n) |
| Tfall | Trise | Fall time (sec) |
| Td | 0 | Propagation delay (sec) |
| Rout | 1 | Output impedance (Ohm) |
| Cout | 0 | Output capacitance (F) |
| Ref | (Vhigh+Vlow)/2 | Logic threshold (V) |

### Schmitt Trigger Parameters

- **Vt**: Trip point center voltage
- **Vh**: Half-hysteresis; low trip = Vt-Vh, high trip = Vt+Vh (must be positive — negative hysteresis not supported)

### OTA (Transconductance Amplifier)

Symbols: OTA, OTA2, MOTA, MOTA2, MOTA3, MOTA8

| Parameter | Default | Description |
|-----------|---------|-------------|
| G | 1 | Transconductance (S) |
| Vhigh | 2V | High compliance limit |
| Vlow | 0V | Low compliance limit |
| Iout | 10u | Maximum source current |
| Isink | -Iout | Maximum sink current |
| Rout | Infinite | Output resistance |
| Cout | 0 | Output capacitance |

### MODULATE (VCO)

- mark: Frequency at FM input = 1V
- space: Frequency at FM input = 0V

---

## X — Subcircuit

```spice
Xxxx n1 n2 n3 ... <subckt_name> [param1=val1] [param2=val2]
```

**Example**:
```spice
X1 in out 0 divider top=9K bot=1K

.subckt divider A B C
R1 A B {top}
R2 B C {bot}
.ends divider
```

Parametric instantiation with string expression:
```spice
X1 in out 0 {name} top=9K bot=1K
```

### Pin Name Annotation (`;§pnba`)

Subcircuit instances generated by the LTspice netlister may end with a special comment that records the pin names of the symbol. The comment begins with `;§pnba` followed by a list of pin names delimited by a right parenthesis `)`.

```spice
X§U1 0 N001 NC_01 N004 NC_02 N003 N002 NC_03 IN IN LT8609S ;§pnba GND)SW)INTVcc)RT)SYNC)FB)TR/SS)PG)VIN)EN/UV
```

When present:

- The pin names appear in the **same order** as the node (net) assignments on the instance line.
- Each pin name maps positionally to a node: the first pin name corresponds to the first node, the second to the second, and so on.
- The names are the labels on the symbol's pins, letting you recover the symbolic meaning of each net connection.

In the example above, the mapping is:

| Node | Pin Name |
|------|----------|
| `0` | GND |
| `N001` | SW |
| `NC_01` | INTVcc |
| `N004` | RT |
| `NC_02` | SYNC |
| `N003` | FB |
| `N002` | TR/SS |
| `NC_03` | PG |
| `IN` | VIN |
| `IN` | EN/UV |

Because `;§pnba` is introduced by `;`, it is an ordinary comment and is ignored by the simulator — it exists purely to preserve the symbol pin names alongside the net assignments.

---

## @ — Frequency Response Analyzer

**Symbols**: FRA

```spice
@xxx out in [zm] [nobode] [delay=<val>] [fstart=<val>] [fend=<val>]
+ [oct=<val> | dec=<val>] [fcoarse=<val>] [flist=<values>]
+ [pp0=<val> [pp1=<val> f0=<val> f1=<val>]] [pp=<values>] [tavgmin=<val>] [tsettle=<val>]
+ [rpar=<val>] [refnode=<netname>] [intnode=<netname>] [acmag=<val>] [acphase=<val>] [enabled=<0|1>]
```

During a [`.fra`](SIMULATION-COMMANDS-REFERENCE.md#fra--frequency-response-analysis) simulation, the analyzer applies sinusoidal stimuli and measures the circuit response. Used to analyze loop gain versus frequency or impedance versus frequency. For a step-by-step procedure using this device, see [SMPS Bode Plots (FRA)](FAQ-AND-TIPS.md#smps-bode-plots-fra).

**Analysis mode**:

- Default — **gain analysis**: applies a voltage stimulus between the terminals and analyzes the absolute voltage at each terminal.
- With the `zm` keyword — **impedance analysis**: applies a current stimulus and analyzes the voltage *across* the terminals.

**Terminals**: `out` is the first node (symbol pin OUT, the flat side) and `in` the second (pin IN, the pointy side). For gain, `out` goes on the low-impedance side of the loop break (typically the converter output) and `in` on the high-impedance side (the feedback divider or error-amplifier input). For output impedance, `out` goes to the converter output and `in` to ground.

**Examples**:

| Device line | What it does |
|-------------|--------------|
| `@1 OUT FB` | Loop gain, configured automatically: crossover frequency, phase margin, gain margin and a Bode plot |
| `@1 OUT FB nobode` | Crossover frequency and phase margin only, no Bode plot; takes less time |
| `@1 OUT FB fstart=1k fend=200k` | Configured automatically, within the given frequency range |
| `@1 OUT FB delay=1m fstart=1k fend=500k oct=2 pp0=20m pp1=5m f0=10k f1=40k tavgmin=100u tsettle=200u` | Every setting given: the sweep is applied exactly as specified |
| `@z1 OUT 0 zm pp=100m` | Output impedance, 100 mA peak-to-peak stimulus |

### Automatic Configuration

**Every parameter is optional**, with two exceptions: impedance (`zm`) needs a stimulus amplitude (see [Impedance Analysis](#impedance-analysis-zm)), and a single frequency (`fstart` = `fend`) needs an amplitude and `tsettle`. LTspice sets each parameter that is left out from the circuit itself: it detects steady state, measures the switching frequency, finds the crossover frequency, and chooses the frequencies, stimulus amplitudes, and settling and averaging times. A parameter that is given is used as given, and the rest are chosen around it.

**Start from a bare device line** (`@1 OUT FB` with a plain `.fra`) and add parameters only to constrain the result — a start time (`delay`), a frequency range. The example schematics in **Educational\FRA\** do the same: their FRA devices give no parameters beyond what the measurement needs, which is `zm` and a stimulus amplitude for output impedance, and a `delay` where steady-state detection needs help.

How a device is measured depends on what its line gives and on the circuit:

| Device line gives | Circuit | Measured by |
|-------------------|---------|-------------|
| A resolution (`oct` or `dec`, or `fstart` = `fend`), an amplitude (`pp` or `pp0`…), and `tsettle` | Switching | The sweep exactly as specified. Any of `delay`, `fstart`, `fend`, `tavgmin` left out is set automatically |
| Anything less | Switching | The automatic sweep |
| Anything except all of `delay`, `fstart`, `fend`, `oct` or `dec`, an amplitude, `tsettle` and `tavgmin` | Does not switch | Small-signal AC at the steady-state operating point — see [Circuits That Do Not Switch](#circuits-that-do-not-switch) |
| All of `delay`, `fstart`, `fend`, `oct` or `dec`, an amplitude, `tsettle` and `tavgmin` | Does not switch | The time-domain sweep exactly as specified |

### Results

- **Default**: a Bode plot, with the crossover frequency (f0dB), phase margin and gain margin shown on it. In the GUI, Ctrl+L in the Bode plot opens the SPICE error log.
- **`nobode`**: only f0dB and the phase margin are measured, which takes less time. There is no Bode plot and no `.fra` raw file; the GUI opens the log when the run ends. `nobode` is an error together with `oct`, `dec` or `flist`, and with `zm`.

The log reports the results. Read it with `get_spice_log` when driving LTspice through MCP:

```
FRA @1: f0dB = 94452.6 Hz, phase margin = 63.628 deg, slope -20.61 dB/decade
FRA Instance @1: F(0dB) = 94.249 kHz, Phase Margin = 63.8 degrees, Gain Margin = 13.2 dB at 261.651 kHz
```

The `FRA Instance` line holds the figures shown on the Bode plot. The automatic sweep also logs its own crossover measurement, the `FRA @1: f0dB = …` line — the only result with `nobode`. The two can differ slightly. A non-switching circuit logs `FRA @1: 94 frequencies analyzed, 1 Hz to 1e+09 Hz, starting at t = … seconds.` before its `FRA Instance` line, and an `FRA @1: f0dB = …` line only with `nobode`. Any message starting `Error:` or `Warning:` should be read before trusting a result. So should `FRA @1: the loop gain could not be measured: …` (or `the impedance`), which has neither prefix: that device has no result.

The Bode data is in `<circuit>.fra_<instance>.raw`, where `<instance>` is the device name without `@` (`fra_1` for `@1`). Signals: `gain_<instance>` (or `impedance_<instance>` with `zm`), `V(stimulus_<instance>)` (or `I(stimulus_<instance>)`), `gain_<instance>_<intnode>` with `intnode`, and `probe_<probe name>` per probe.

The main `.raw` file holds the time-domain simulation, not the whole sweep: the start-up to steady state, then at most one stimulus.

| Run | Stimulus in the main `.raw` |
|-----|-----------------------------|
| Loop gain, automatic, with a Bode plot | One, near f0dB: of the frequencies LTspice used to find the crossover, the one nearest it |
| `zm`, automatic | One, near the middle of the frequency range |
| Single frequency (`fstart` = `fend`) | That frequency |
| `nobode`; a fully specified sweep of several frequencies; `delay=0` | None: the file ends at steady state |
| A circuit measured by small-signal AC | None: a single point |

The log names the stimulus, for example `FRA - the .raw file shows @1's tone of 93806.6 Hz from 0.00010653 to 0.000270171 seconds, one of the frequencies it measured.` With several FRA devices, only the first one's stimulus is included. A single-frequency sweep is the way to inspect a chosen stimulus in the time domain.

### When the Analysis Starts

**With no `delay`**, the analysis starts once LTspice detects steady state. Detection works in most circuits: those using an ADI product model that supports steady-state detection, other switching circuits, and circuits that do not switch. The one exception is a circuit whose independent sources repeat at different frequencies — two clocks, or a clock and a repeating load pulse at another frequency — without such an ADI model. That is an error; give a `delay`.

**`.fra` `Tstop` is the maximum time to wait for steady state.** Without it, the limit is 5 ms, counted from the end of any one-off change in the sources, such as a start-up ramp. If the circuit has not settled by then, it is an error (`Error: FRA @1 did not reach steady state …, so the analysis was not started.`), and nothing is analyzed: give a `delay` after the circuit settles, or a longer `Tstop`.

`Tstop` applies only to the settling simulation, the time before the analysis starts. It does not interrupt the frequency response analysis itself: once that has started, every frequency runs to completion. A device whose `delay` is later than `Tstop` analyzes nothing, with a warning (`Warning: no frequencies of FRA instance @1 were analysed …`); any other FRA devices are measured as usual.

**With a `delay`**, the analysis starts at that time. With a supporting ADI model, LTspice warns if steady state has not been detected by then (`Warning: FRA @1: the analysis started at its delay of … seconds, but the circuit had not reached steady state by then …`); a non-switching circuit that is not static at its `delay` is an error. Other switching circuits are not checked: confirm in the waveform that the circuit had settled. `delay=0` starts at the operating point. `delay` is absolute simulation time from t=0, also when the run starts from a `loadstate` file; see [SMPS Bode Plots, Step 3](FAQ-AND-TIPS.md#step-3-run-the-automatic-fra).

**A source that changes during the analysis is warned of**, one line per source: for example a load step `PULSE` that falls inside the sweep. The frequencies measured across the change may be wrong. Periodic sources (a clock, a repeating PWL) are part of the steady state and are not warned of. Move the change outside the analysis, or set `delay` after it.

### Circuits That Do Not Switch

A circuit that does not switch — an op-amp loop, a linear regulator — is measured with small-signal AC analysis once it is at steady state, gain and `zm` alike. This is much faster than a time-domain sweep. The stimulus amplitude, `tsettle`, `tavgmin` and `fcoarse` are not used (the log lists any that were given). Default frequencies: 1 Hz to 1 GHz, 10 per decade; `fstart`, `fend`, `oct` or `dec`, and `flist` apply as given.

The AC analysis is made at the steady-state operating point, so for a circuit with no `delay` and no initial conditions it runs straight from the DC operating point, and the main `.raw` has no transient to show.

To measure such a circuit with a time-domain sweep instead — for example, to see large-signal effects — give all of `delay`, `fstart`, `fend`, `oct` or `dec`, an amplitude, `tsettle` and `tavgmin`.

### Impedance Analysis (zm)

- **The stimulus amplitude is required** for a switching circuit: `pp`, or `pp0` (with `pp1`, `f0`, `f1` to vary it with frequency), in amps peak-to-peak.
- Default range: `fstart` = fsw/1000 to `fend` = 10 × fsw, where fsw is the measured switching frequency.
- `nobode` and [FRA probes](#--frequency-response-analysis-probe) (`&`) cannot be used with `zm`; both are errors.
- The feedback loop stays closed. Remove or disable (`enabled=0`) any gain FRA device in the loop.

**Output impedance setup**: connect `out` to the converter output and `in` to ground. Load the output with **50 % of the expected maximum load current**, and set the stimulus amplitude to **10 % of the expected maximum load current**. For a converter rated for 2 A:

```spice
I1 OUT 0 1 load       ; 50 % of the 2 A maximum
@z1 OUT 0 zm pp=200m  ; 10 % of the 2 A maximum
.fra
```

Example schematic: `fra_eg7_LT8618_zout.asc` in **Educational\FRA\**.

### Analysis Frequencies

- **`fstart`, `fend`** — the lowest and highest frequencies. The lowest frequencies take the longest to analyze, so a higher `fstart` reduces the simulation time. Defaults for a switching circuit:
  - `fstart` for gain: the higher of fsw/1000 and 1 kHz, but no higher than f0dB/10, so that the Bode plot always reaches a decade below the crossover — min(f0dB/10, max(fsw/1000, 1 kHz)).
  - `fstart` for `zm`, or for a fully specified sweep: fsw/1000.
  - `fend`: 0.43 × fsw for gain (below half the switching frequency, where a stimulus can no longer be told apart from the switching), 10 × fsw for `zm`.
- **One frequency**: `fstart` = `fend`. Requires an amplitude and `tsettle`; it is an error without them.
- **`oct`, `dec`** — points per octave or per decade; giving both is an error. Values of 1 or more are rounded to whole numbers; values below 1 space the points out (`oct=0.5` is one point every two octaves). With neither, LTspice uses about 3 points per decade with more where the response changes quickly. **Leave both out** unless the sweep is to be fully specified (resolution, amplitude and `tsettle`): giving either replaces LTspice's choice of frequencies, including the points it adds where the response changes quickly.
- **`fcoarse`** — at most one point per octave below `fcoarse`. Setting it to 2–10 × `fstart` can greatly reduce simulation time. Use it with `oct`: the automatic configuration ignores it otherwise.
- **`flist`** — specific frequencies, added to the sweep.

### Stimulus Amplitude

Amplitudes are **peak-to-peak**, in volts for gain and amps for `zm`. For gain, LTspice chooses the amplitude when none is given. Otherwise, use one of three methods:

| Method | Behavior |
|--------|----------|
| `pp0` alone | Sets one stimulus amplitude across all frequencies. |
| `pp0`, `pp1`, `f0`, `f1` | Amplitude is `pp0` up to `f0`, `pp1` above `f1`, and logarithmically interpolated between `(f0, pp0)` and `(f1, pp1)`. |
| `pp` | Piecewise logarithmic amplitude vs. frequency, as space-delimited frequency-amplitude pairs. `pp=1k 10m 10k 1m` is equivalent to `f0=1k pp0=10m f1=10k pp1=1m`. A single value sets one amplitude for all frequencies. |

For gain analysis, typically `pp0 > pp1` — a larger stimulus at low frequencies, where high loop gain suppresses the injected perturbation, and a smaller one at high frequencies, where the loop no longer attenuates it and too much drive would disturb the operating point.

A given amplitude is applied exactly, at every frequency. Giving one for gain therefore fixes what the automatic configuration would otherwise choose.

### Timing

- **`tsettle`** — time between a stimulus first being applied and analysis beginning. Chosen automatically when left out. Required only for a single frequency (`fstart` = `fend`); otherwise give it only for a fully specified sweep, of which it is one of the three settings. A good starting point is `2/f0dB`.
- **`tavgmin`** — minimum time each stimulus is analyzed; the analysis time is increased in whole periods of the stimulus until it reaches `tavgmin`. Defaults to 100 switching periods (`100/fsw`), so the switching ripple averages out.
- **`delay`** — see [When the Analysis Starts](#when-the-analysis-starts).

### Alternate Measurement Nodes

- **`refnode`** — measures the `in` and `out` node voltages relative to `refnode` instead of ground. This allows FRA to be used on, for example, circuits that regulate current via the voltage across a sense resistor. Not applicable to impedance analysis.
- **`intnode`** — specifies an intermediate node for an additional gain analysis, useful for analyzing the external compensation point of a regulator. The gain from the FRA device to `intnode` is written to the `.fra` raw file as `gain_<instance>_<intnode>`.

**The [FRA probe](#--frequency-response-analysis-probe) (`&`, symbol `fraprobe`) is generally preferred over both**, because its connections state explicitly what it measures. It takes an explicit differential pair at each end, adds measurement points without altering how the loop is broken, and — marked `loopgain` — moves the crossover and margin measurement to where it is placed.

### Results and Bode Plot

The crossover frequency and margins are measured at the device's **measurement point**, which is also the trace the Bode plot shows:

| FRA device terminals | FRA probes (`&`) of this device | Measurement point and plotted trace |
|----------------------|---------------------------------|-------------------------------------|
| Any | One marked `loopgain` | That probe |
| Neither grounded, or a `refnode` given | Any number, none `loopgain` | The FRA device itself (`gain_<instance>`) |
| One grounded | Exactly one | That probe |
| One grounded | Several, none `loopgain` | None: mark one `loopgain`. An error, except in a fully specified sweep |
| One grounded (gain) | None, and no `refnode` | Error |

To be sure the plot and margins come from the intended point, mark that probe `loopgain`. Every probe's result is in the `.fra` raw file, as `probe_<fraprobe_instance_name>`, and can be added to the plot with **View > Add Trace**.

### Errors Worth Knowing

These are fatal (`Error:` in the log) rather than silently worked around:

| Condition | Fix |
|-----------|-----|
| `oct` and `dec` both given | Give one |
| `nobode` with `oct`, `dec`, `flist` or `zm` | Remove `nobode`, or the other parameter |
| `fstart` = `fend` without an amplitude and `tsettle` | Give both, or a wider range |
| `zm` on a switching circuit with no amplitude | Give `pp` (amps) |
| A probe of a `zm` device | Remove the probe |
| Grounded terminal, several probes, none `loopgain` | Mark one probe `loopgain` |
| Two `loopgain` probes for one device, or `loopgain` on a probe of a disabled device | Mark one probe of an enabled device |
| No `delay`, no supporting ADI model, sources repeating at different frequencies | Drive the circuit from one clock, or give a `delay` |
| No `delay`, and the circuit had not settled by the time limit (`.fra` `Tstop`, else 5 ms) | Give a `delay`, or a longer `.fra` `Tstop` |
| Non-switching circuit not static at its `delay` | Give a later `delay` |
| Several FRA devices measuring loop gain, a circuit switching at more than one frequency, and fewer supporting ADI models than such devices | Measure one loop at a time, with the other devices disabled (`enabled=0`) |

### Parameters

fsw is the switching frequency LTspice measures. For non-switching circuits, see [Circuits That Do Not Switch](#circuits-that-do-not-switch).

| Parameter | Description | Units | Default |
|-----------|-------------|-------|---------|
| zm | Measure impedance instead of gain | — | gain |
| nobode | Measure only the crossover frequency and phase margin (gain only) | — | Bode plot produced |
| delay | Stimulus start time | sec | when steady state is detected |
| fstart | Lowest frequency | Hz | the higher of fsw/1000 and 1 kHz, but no higher than f0dB/10 (gain) / fsw/1000 (impedance, or a fully specified sweep) |
| fend | Highest frequency | Hz | 0.43 × fsw (gain) / 10 × fsw (impedance) |
| oct | Points per octave | — | automatic |
| dec | Points per decade | — | automatic |
| fcoarse | Upper frequency for coarse stepping; use with `oct` | Hz | — |
| flist | Specific frequencies added to the sweep | Hz | — |
| pp0 | Stimulus amplitude for frequencies below `f0` (if specified), peak-to-peak | V (gain) / A (impedance) | automatic (gain) / required (impedance) |
| pp1 | Stimulus amplitude for frequencies above `f1`, peak-to-peak | V (gain) / A (impedance) | — |
| f0 | Maximum frequency for `pp0` | Hz | — |
| f1 | Minimum frequency for `pp1` | Hz | — |
| pp | Piecewise logarithmic amplitude vs. frequency | Hz,V or Hz,A pairs | — |
| tavgmin | Minimum analysis time for each stimulus frequency | sec | 100/fsw |
| tsettle | Settling time at each frequency before analysis begins | sec | automatic |
| rpar | Parallel resistance | Ohm | 1m (gain) / 1T (impedance) |
| acmag | AC current magnitude (`.ac` simulations only) | A | 0 |
| acphase | AC current phase (`.ac` simulations only) | degrees | 0 |
| ac | AC current magnitude, phase pair (`.ac` simulations only) | A,degrees | 0,0 |
| enabled | Analyzer enable (0 or 1) | — | 1 |
| refnode | Reference node for voltage gain analysis | — | 0 |
| intnode | Intermediate node for additional gain analysis | — | — |
| nmax | Ignored. Present in the example schematics; has no effect | — | — |

---

## & — Frequency Response Analysis Probe

**Symbols**: FRAPROBE

```spice
&xxx o+ o- i+ i- [fra=@<instance>] [loopgain]
```

Used in conjunction with an [`@` Frequency Response Analyzer](#--frequency-response-analyzer) during a [`.fra`](SIMULATION-COMMANDS-REFERENCE.md#fra--frequency-response-analysis) simulation, the probe analyzes gain between any two differential points. The stimulus is controlled entirely by the FRA device.

**Example**: `&1 FBX 0 FB 0 fra=@1 loopgain` — the loop of `@1`, measured from `FB` to `FBX`, with the crossover and margins taken there.

**Result**: the complex quantity `V(o+,o-) / V(i+,i-)` versus frequency, written to the FRA complex raw output file `<circuit>.fra_<fra_instance_name>.raw` as a signal named `probe_<fraprobe_instance_name>`. Whether that signal is plotted automatically, and whether the margins are measured there, is set by `loopgain` — see [Results and Bode Plot](#results-and-bode-plot).

The differential input and output pairs suit applications such as the following, each with an example schematic in **File > Open Examples > Educational\FRA\**:

- SMPS micromodules with integrated top feedback resistors — `fra_eg8_ltm8074_probe.asc`
- Analyzing the gain of an intermediate portion of a control loop — for example from the compensation point of an SMPS to the output, known as the modulator gain — `&mod` in `fra_eg6_LT3763_probe_current.asc`, which measures from the compensation point VC to the output current sense
- Differential feedback, such as current-feedback circuits — `&1` in the same example, taken differentially across the output current sense resistor
- Inverting (negative output) SMPS circuits — `fra_eg10_LT8609_inverting_probe.asc`

Prefer this device to the FRA device's [`refnode` and `intnode`](#alternate-measurement-nodes) parameters: the probe's connections state explicitly what it measures.

### Probe Parameters

- **`fra=@<instance>`** — the FRA device the probe belongs to. If left out: the only FRA device in the circuit, else the FRA device of the same name (`&1` with `@1`, `&2` with `@2`, and so on).
- **`loopgain`** — use this probe for loop gain analysis: the crossover frequency, phase margin and gain margin are measured there, the automatic configuration measures the loop there, and the Bode plot shows it. This applies to a fully specified sweep too. At most one `loopgain` probe per FRA device; the others are measured beside it and appear in the raw file.

In the GUI, right-clicking the probe opens a dialog with both settings: the FRA device, and the checkbox **Use this Probe for Automatic Loop Gain Analysis** for `loopgain`.

### Multiple Loops and Probes

A circuit with more than one feedback loop can have its loops analyzed simultaneously by configuring a separate FRA device for each independent loop. Any number of probes may belong to one FRA device. With several FRA devices, give each probe `fra=` (or name it after its device) so the association is explicit.

Probes cannot be used with a `zm` (impedance) device.

**Examples**: in that same directory, any schematic with "probe" in the filename demonstrates the probe device.

---

*See also: [SPICE-SYNTAX-REFERENCE.md](SPICE-SYNTAX-REFERENCE.md) for netlist conventions, [SIMULATION-COMMANDS-REFERENCE.md](SIMULATION-COMMANDS-REFERENCE.md) for dot commands*
---

*Documentation source: [github.com/analogdevicesinc/ltspice-reference](https://github.com/analogdevicesinc/ltspice-reference)*
