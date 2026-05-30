# LTspice .MEAS Statement Reference

This document contains `.MEAS` statement examples for various simulation types.

`.MEAS` results appear in the SPICE Output Log (View → SPICE Output Log, or CTRL+L)

## Table of Contents

- [.MEAS with AC Analysis - Key Functions](#meas-with-ac-analysis---key-functions)
- [AC Analysis .MEAS Examples](#ac-analysis-meas-examples)
- [.MEAS with Noise Analysis - Key Functions](#meas-with-noise-analysis---key-functions)
- [Noise Analysis .MEAS Examples](#noise-analysis-meas-examples)

#### TODO

- [ ] Add transient analysis .MEAS examples
- [ ] Add DC sweep .MEAS examples
- [x] Add noise analysis .MEAS examples
- [ ] Add operating point .MEAS examples



## .MEAS with AC Analysis - Key Functions

### Measurement Functions

| Function | Description |
|----------|-------------|
| `V(node)` | Complex voltage (magnitude and phase) |
| `I(component)` | Complex current through component (magnitude and phase) |
| `mag(V(node))` | Voltage magnitude |
| `mag(I(component))` | Current magnitude |
| `ph(V(node))` | Voltage phase in degrees |
| `ph(I(component))` | Current phase in degrees |
| `re(V(node))` | Real part of complex voltage |
| `re(I(component))` | Real part of complex current |
| `im(V(node))` | Imaginary part of complex voltage |
| `im(I(component))` | Imaginary part of complex current |

### Measurement Operations

| Operation | Description |
|-----------|-------------|
| `FIND ... AT freq` | Find value at specific frequency |
| `WHEN condition` | Find frequency when condition is met |
| `MAX` | Find maximum value |
| `PARAM {expr}` | Calculate parameter from measured values |
| `CROSS=1` | First crossing of condition |
| `CROSS=2` | Second crossing of condition |
| `CROSS=LAST` | Last crossing of condition |

**Best Practices:**
- Use `.options meascplxfmt=polar` to display results in linear magnitude and phase (default is dB and phase)
- Use `.options meascplxfmt=cartesian` to display results in real and imaginary format
- Use relative measurements (e.g., `Vout_max/sqrt(2)`) instead of absolute thresholds for robustness
- Functions `mag()`, `ph()`, `re()`, and `im()` extract specific components of complex AC voltages and currents



## AC Analysis .MEAS Examples

1. [Measure Amplitude at a Specific Frequency](#measure-amplitude-at-a-specific-frequency)
2. [Find the Amplitude at a Specific Frequency (Linear Format)](#find-the-amplitude-at-a-specific-frequency-linear-format)
3. [Measure Amplitude at Specific Frequency (Cartesian Format)](#measure-amplitude-at-specific-frequency-cartesian-format)
4. [Find DC Gain (Gain at Lowest Frequency)](#find-dc-gain-gain-at-lowest-frequency)
5. [Find -3dB Cutoff Frequency](#find--3db-cutoff-frequency)
6. [Measure Phase at Specific Frequency](#measure-phase-at-specific-frequency)
7. [Measure Phase at Specific Frequency - Default Reporting in dB](#measure-phase-at-specific-frequency---default-reporting-in-db)
8. [Find Frequency Where Phase = -45°](#find-frequency-where-phase---45)
9. [Calculate Slope](#calculate-slope)
10. [Measure Bandwidth (Between Two Frequencies)](#measure-bandwidth-between-two-frequencies)
11. [Find Maximum Output](#find-maximum-output)
12. [Quality Factor (for Bandpass Filters)](#quality-factor-for-bandpass-filters)

**Important Note:** Amplitude results from `.MEAS` statements in AC simulations are always reported as complex numbers (magnitude and phase), even when measuring only the magnitude, phase, real, or imaginary portions of a data point. The display format can be controlled with `.options meascplxfmt=polar` (linear magnitude, phase in degrees) or the default dB format (dB magnitude, phase in degrees).

---

### Measure Amplitude at a Specific Frequency

**Complete netlist:**
```spice
* RC Low-Pass Filter - Measure Amplitude at Specific Frequencies
V1 in 0 AC 1
R1 in out 1k
C1 out 0 159nF

.ac dec 100 1 1Meg

.meas AC voltage_amplitude_1kHz FIND V(out) AT 1kHz
.meas AC voltage_amplitude_10kHz FIND V(out) AT 10kHz
.meas AC current_amplitude_1kHz FIND I(C1) AT 1kHz
.meas AC current_amplitude_10kHz FIND I(C1) AT 10kHz

.end
```

**Expected output (SPICE Output Log):**
```
voltage_amplitude_1khz: V(out) =(-3.00607194349dB,-44.9720966632°) at 1000
voltage_amplitude_10khz: V(out) =(-20.0348374361dB,-84.28387881°) at 10000
current_amplitude_1khz: I(C1) =(-63.0145320899dB,45.0279033368°) at 1000
current_amplitude_10khz: I(C1) =(-60.0432975825dB,5.71612119002°) at 10000
```
**Notes:**
- Default format displays results in dB and phase
- The `FIND ... AT` syntax measures the value at exactly the specified frequency
- Both voltage and current measurements can be performed using `V(node)` and `I(component)` syntax
---

### Find the Amplitude at a Specific Frequency (Linear Format)

**Complete netlist:**
```spice
* RC Low-Pass Filter - Find Amplitude at Specific Frequency (Linear)
V1 in 0 AC 1
R1 in out 1k
C1 out 0 159nF

.ac dec 100 1 1Meg

.options meascplxfmt=polar

.meas AC amplitude_1kHz FIND V(out) AT 1kHz
.meas AC amplitude_10kHz FIND V(out) AT 10kHz

.end
```

**Expected output (SPICE Output Log):**
```
amplitude_1khz: V(out) =(0.707451061927,-44.9720966632°) at 1000
amplitude_10khz: V(out) =(0.0995997224501,-84.28387881Â°) at 10000
```

**Notes:**
- `.options meascplxfmt=polar` displays measurements in linear magnitude and phase format
- Default format (without this option) displays measurements in dB and phase
- The `FIND ... AT` syntax measures the value at exactly the specified frequency

---
### Measure Amplitude at Specific Frequency (Cartesian Format)

**Complete netlist:**
```spice
* RC Low-Pass Filter - Measure Amplitude at Specific Frequencies (Cartesian)
V1 in 0 AC 1
R1 in out 1k
C1 out 0 159nF

.ac dec 100 1 1Meg

.options meascplxfmt=cartesian

.meas AC amplitude_1kHz FIND V(out) AT 1kHz
.meas AC amplitude_10kHz FIND V(out) AT 10kHz

.end
```

**Expected output (SPICE Output Log):**
```
amplitude_1khz: V(out) =(0.500487005022,-0.499999762826) at 1000
amplitude_10khz: V(out) =(0.00992010471214,-0.0991044713151) at 10000
```

**Notes:**
- `.options meascplxfmt=cartesian` displays measurements in real + imaginary format

---

### Find DC Gain (Gain at Lowest Frequency)

**Complete netlist:**
```spice
* RC Low-Pass Filter - Find DC Gain
V1 in 0 AC 1
R1 in out 1k
C1 out 0 159nF

.ac dec 100 1 1Meg

.meas AC DC_gain FIND mag(V(out)) AT 1Hz

.end
```

**Expected output (SPICE Output Log):**
```
dc_gain: mag(V(out)) =(-4.33449074446e-06dB,0°) at 1
```

---

### Find -3dB Cutoff Frequency

**Complete netlist:**
```spice
* RC Low-Pass Filter - Find Cutoff Frequency
V1 in 0 AC 1
R1 in out 1k
C1 out 0 159nF

.ac dec 100 1 1Meg

* Basic method using magnitude
.meas AC cutoff_freq WHEN mag(V(out)) = 1/sqrt(2)

* Basic method using phase
.meas AC cutoff_freq2 WHEN ph(V(out)) = -45

* Basic method using real
.meas AC cutoff_freq3 WHEN re(V(out)) = .5

* Basic method using imaginary
.meas AC cutoff_freq4 WHEN im(V(out)) = -.499999

* Robust method (relative to DC gain)
.meas AC dc_gain FIND mag(V(out)) AT 1
.meas AC cutoff_freq5 WHEN mag(V(out)) = dc_gain/sqrt(2)

.end
```

**Expected output (SPICE Output Log):**
```
cutoff_freq: mag(V(out)) =1/sqrt(2) AT 1000.97471156
cutoff_freq2: ph(V(out)) =-45 AT 1000.99644414
cutoff_freq3: re(V(out)) =.5 AT 1000.98546328
cutoff_freq4: im(V(out)) =-.499999 AT 1000.14647293
dc_gain: mag(V(out)) =(-4.33449074446e-06dB,0°) at 1
cutoff_freq5: mag(V(out)) =dc_gain/sqrt(2) AT 1000.97571081
```

**Notes:**
- Use `mag(V(out))` instead of `V(out)` for AC magnitude measurements
- `-3dB` point corresponds to `1/sqrt(2)` or `0.707` of the DC gain
- The robust method first measures DC gain, then finds cutoff relative to it

---

### Measure Phase at Specific Frequency

**Complete netlist:**
```spice
* RC Low-Pass Filter - Measure Phase
V1 in 0 AC 1
R1 in out 1k
C1 out 0 159nF

.ac dec 100 1 1Meg

.options meascplxfmt=polar

.meas AC phase_1kHz FIND ph(V(out)) AT 1kHz

.end
```

**Expected output (SPICE Output Log):**
```
phase_1khz: ph(V(out)) =(44.9720966632,180°) at 1000
```

**Notes:**
- Phase is reported in linear polar form when using `.options meascplxfmt=polar`
- `(44.97, 180°)` equates to -44.97° (magnitude at 180° = negative value)

---

### Measure Phase at Specific Frequency - Default Reporting in dB

**Complete netlist:**
```spice
* RC Low-Pass Filter - Measure Phase (dB format)
V1 in 0 AC 1
R1 in out 1k
C1 out 0 159nF

.ac dec 100 1 1Meg

.meas AC phase_1kHz FIND ph(V(out)) AT 1kHz

.end
```

**Expected output (SPICE Output Log):**
```
phase_1khz: ph(V(out)) =(33.0588627093dB,180°) at 1000
```

**Notes:**
- Without `.options meascplxfmt=polar`, phase is reported in dB format
- The result shows the phase in terms of dB (which is likely not useful)

---

### Find Frequency Where Phase = -45°

**Complete netlist:**
```spice
* RC Low-Pass Filter - Find Frequency at -45 Degrees Phase
V1 in 0 AC 1
R1 in out 1k
C1 out 0 159nF

.ac dec 100 1 1Meg

.meas AC f_45deg WHEN ph(V(out))=-45

.end
```

**Expected output (SPICE Output Log):**
```
f_45deg: ph(V(out))=-45 AT 1000.99644414
```

---

### Calculate Slope

**Complete netlist:**
```spice
* RC Low-Pass Filter - Calculate Rolloff Rate
V1 in 0 AC 1
R1 in out 1k
C1 out 0 159nF

.ac dec 100 1 1Meg

.meas AC gain_10kHz FIND mag(V(out)) AT 10kHz
.meas AC gain_100kHz FIND mag(V(out)) AT 100kHz
.meas AC rolloff PARAM {gain_100kHz/gain_10kHz}
* Should be close to -20dB/decade for first-order filter

.end
```

**Expected output (SPICE Output Log):**
```
gain_10khz: mag(V(out)) =(-20.0348374361dB,0°) at 10000
gain_100khz: mag(V(out)) =(-39.9919749731dB,0°) at 100000
rolloff: {gain_100kHz/gain_10kHz}=(-19.957137537dB,0°)
```

---

### Measure Bandwidth (Between Two Frequencies)

**Complete netlist:**
```spice
* RLC Bandpass Filter - Measure Bandwidth
V1 in 0 AC 1
R1 out 0 100
L1 in n1 10m
C1 n1 out 253n

.ac dec 100 10 100k

.options meascplxfmt=polar

.meas AC f_lower WHEN mag(V(out))=1/sqrt(2) CROSS=1
.meas AC f_upper WHEN mag(V(out))=1/sqrt(2) CROSS=LAST
.meas AC bandwidth PARAM {f_upper-f_lower}

.end
```

**Expected output (SPICE Output Log):**
```
f_lower: mag(V(out))=1/sqrt(2)  AT 2467.09854574
f_upper: mag(V(out))=1/sqrt(2)  AT 4058.53869986
bandwidth: {f_upper-f_lower}=(1591.44015412,0°)
```

---

### Find Maximum Output

**Complete netlist:**
```spice
* RLC Bandpass Filter - Find Peak Response
V1 in 0 AC 1
R1 out 0 100
L1 in n1 10m
C1 n1 out 253n

.ac dec 100 10 100k

.meas AC Vout_max MAX mag(V(out))
.meas AC freq_at_max WHEN mag(V(out))=Vout_max

.end
```

**Expected output (SPICE Output Log):**
```
vout_max: MAX(mag(V(out)))=(-0.000111442946874dB,0°) FROM 10 TO 100000
freq_at_max: mag(V(out))=Vout_max AT 3162.27766017
```

---

### Quality Factor (for Bandpass Filters)

**Complete netlist:**
```spice
* RLC Bandpass Filter - Calculate Q Factor
V1 in 0 AC 1
R1 out 0 100
L1 in n1 10m
C1 n1 out 253n

.ac dec 100 10 100k

.options meascplxfmt=polar

.meas AC Vout_max MAX mag(V(out))
.meas AC f_center WHEN mag(V(out))=Vout_max
.meas AC f_3dB_low WHEN mag(V(out))=Vout_max/sqrt(2) CROSS=1
.meas AC f_3dB_high WHEN mag(V(out))=Vout_max/sqrt(2) CROSS=2
.meas AC bandwidth PARAM {f_3dB_high-f_3dB_low}
.meas AC Q_factor PARAM {f_center/bandwidth}

.end
```

**Expected output (SPICE Output Log):**
```
vout_max: MAX(mag(V(out)))=(0.999987169739,0°) FROM 10 TO 100000
f_center: mag(V(out))=Vout_max AT 3162.27766017
f_3db_low: mag(V(out))=Vout_max/sqrt(2)  AT 2467.08295647
f_3db_high: mag(V(out))=Vout_max/sqrt(2)  AT 4058.56400569
bandwidth: {f_3dB_high-f_3dB_low}=(1591.48104922,0°)
q_factor: {f_center/bandwidth}=(1.98700302571,0°)
```

---


## .MEAS with Noise Analysis - Key Functions

### Measurement Functions

| Function | Description |
|----------|-------------|
| `V(onoise)` | Total output-referred noise (V/√Hz) |
| `V(inoise)` | Total input-referred noise (V/√Hz) |
| `V(component)` | Noise contribution from specific component (V/√Hz) |

### Measurement Operations

| Operation | Description |
|-----------|-------------|
| `FIND ... AT freq` | Find noise value at specific frequency |
| `INTEG ... FROM f1 TO f2` | Integrate noise over frequency range to get RMS value (V_rms) |
| `MAX` | Find maximum noise value |
| `WHEN condition` | Find frequency when condition is met |
| `PARAM {expr}` | Calculate parameter from measured values |

**Best Practices:**
- Noise spectral density is in V/√Hz units
- Integrated noise (using `INTEG`) returns V_rms
- Use `V(component)` to measure individual component noise contributions
- For parametric sweeps with `.STEP`, use `.meas NOISE param_name PARAM {parameter}` to record the stepped value

---

## Noise Analysis .MEAS Examples

1. [Noise Density Comparison at Multiple Frequencies](#noise-density-comparison-at-multiple-frequencies)
2. [Component Noise Contribution](#component-noise-contribution)
3. [Find Peak Noise Frequency](#find-peak-noise-frequency)
4. [Integrated Noise Over Bandwidth](#integrated-noise-over-bandwidth)
5. [1/f Corner Frequency](#1f-corner-frequency)
6. [Parametric Sweep of Resistor Value](#parametric-sweep-of-resistor-value)
7. [Inverting Op-Amp with Resistor Noise Contributions](#inverting-op-amp-with-resistor-noise-contributions)

---

### Noise Density Comparison at Multiple Frequencies

**Complete netlist:**
```spice
* RC Low-Pass Filter - Noise at Multiple Frequencies
V1 in 0 AC 1
R1 in out 10k
C1 out 0 159nF

.noise V(out) V1 dec 100 1 1Meg

.meas NOISE noise_1Hz FIND V(onoise) AT 1Hz
.meas NOISE noise_1kHz FIND V(onoise) AT 1kHz
.meas NOISE noise_10kHz FIND V(onoise) AT 10kHz
.meas NOISE ratio_1kHz_to_10kHz PARAM {noise_1kHz/noise_10kHz}

.end
```

**Expected output (SPICE Output Log):**
```
noise_1hz: V(onoise) =1.28741728389e-08 at 1
noise_1khz: V(onoise) =1.28232802155e-09 at 1000
noise_10khz: V(onoise) =1.28867166937e-10 at 10000
ratio_1khz_to_10khz: {noise_1kHz/noise_10kHz}=9.95077374649
```

**Notes:**
- Resistor thermal noise: V_n = √(4kTR) ≈ 12.87 nV/√Hz for R=10k at 300K
- H(f) = 1/(1 + j·2πfRC), where f_c = 1/(2πRC) ≈ 100 Hz
- Output noise: V(onoise) = V_n × |H(f)|
- At f << f_c: full noise passes; at f >> f_c: -20 dB/decade rolloff
- Noise spectral density in V/√Hz units

---

### Component Noise Contribution

**Complete netlist:**
```spice
* RC Low-Pass Filter - Component Noise Contributions
V1 in 0 AC 1
R1 in mid 1k
R2 mid out 9k
C1 out 0 159nF

.noise V(out) V1 dec 100 1 1Meg

.meas NOISE R1_noise FIND V(R1) AT 1Hz
.meas NOISE R2_noise FIND V(R2) AT 1Hz
.meas NOISE total_noise FIND V(onoise) AT 1Hz

.end
```

**Expected output (SPICE Output Log):**
```
r1_noise: V(R1) =4.07117095591e-09 at 1
r2_noise: V(R2) =1.22135128677e-08 at 1
total_noise: V(onoise) =1.28741728389e-08 at 1
```

**Notes:**
- Individual component noise contributions can be measured separately
- Thermal noise scales as √R: R2 (9k) generates 3× more noise than R1 (1k) since √9 = 3
- Uncorrelated noise sources add via root sum squared: √(V_R1² + V_R2²) = √(4kT·(R1+R2)) = 10k equivalent
- Total noise (12.87 nV/√Hz) matches a single 10k resistor, confirming √((4.07)² + (12.2)²) ≈ 12.87 nV/√Hz

---

### Find Peak Noise Frequency

**Complete netlist:**
```spice
* RLC Bandpass Filter - Peak Noise Frequency
V1 in 0 AC 1
R1 in out 100
L1 out 0 10m
C1 out 0 253n

.noise V(out) V1 dec 100 10 100k

.meas NOISE max_output_noise MAX V(onoise)
.meas NOISE freq_at_peak WHEN V(onoise)=max_output_noise

.end
```

**Expected output (SPICE Output Log):**
```
max_output_noise: MAX(V(onoise))=1.28747801309e-09 FROM 10 TO 100000
freq_at_peak: V(onoise)=max_output_noise AT 3162.27766017
```

**Notes:**
- Parallel LC circuit creates resonance at center frequency
- Noise peaks at resonant frequency where impedance is maximum
- Peak noise equals R1 thermal noise: √(4kTR) = √(4 × 1.38×10⁻²³ × 300 × 100) ≈ 1.287 nV/√Hz
- Center frequency: f₀ = 1/(2π√(LC)) = 1/(2π√(10m × 253n)) ≈ 3162 Hz

---

### Integrated Noise Over Bandwidth

**Complete netlist:**
```spice
* RC Low-Pass Filter - Integrated Noise Over Bandwidth
V1 in 0 AC 1
R1 in out 1k
C1 out 0 159nF

.noise V(out) V1 dec 100 10 100k

.meas NOISE integrated_noise INTEG V(onoise) FROM 10 TO 100k

.end
```

**Expected output (SPICE Output Log):**
```
integrated_noise: INTEG(V(onoise) )=1.60413860951e-07 FROM 10 TO 100000
```

**Notes:**
- INTEG calculates total RMS noise over specified bandwidth
- Result is in V_rms, not V/√Hz
- RC filter limits the noise bandwidth, reducing total integrated noise

---

### 1/f Corner Frequency

**Complete netlist:**
```spice
* MOSFET Amplifier - 1/f Corner Frequency
V1 in 0 AC 1
Vin gate 0 DC 2
M1 out gate 0 0 NMOS W=10u L=1u
Rd vdd out 10k
Vdd vdd 0 DC 5

.model NMOS NMOS (KP=200u VTO=0.7 LAMBDA=0.01 KF=1e-25 AF=1)

.noise V(out) V1 dec 100 1 100Meg

.meas NOISE noise_at_1Hz FIND V(onoise) AT 1Hz
.meas NOISE white_noise_floor FIND V(onoise) AT 100Meg
.meas NOISE corner_freq PARAM square({noise_at_1Hz/white_noise_floor})
.meas NOISE corner_freq2 WHEN V(onoise)={white_noise_floor*sqrt(2)} CROSS=1

.end
```

**Expected output (SPICE Output Log):**
```
noise_at_1hz: V(onoise) =9.31752538236e-07 at 1
white_noise_floor: V(onoise) =1.0712658538e-09 at 100000000
corner_freq: square({noise_at_1Hz/white_noise_floor})=756496.015133
corner_freq2: V(onoise)={white_noise_floor*sqrt(2)}  AT 750901.087711
```

**Notes:**
- 1/f noise dominates at low frequencies in MOSFETs
- KF and AF model parameters define flicker noise
- **Method 1 (PARAM)**: Uses 1/f decay at -10 dB/decade (voltage). Since V(onoise) ∝ 1/√f, then f_c = (V_1Hz/V_floor)²
- **Method 2 (RSS)**: Finds frequency where total noise = √2 × white noise floor. At corner frequency, 1/f noise equals white noise, so RSS = √(V_white² + V_white²) = √2 × V_white
- Both methods give corner frequency ≈ 750 kHz where 1/f noise equals the white noise floor

---

### Parametric Sweep of Resistor Value

**Complete netlist:**
```spice
* RC Low-Pass Filter - Parametric Sweep of R1
V1 in 0 AC 1
R1 in out {Rval}
C1 out 0 159nF

.step param Rval list 1k 5k 10k

.noise V(out) V1 dec 100 1 100k

.meas NOISE r_value PARAM Rval
.meas NOISE noise_1Hz FIND V(onoise) AT 1Hz
.meas NOISE integrated_noise INTEG V(onoise)

.end
```

**Expected output (SPICE Output Log):**
```
Measurement: r_value
  step	Rval
     1	1000
     2	5000
     3	10000

Measurement: noise_1hz
  step	V(onoise) 	at
     1	4.07137212832e-09	1
     2	9.1037559713e-09	1
     3	1.28741728389e-08	1

Measurement: integrated_noise
  step	INTEG(V(onoise))	FROM	TO
     1	1.60878171491e-07	1	100000
     2	1.61084970228e-07	1	100000
     3	1.6087915769e-07	1	100000
```

**Notes:**
- .STEP directive creates multiple simulation runs
- PARAM measurement records the swept parameter value
- Thermal noise density for 1k resistor: √(4kTR) = √(4 × 1.38×10⁻²³ × 300 × 1000) ≈ 4.07 nV/√Hz
- Noise at 1Hz scales as √R: doubling from 1k→5k→10k increases noise by √5 and √10
- Cutoff frequency f_c = 1/(2πRC) changes with R1: higher R → lower f_c → more filtering
- kT/C noise: √(kT/C) = √(1.38×10⁻²³ × 300 / 159×10⁻⁹) ≈ 161 nV_rms
- Integrated noise equals kT/C noise (~161 nV_rms) regardless of R value - R cancels in the integration
- **kT/C derivation**: Integrating thermal noise V_n = √(4kTR) through RC filter with f_c = 1/(2πRC) gives V_rms² = ∫₀^∞ 4kTR/(1+(f/f_c)²) df = 4kTR × (π/2)/(2πRC) = kT/C, therefore V_rms = √(kT/C)


---

### Inverting Op-Amp with Resistor Noise Contributions

**Complete netlist:**
```spice
* Inverting Op-Amp - Noise Contributions

V1 NONINV 0 SINE(0 1 10K)
R1 INV 0 10K
R2 OUT INV 10K

Vdd vdd 0 DC 15
Vss vss 0 DC -15

XU1 NONINV INV vdd vss OUT level2 Avol=1Meg GBW=10Meg Slew=10Meg Ilimit=25m Rail=0 Vos=0 En=7.3n Enk=100 In=0 Ink=0 Rin=500Meg

.lib UniversalOpAmp2.lib

.noise V(out) V1 dec 100 1 1Meg

.meas NOISE total_noise_density FIND V(onoise) AT 1Meg
.meas NOISE R1_noise_density FIND V(R1) AT 1Meg
.meas NOISE R2_noise_density FIND V(R2) AT 1Meg
.meas NOISE low_freq_noise_density FIND V(onoise) AT 1

.end
```

**Expected output (SPICE Output Log):**
```
total_noise_density: V(onoise) =2.28844356798e-08 at 1000000
r1_noise_density: V(R1) =1.2624076895e-08 at 1000000
r2_noise_density: V(R2) =1.2624076895e-08 at 1000000
low_freq_noise_density: V(onoise) =1.47854748889e-07 at 1
```

**Notes:**
- Unity-gain inverting amplifier (R2/R1 = 10k/10k = 1)
- Op-amp configured with explicit parameters: En=7.3n (voltage noise), Enk=100 (1/f noise corner)
- **Noise gain**: For inverting amplifier, noise gain = 1 + R2/R1 = 1 + 1 = 2 (different from signal gain of -1)
- **At 1 MHz (white noise)**:
  - Each 10k resistor: √(4kTR) = √(4 × 1.38×10⁻²³ × 300 × 10k) ≈ 12.87 nV/√Hz → 12.62 nV/√Hz at output
  - Op-amp noise at output: En × (noise gain) = 7.3 × 2 = 14.6 nV/√Hz
  - Total noise (RSS): √(12.62² + 12.62² + 14.6²) ≈ 22.9 nV/√Hz ✓
- **At 1 Hz**: 1/f noise dominates with corner at Enk = 100 Hz, increasing total noise to ~148 nV/√Hz
- All noise sources are referred to output

---

