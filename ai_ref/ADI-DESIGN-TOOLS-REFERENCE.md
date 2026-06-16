[← AI Reference](README.md)

# ADI Design Tools — LTspice Export Reference

Analog Devices provides a suite of specialized design tools intended to accelerate your path to simulation. Use these tools upstream of LTspice to quickly explore component selection, evaluate performance trade-offs, and generate a starting schematic — then export directly to LTspice schematic files for full circuit verification.

---

## Table of Contents

1. [Signal Chain Designer](#signal-chain-designer)
2. [Analog Filter Wizard](#analog-filter-wizard)
3. [Analog Photodiode Wizard](#analog-photodiode-wizard)
4. [Precision ADC Driver Tool](#precision-adc-driver-tool)
5. [LTpowerCAD](#ltpowercad)

---

## Signal Chain Designer

**URL:** https://tools.analog.com/en/signalchaindesigner/

Signal Chain Designer is a web-based platform for building and simulating precision signal chains. It lets you assemble a chain of ADI precision components — amplifiers, ADCs, DACs, references, and other signal-path devices — evaluate system-level performance, and export a set of LTspice schematics for further verification.

### Workflow

1. **Build** — Select and connect ADI precision components (amplifiers, ADCs, DACs, voltage references, etc.) to form the signal chain.
2. **Simulate** — Evaluate system-level performance metrics within the tool:
   - Transfer functions
   - Noise performance
   - Power consumption
   - Input/output ranges
   - DC errors
3. **Export** — Export the complete signal chain to LTspice for full transient, AC, or noise simulation.

### Exporting to LTspice

Download using the **LTspice Simulation Files** button within the tool. The export produces LTspice schematics containing the selected components with ADI SPICE models pre-wired according to the signal chain topology.

| Schematic | Simulation type | Verification goal |
|-----------|----------------|-------------------|
| AC | `.ac` | Frequency response / bandwidth |
| Noise | `.noise` | Noise analysis |
| Transient | `.tran` | Time-domain transient behavior |

### Notes

- Signal Chain Designer is part of ADI's **Precision Studio** suite.
- The export is a `.zip` file containing multiple schematics — unzip it first, then open the schematic that matches your intended simulation type.
- Component models in the exported schematic are ADI-supplied SPICE models; do not substitute generic op-amp models without verifying pin compatibility.


---

## Analog Filter Wizard

**URL:** https://tools.analog.com/en/filterwizard/

The Analog Filter Wizard is a web-based tool for designing active filters using real ADI op-amp models. It walks you from ideal filter specifications through real-world circuit behavior, accounting for op-amp non-idealities, and exports a complete implementation to LTspice for further simulation.

### Supported Filter Types

- Low-pass
- High-pass
- Band-pass

### Workflow

1. **Specify** — Enter filter requirements: type (LP/HP/BP), frequency, and attenuation targets.
2. **Evaluate** — The wizard shows how the design transitions from ideal theoretical response to real-world behavior driven by the selected op-amp's characteristics.
3. **Analyze trade-offs** — Examine the impact of op-amp specifications on filter performance:
   - Gain-bandwidth product
   - Output-referred noise
   - Input and output swing limitations
   - Quiescent supply current requirements
   - Frequency response plots
4. **Export** — Export the complete filter schematic to LTspice for full simulation and verification.

### Exporting to LTspice

Use the **All Files** or **SPICE Only** button on the Next Steps tab within the tool. The export produces a `.zip` file containing multiple LTspice schematics with the filter topology, component values, and real ADI op-amp models pre-wired. Open the schematic that matches your intended simulation type.

| Schematic | Simulation type | Verification goal |
|-----------|----------------|-------------------|
| AC | `.ac` | Frequency response |
| Noise | `.noise` | Noise analysis |
| Transient | `.tran` | Time-domain transient behavior |

### Notes

- The export is a `.zip` file — unzip it before opening in LTspice.
- The exported schematics are hierarchical: a top-level schematic references filter stage blocks. Double-click a stage block on the top-level schematic to navigate into it and inspect or modify the individual stage circuitry.
- Op-amp models in the exported schematic are ADI-supplied SPICE models selected by the wizard; substituting a different op-amp requires verifying pin compatibility and updating the model reference.
- Use an `.ac` simulation in LTspice to verify frequency response against the wizard's predicted plots.
- Use a `.tran` simulation to check time-domain behavior and slew-rate effects not captured in AC analysis.

---

## Analog Photodiode Wizard

**URL:** https://tools.analog.com/en/photodiode/

The Analog Photodiode Wizard provides a structured workflow for designing transimpedance amplifier (TIA) circuits for photodiode interfaces. It lets you select a photodiode, configure TIA component values, evaluate key performance trade-offs through detailed plots, and export the complete circuit to LTspice for full simulation.

### Workflow

1. **Select photodiode** — Choose from the built-in device library, or enter custom parameters:
   - Photodiode capacitance
   - Shunt resistance
   - Peak current
2. **Evaluate** — The wizard immediately computes key performance trade-offs:
   - Closed-loop bandwidth
   - Peaking (Q-factor)
   - ENOB (Effective Number of Bits)
   - SNR (Signal-to-Noise Ratio)
3. **Analyze** — Review detailed plots to guide component selection:
   - Pulse response
   - Frequency response
   - Noise-gain characteristics
4. **Adjust** — Modify TIA component values and observe updated plots in real time.
5. **Export** — Export the complete TIA schematic to LTspice for comprehensive validation.

### Exporting to LTspice

Use the **All Files** or **SPICE Only** button on the Next Steps tab within the tool. The export produces a `.zip` file containing three LTspice schematics, each configured for a specific simulation:

| Schematic | Simulation type | Verification goal |
|-----------|----------------|-------------------|
| Transient | `.tran` | Pulse response behavior |
| AC | `.ac` | Closed-loop bandwidth and peaking |
| Noise | `.noise` | Noise-gain characteristics |

### Notes

- The export is a `.zip` file — unzip it before opening in LTspice.

---

## Precision ADC Driver Tool

**URL:** https://tools.analog.com/en/adcdriver

The Precision ADC Driver Tool enables detailed simulation of precision ADC-and-driver signal chains. It evaluates architectural and component-level trade-offs using actual device parameters, helping designers identify potential issues with amplifier selection, ADC input-kickback settling, and distortion before moving to full SPICE simulation.

### Workflow

1. **Select components** — Choose the ADC and driver amplifier from ADI's precision device portfolio.
2. **Evaluate trade-offs** — The tool computes system-level performance metrics based on actual device parameters:
   - System-level noise
   - Harmonic distortion
   - Time-domain settling behavior at the ADC input
3. **Identify issues** — Assess potential problems related to:
   - Amplifier selection
   - Input-kickback settling
   - Distortion mechanisms
4. **Export** — Export the complete driver-ADC configuration to LTspice for further simulation and verification.

### Exporting to LTspice

Use the **Download LTspice Simulation** button in the Next Steps tab within the tool. The export produces three LTspice schematics, each configured for a specific simulation:

| Schematic | Simulation type | Verification goal |
|-----------|----------------|-------------------|
| Kickback | `.tran` | ADC input-kickback settling behavior |
| Operating Range | `.tran` | Driver and ADC operating range |
| Noise | `.noise` | System-level noise |

### Notes

- The export is a `.zip` file — unzip it before opening in LTspice.
- Exported schematics use **templated models** for the ADC and amplifier to ensure all designs are immediately simulatable in LTspice.
- Templated models can be replaced with the corresponding ADI macromodels available in the LTspice component library for higher-fidelity simulation with device-specific behavior.

---

## LTpowerCAD

**URL:** https://www.analog.com/en/lp/ltpowercad.html

LTpowerCAD is a complete power supply design tool that guides users through the full regulator design process. It recommends component values and performance estimates specific to the application, displays real-time feedback loop and power stage results, and exports the completed design to LTspice for full time-domain simulation and verification.

LTpowerCAD includes **LTpowerPlanner**, a system-level power architecture design tool for planning complex power trees before diving into individual regulator designs.

### LTpowerPlanner — System-Level Power Tree Planning

LTpowerPlanner is the starting point for multi-rail power system design. It operates at the architecture level, above individual regulator design:

1. **Build** — Create an interactive block diagram defining voltage rails and load currents.
2. **Discover** — Find pre-validated power-tree solutions from ADI's portfolio.
3. **Compare** — Evaluate alternative architectures side by side with real-time calculations.
4. **Refine** — Select components and finalize the power tree before moving into LTpowerCAD for per-regulator design.

### LTpowerCAD — Regulator Design Workflow

LTpowerCAD guides individual regulator design in five steps:

1. **Search** — Specify supply requirements (input voltage, output voltage, output current); the tool suggests suitable ADI regulator ICs.
2. **Design** — Configure component values; the tool provides recommendations and warnings for component selection.
3. **Analyze** — Review real-time performance results:
   - Efficiency calculations
   - Feedback loop Bode plot (gain and phase margin)
   - Power stage performance
   - Transient response
4. **Summarize** — Generate a detailed design summary.
5. **Export** — Export the design to LTspice for full time-domain simulation.

### Exporting to LTspice

Use the **LTspice** button on the schematic page within LTpowerCAD. The export produces a single `.asc` file that opens directly in LTspice, with the regulator model and surrounding components pre-wired.

### Notes

- LTpowerCAD is a Windows desktop application — download and install it from the URL above before use.
- LTpowerPlanner is included in the LTpowerCAD installation; no separate download is required.
- Use a `.tran` simulation in LTspice to verify time-domain switching behavior, output ripple, and transient load response.

---

*See also: [DEVICE-MODELS-GUIDE.md](DEVICE-MODELS-GUIDE.md) for working with ADI SPICE models in LTspice, [SIMULATION-COMMANDS-REFERENCE.md](SIMULATION-COMMANDS-REFERENCE.md) for simulation command syntax*
