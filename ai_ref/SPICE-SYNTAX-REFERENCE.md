[← AI Reference](README.md)

# SPICE Netlist Syntax Reference

Complete reference for LTspice netlist structure, conventions, and syntax rules.

---

## Netlist Structure

A netlist is a plain-text file describing the circuit to be analyzed.

- **First line**: Always treated as a comment (title line)
- **Last line**: Usually `.END` (can be omitted; anything after `.END` is ignored)
- **Line order**: Between the title and `.END`, line order is irrelevant
- **File extensions**: `.cir` (standard), `.net`, `.sp`

### Example Netlist

```spice
* RC Circuit driven with a 1MHz square wave
R1 n1 n2 1K        ; 1K resistor between nodes n1 and n2
C1 n2 0 100p       ; 100pF capacitor between n2 and ground
V1 n1 0 PULSE(0 1 0 0 0 .5u 1u)  ; 1MHz square wave
.tran 3u           ; 3us transient analysis
.end
```

---

## Text Encoding

LTspice accepts three encodings:

| Encoding | Notes |
|----------|-------|
| UTF-8 | Recommended. Used exclusively by the built-in netlister |
| UTF-16 LE | Little-endian, with or without BOM |
| Latin-1 (ISO 8859-1) | Assumed only if file contains byte sequences invalid for UTF-8 |

LTspice conforms to Unicode standard version 14. Text comparison uses canonical equivalence and Unicode case folding for case insensitivity. The parser is based on grapheme clusters.

---

## Comments and Line Continuation

| Syntax | Meaning |
|--------|---------|
| `*` at line start | Entire line is a comment |
| `;` anywhere in line | Rest of line is a comment |
| `+` at line start | Continuation of previous line (the `+` is removed and remainder appended) |

### Special Netlister Comments

The LTspice netlister may append machine-readable comments that begin with `;§`. These are ordinary comments (ignored by the simulator) but carry structural metadata:

- **`;§pnba`** on a subcircuit (`X`) instance line lists the symbol's pin names, delimited by `)`, in the same order as the net assignments. See [CIRCUIT-ELEMENTS-REFERENCE.md](CIRCUIT-ELEMENTS-REFERENCE.md#x--subcircuit) for details and an example.

---

## Line Types by Leading Character

The first non-blank character of a line defines what it represents:

| Character | Element Type |
|-----------|-------------|
| `*` | Comment |
| `A` | Special function device |
| `B` | Arbitrary behavioral source |
| `C` | Capacitor |
| `D` | Diode |
| `E` | Voltage-dependent voltage source |
| `F` | Current-dependent current source |
| `G` | Voltage-dependent current source |
| `H` | Current-dependent voltage source |
| `I` | Independent current source |
| `J` | JFET transistor |
| `K` | Mutual inductance |
| `L` | Inductor |
| `M` | MOSFET transistor |
| `O` | Lossy transmission line |
| `Q` | Bipolar transistor |
| `R` | Resistor |
| `S` | Voltage-controlled switch |
| `T` | Lossless transmission line |
| `U` | Uniform RC-line |
| `V` | Independent voltage source |
| `W` | Current-controlled switch |
| `X` | Subcircuit invocation |
| `Z` | MESFET or IGBT transistor |
| `@` | Frequency Response Analyzer |
| `&` | Frequency Response Analysis Probe |
| `.` | Simulation directive (e.g., `.options reltol=1e-4`) |
| `+` | Line continuation |

---

## Engineering Multipliers

Numbers can use scientific notation (e.g., `1e12`) or engineering multipliers (e.g., `1K` for 1000):

| Suffix | Multiplier | Example |
|--------|-----------|---------|
| `T` | 1e12 | `1T` = 1,000,000,000,000 |
| `G` | 1e9 | `2.2G` = 2,200,000,000 |
| `Meg` | 1e6 | `1Meg` = 1,000,000 |
| `K` | 1e3 | `4.7K` = 4,700 |
| `mil` | 25.4e-6 | `1mil` = 25.4e-6 |
| `m` | 1e-3 | `10m` = 0.01 |
| `u` | 1e-6 | `100u` = 0.0001 |
| `n` | 1e-9 | `47n` = 47e-9 |
| `p` | 1e-12 | `100p` = 100e-12 |
| `f` | 1e-15 | `1f` = 1e-15 |

### Important Rules

- **Suffixes are case-insensitive** (except `Meg` vs `m` — see warning below)
- **Unrecognized letters after a number are ignored**: `10V`, `10Volts`, `10Hz` all equal `10`
- **Common pitfall**: `1M` means 1 milliohm (1e-3), NOT 1 megaohm. Use `1Meg` for megaohms.
- **Embedded decimal**: `6K34` means `6.34K` (works for all multipliers)
- **No unit suffixes needed**: Just the number and multiplier (e.g., `100p` not `100pF`)
- **Use `.options reject_number_tails`** to make LTspice report unrecognized trailing letters as syntax errors

### Pitfall Example

```spice
C23 N1 N2 4Farads
```

This creates a **4 femtofarad** capacitor (the `F` is parsed as the femto multiplier, `arads` is ignored). Always use just the number and multiplier: `C23 N1 N2 4`.

---

## Node Naming

- Node names are arbitrary character strings
- **Case-insensitive** (via Unicode case folding)
- Node `0` is the global circuit common (ground)
- `GND` is a special synonym for `0`
- `0` and `00` are distinct nodes (string comparison, not numeric)
- Can use alphanumeric characters and underscores
- Avoid spaces in node names

---

## Creating and Running Netlists

### Creating a Netlist

- Use any text editor that produces ASCII or UTF-8 encoded files
- In LTspice: **View > SPICE Netlist** shows the netlist for the current schematic
- Copy to clipboard: Select all text, then Ctrl+C

### Running a Netlist

- Open the `.cir` file in LTspice and run it
- Command line: `ltspice.exe "C:\path\to\circuit.cir"`

---

## Externally Generated Netlists

LTspice can open netlists from other schematic capture programs or hand-written netlists.

- Accepted extensions: `.cir`, `.net`, `.sp`
- The built-in text editor colorizes SPICE syntax
- Adjust editor colors: **Tools > Color Preferences**
- Unicode is fully supported

---

## Netlist Options

These options control how LTspice generates netlists from schematics:

| Option | Description |
|--------|-------------|
| Convert 'µ' to 'u' | Replace all 'µ' instances with 'u' for compatibility with simulators that don't support the µ character as 1e-6 |
| Reverse comp. order | Netlist elements in reverse order from how they were added to schematic |
| Default Devices | Include default model statements (e.g., `.model D D`) to suppress missing-model messages |
| Default Libraries | Auto-include standard and user component libraries for all component types used |

### Library Paths

- Standard library: `%LOCALAPPDATA%\LTspice\lib\cmp\standard.dio` (and similar for BJT, MOSFET, JFET)
- User library: `Documents/LTspice/user.dio` (configurable in Search Paths tab)

---

## Notation Conventions Used in This Documentation

| Symbol | Meaning |
|--------|---------|
| `<name>` | Required data field to be filled with specific information |
| `[optional]` | Enclosed field is optional |
| `a \| b` | Alternatives — either `a` or `b` |

---

*See also: [CIRCUIT-ELEMENTS-REFERENCE.md](CIRCUIT-ELEMENTS-REFERENCE.md) for component syntax, [SIMULATION-COMMANDS-REFERENCE.md](SIMULATION-COMMANDS-REFERENCE.md) for dot commands*
