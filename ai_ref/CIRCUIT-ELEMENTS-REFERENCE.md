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

*See also: [SPICE-SYNTAX-REFERENCE.md](SPICE-SYNTAX-REFERENCE.md) for netlist conventions, [SIMULATION-COMMANDS-REFERENCE.md](SIMULATION-COMMANDS-REFERENCE.md) for dot commands*
---

*Documentation source: [github.com/analogdevicesinc/ltspice-reference](https://github.com/analogdevicesinc/ltspice-reference)*
