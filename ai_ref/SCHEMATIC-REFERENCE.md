---
title: LTspice Schematic Design and Modification Guide
description: The .asc file format, schematic editing, symbols, and hierarchy — including Windows-1252 encoding caveats.
version: "24+"
---

[← AI Reference](README.md)

# LTspice Schematic Design and Modification Guide

This guide documents the `.asc` schematic file format used by LTspice, based on observation of example schematics shipped with the application.

---

## Table of Contents

1. [ASC File Format Overview](#asc-file-format-overview)
   - [File Encoding — Critical](#file-encoding--critical)
2. [Coordinate System and Grid](#coordinate-system-and-grid)
3. [Wires](#wires)
4. [Net Labels (Flags)](#net-labels-flags)
5. [Components (Symbols)](#components-symbols)
6. [Component Attributes](#component-attributes)
7. [Text and SPICE Directives](#text-and-spice-directives)
8. [Graphic Elements](#graphic-elements)
9. [Rotation and Mirroring](#rotation-and-mirroring)
10. [I/O Pins (Hierarchical Designs)](#io-pins-hierarchical-designs)
11. [Common SPICE Analysis Commands](#common-spice-analysis-commands)
12. [Design Best Practices](#design-best-practices)
13. [Example Walkthrough](#example-walkthrough)
---

## ASC File Format Overview

An `.asc` file is a plain-text file describing an LTspice schematic. The first line declares the format version:

```
Version 4
```

The second line defines the sheet number and drawing area (width x height):

```
SHEET 1 2580 1252
```

The remainder consists of element declarations using these keywords:

| Keyword     | Description                                      |
|-------------|--------------------------------------------------|
| `WIRE`      | A wire segment connecting two points             |
| `FLAG`      | A net label (named node) at a location           |
| `SYMBOL`    | A component instance placed on the schematic     |
| `SYMATTR`   | An attribute of the preceding SYMBOL             |
| `WINDOW`    | A text display window for a SYMBOL attribute     |
| `TEXT`      | Free-form text or a SPICE directive              |
| `LINE`      | A graphic line (non-electrical)                  |
| `RECTANGLE` | A graphic rectangle                              |
| `CIRCLE`    | A graphic circle/ellipse                         |
| `ARC`       | A graphic arc                                    |
| `IOPIN`     | An I/O pin for hierarchical designs              |

### File Encoding — Critical

`.asc` files use **Windows-1252 (Latin-1) encoding**, not UTF-8. The micro prefix character `µ` is stored as the single byte `0xB5`. This appears in component values like `2.2µ` (2.2 microhenries) or `22µ` (22 microfarads).

**When editing `.asc` files programmatically:**
- The file MUST be read and written as raw bytes or using Windows-1252 encoding.
- Do NOT re-encode the file as UTF-8. This corrupts `0xB5` (µ) into the 3-byte UTF-8 replacement character `EF BF BD` (U+FFFD), which LTspice cannot parse.
- If your editor or tool only supports UTF-8, replace `µ` with the letter `u` in component values (e.g., `2.2u` instead of `2.2µ`). LTspice treats `u` as the micro multiplier in netlist values.
- Other non-ASCII bytes that may appear: `0xB0` (°) in temperature values, `0xB2` (²) in annotations.

**Do NOT edit .asc files with `replace_string_in_file`, `multi_replace_string_in_file`, `create_file`, or any other text tool that assumes UTF-8 encoding. These tools WILL corrupt µ (0xB5) and other Windows-1252 characters.** Use a Python script with `encoding='latin-1'` to make modifications, or re-copy the original and apply changes programmatically.

**Safe editing approach:** When modifying `.asc` files, read the file as a byte array, perform targeted byte-level replacements only in the lines being changed (using ASCII for new content), and write the byte array back unchanged otherwise. Never pass the entire file through a UTF-8 encode/decode round-trip.

---

## Coordinate System and Grid

- Coordinates are integers in schematic units (typically multiples of 16).
- The default grid spacing is 16 units.
- Positive X is rightward; positive Y is downward.
- Component pins and wire endpoints should align to the grid for proper connectivity.
- Wire endpoints must exactly match component pin world-coordinates for a connection to be made.

### Pin World-Coordinate Calculation

A `SYMBOL` placed at `(sx, sy)` has pin world-coordinates determined by applying the rotation transform to each pin's local offset `(px, py)` from the `.asy` file:

| Rotation | world_x | world_y |
|----------|---------|---------|
| R0 | sx + px | sy + py |
| R90 | sx - py | sy + px |
| R180 | sx - px | sy - py |
| R270 | sx + py | sy - px |

For mirror orientations (M0, M90, M180, M270), first negate px (flip horizontally), then apply the corresponding rotation formula above.

### Standard Symbol Pin Offsets (local coordinates from .asy files)

| Symbol | Pin 1 (name) | Pin 1 (px, py) | Pin 2 (name) | Pin 2 (px, py) | Pin 3 | Pin 3 (px, py) |
|--------|--------------|----------------|--------------|----------------|-------|----------------|
| `cap` | A (+) | (16, 0) | B (-) | (16, 64) | — | — |
| `res` | A | (16, 16) | B | (16, 96) | — | — |
| `ind` | A | (16, 16) | B | (16, 96) | — | — |
| `voltage` | + | (0, 16) | - | (0, 96) | — | — |
| `current` | + | (0, 0) | - | (0, 80) | — | — |
| `diode` | + (anode) | (16, 0) | - (cathode) | (16, 64) | — | — |
| `npn` | C | (64, 0) | B | (0, 48) | E | (64, 96) |
| `nmos` | D | (48, 0) | G | (0, 80) | S | (48, 96) |
| `sw` | A | (0, 16) | B | (0, 96) | NC+ | (-48, 80) |

### Rotation Examples

**Resistor in R90** (horizontal): `SYMBOL res 48 96 R90`
- Pin A: (48 - 16, 96 + 16) = **(32, 112)** — right side
- Pin B: (48 - 96, 96 + 16) = **(-48, 112)** — left side

**Voltage source in R0** (vertical): `SYMBOL voltage -48 96 R0`
- Pin +: (-48 + 0, 96 + 16) = **(-48, 112)** — top
- Pin -: (-48 + 0, 96 + 96) = **(-48, 192)** — bottom

**Capacitor in R0** (vertical): `SYMBOL cap 96 112 R0`
- Pin A: (96 + 16, 112 + 0) = **(112, 112)** — top
- Pin B: (96 + 16, 112 + 64) = **(112, 176)** — bottom

### Complete Example: RC Low-Pass Filter

```
Version 4.1
SHEET 1 880 340
WIRE -32 96 -48 96
WIRE 16 96 -32 96
WIRE 128 96 96 96
WIRE 144 96 128 96
WIRE -48 112 -48 96
WIRE 144 112 144 96
WIRE -48 208 -48 192
WIRE 144 208 144 176
FLAG -48 208 0
FLAG 144 208 0
FLAG -32 96 in
FLAG 128 96 out
SYMBOL voltage -48 96 R0
SYMATTR InstName V1
SYMATTR Value AC 1
SYMBOL cap 128 112 R0
SYMATTR InstName C1
SYMATTR Value 100n
SYMBOL res 112 80 R90
WINDOW 0 0 56 VBottom 2
WINDOW 3 32 56 VTop 2
SYMATTR InstName R1
SYMATTR Value 1k
TEXT -48 256 Left 2 !.ac dec 100 1 10Meg
```

**Connection verification**:
- V1 pin+ at (-48, 112) = R1 pin B at (-48, 112) → directly connected
- R1 pin A at (32, 112) → wire endpoint of both `WIRE 32 112 -48 112` and `WIRE 112 112 32 112`
- C1 pin A at (112, 112) → wire endpoint of `WIRE 112 112 32 112`
- V1 pin- at (-48, 192) → wire endpoint of `WIRE -48 208 -48 192`
- C1 pin B at (112, 176) → wire endpoint of `WIRE 112 208 112 176`
- Ground flags at wire endpoints (-48, 208) and (112, 208)

### Caution: AI-Generated Schematic Modifications

Creating or modifying `.asc` schematics that involve placing components or routing wires is inherently error-prone for AI assistants. The coordinate math, rotation transforms, and wire connectivity rules make it very easy to produce schematics with misaligned pins, overlapping symbols, or broken connections. If a user asks to create a schematic or make changes that require moving components or rewiring, **warn them that the result may need manual correction in LTspice** and suggest they verify connectivity after opening the file.

Changes that only modify SYMATTR values (e.g., changing a component value or model name) or TEXT directives (e.g., changing `.tran 1m` to `.tran 5m`) are usually safe and reliable.

### Layout Guidelines for AI-Generated Schematics

1. **Compute pin world-coordinates first**: Before placing a symbol, calculate where its pins will land using the rotation formulas above.
2. **Verify connections**: Every intended connection must have matching coordinates — either two pins at the same point, or pins at wire endpoints.
3. **Avoid overlaps**: Ensure symbol bodies do not overlap. A `res` in R90 spans 80 units horizontally; a `voltage` in R0 spans 80 units vertically.
4. **Use wires for gaps**: If two connected pins are not at the same point, add a `WIRE` line connecting them.
5. **Ground flags need wire endpoints**: Every `FLAG` must be placed at a wire endpoint or at a point that coincides with a component pin.
6. **Keep components on the 16-unit grid**: Choose symbol placement coordinates that result in all pin world-coordinates being multiples of 16.

---

## Wires

Wires represent electrical connections between two points.

### Syntax

```
WIRE x1 y1 x2 y2
```

### Rules

- Wires should be orthogonal (horizontal or vertical) for best results.
- Wires connect at their endpoints.
- When three or more wires meet at a single point, LTspice automatically creates a junction dot.
- Wire endpoints must exactly coincide with component pin locations to form connections.

### Example

```
WIRE 704 208 368 208
WIRE 832 208 784 208
```

---

## Net Labels (Flags)

Net labels assign a name to a node, making it accessible for probing and cross-referencing.

### Syntax

```
FLAG x y netname
```

### Special Names

- `0` - Ground reference (every circuit needs at least one)

### Examples

```
FLAG 368 608 0
FLAG 96 432 IN
FLAG 544 432 Vout
```
---

## Components (Symbols)

Components are instances of symbols placed on the schematic.

### Syntax

```
SYMBOL symbolName x y rotation
```

- `symbolName`: Name or path of the symbol (e.g., `voltage`, `res`, `cap`, `AD4000`)
- `x, y`: Placement coordinates (symbol origin)
- `rotation`: Orientation string (see [Rotation and Mirroring](#rotation-and-mirroring))

A `SYMBOL` line is typically followed by one or more `WINDOW` and `SYMATTR` lines.

### Example

```
SYMBOL voltage -48 432 R90
WINDOW 0 -32 56 VBottom 2
WINDOW 3 32 56 VTop 2
SYMATTR InstName V1
SYMATTR Value SINE(3 4 10k)
```

---

## Component Attributes

### SYMATTR

Sets an attribute value for the preceding component:

```
SYMATTR attributeName value
```

Common attribute names:

| Attribute    | Purpose                                  |
|--------------|------------------------------------------|
| `InstName`   | Instance/reference designator (e.g., R1, C2, U1) |
| `Value`      | Primary value (resistance, capacitance, source waveform, etc.) |
| `Value2`     | Secondary value                          |
| `SpiceLine`  | Additional SPICE netlist parameters      |
| `SpiceLine2` | Second line of extra SPICE parameters    |
| `Prefix`     | Netlist prefix character                 |
| `SpiceModel` | Model name                               |

### WINDOW

Controls where an attribute's text is displayed relative to the component:

```
WINDOW attrId xOffset yOffset justification fontSize
```

Common attribute IDs:

| ID  | Attribute   |
|-----|-------------|
| 0   | InstName    |
| 3   | Value       |
| 39  | SpiceLine   |
| 123 | Value2      |

Justification values: `Left`, `Right`, `Top`, `Bottom`, `Center`, `VLeft`, `VRight`, `VTop`, `VBottom`, `VCenter`

---

## Text and SPICE Directives

### Syntax

```
TEXT x y justification fontSize content
```

### Content Prefixes

- `!` - SPICE directive (executed during simulation)
- `;` - Comment (displayed on schematic but not executed)

### Examples

```
TEXT 184 624 Left 2 !.tran 110u
TEXT 100 700 Left 2 ;This is a comment
```

---

## Graphic Elements

Non-electrical drawing elements for annotation and documentation.

### LINE

```
LINE Normal x1 y1 x2 y2
```

### RECTANGLE

```
RECTANGLE Normal x1 y1 x2 y2
```

### CIRCLE

```
CIRCLE Normal x1 y1 x2 y2
```

(Defined by bounding box corners)

### ARC

```
ARC Normal x1 y1 x2 y2 x3 y3 x4 y4
```

(Bounding box + start/end points on the arc)
---

## Rotation and Mirroring

Components support 8 orientations:

| String | Meaning                                        |
|--------|------------------------------------------------|
| `R0`   | No rotation (default)                          |
| `R90`  | 90 degrees clockwise                           |
| `R180` | 180 degrees rotation                           |
| `R270` | 270 degrees clockwise (90 degrees CCW)         |
| `M0`   | Mirror horizontally                            |
| `M90`  | Mirror + 90 degrees rotation                   |
| `M180` | Mirror vertically                              |
| `M270` | Mirror + 270 degrees rotation                  |

---

## I/O Pins (Hierarchical Designs)

For hierarchical schematics (subcircuits used as blocks):

```
IOPIN x y direction
```

Direction values: `In`, `Out`, `BiDir`

I/O pins define the interface of a subcircuit schematic and correspond to pins on the parent symbol.

---

## Common SPICE Analysis Commands

Place these as `TEXT` elements with the `!` prefix. Only one analysis command (`.tran`, `.ac`, `.dc`, `.op`, `.noise`) can be active at a time — comment out any others with `;`.

| Command    | Purpose                  | Example                              |
|------------|--------------------------|--------------------------------------|
| `.tran`    | Transient analysis       | `!.tran 110u`                        |
| `.ac`      | AC (frequency) analysis  | `!.ac dec 100 1 1Meg`               |
| `.dc`      | DC sweep                 | `!.dc V1 0 5 0.01`                  |
| `.op`      | DC operating point       | `!.op`                               |
| `.step`    | Parameter sweep          | `!.step param R1 1k 10k 1k`         |
| `.param`   | Parameter definition     | `!.param Vcc=5`                      |
| `.lib`     | Include model library    | `!.lib filename.lib`                 |
| `.include` | Include file             | `!.include filename.inc`             |
| `.meas`    | Measurement              | `!.meas TRAN Vmax MAX V(out)`        |
| `.model`   | Model definition         | `!.model D1 D(Is=1e-14)`            |
| `.noise`   | Noise analysis           | `!.noise V(out) V1 dec 100 1 1Meg`  |
| `.four`    | Fourier analysis         | `!.four 1k V(out)`                   |

---

## Design Best Practices

1. **Always include a ground node**: Every circuit must have at least one `FLAG x y 0`.

2. **Name important nets**: Use descriptive flag names (`IN`, `Vout`, `VCC`) for nodes you want to probe or reference.

3. **Align to grid**: Place all components and wire endpoints on the 16-unit grid to ensure proper connectivity.

4. **Use orthogonal wires**: Keep wires horizontal or vertical for clean, readable schematics.

5. **One analysis command per simulation**: While multiple can exist, only the active (uncommented) analysis runs.

6. **Place analysis commands at the bottom**: Convention is to put `.tran`, `.ac`, etc. below the circuit.

7. **Verify connectivity**: Ensure wire endpoints touch component pins exactly. Misaligned connections are a common source of errors.

8. **Use hierarchical design for complex circuits**: Break large designs into subcircuit blocks with I/O pins.
---

## Example Walkthrough

Below is a minimal but complete LTspice schematic (a voltage source driving a resistor):

```
Version 4.1
SHEET 1 880 680
WIRE 304 176 112 176
WIRE 112 192 112 176
WIRE 304 192 304 176
FLAG 112 272 0
FLAG 304 272 0
FLAG 112 176 input
SYMBOL voltage 112 176 R0
SYMATTR InstName V1
SYMATTR Value SINE(0 1 1k)
SYMBOL res 288 176 R0
SYMATTR InstName R1
SYMATTR Value 1k
TEXT 64 312 Left 2 !.tran 10m
```

### Breakdown

1. **Version and Sheet**: Format version 4.1, sheet dimensions 880x680
2. **Wires**: Connect V1 positive terminal to R1 top terminal
3. **Ground flags**: Both V1 and R1 have their bottom terminals grounded
4. **Named net**: The connection point is labeled `input`
5. **Components**: A sine voltage source (V1) and a 1k ohm resistor (R1)
6. **Analysis**: 10ms transient simulation

---

## Creating a New Schematic - Checklist

- [ ] Start with `Version 4.1` and `SHEET 1 width height`
- [ ] Place wires to connect component pins (endpoints must align exactly)
- [ ] Add at least one ground flag (`FLAG x y 0`)
- [ ] Place all required symbols with proper rotation
- [ ] Set `SYMATTR InstName` for every component
- [ ] Set `SYMATTR Value` for components that need values
- [ ] Add at least one analysis command as a `TEXT` element with `!` prefix
- [ ] Verify all wire endpoints connect to pins (misalignment = open circuit)

---

## Modifying an Existing Schematic

### Common Edits (in a text editor)

| Task                    | What to Change                                                        |
|-------------------------|-----------------------------------------------------------------------|
| Change a component value | Edit `SYMATTR Value` line after the component                        |
| Rename a net            | Change the name in the `FLAG` line                                    |
| Change analysis         | Edit or replace the `TEXT ... !.command` line                         |
| Move a component        | Update x,y in the `SYMBOL` line and adjust connected `WIRE` endpoints |
| Add a component         | Insert `SYMBOL` + `SYMATTR` lines; add `WIRE` lines to connect       |
| Delete a component      | Remove the `SYMBOL`, `WINDOW`, and `SYMATTR` lines; remove orphaned wires |
| Rotate a component      | Change the rotation string (e.g., `R0` to `R90`) and adjust wires    |

### Important Notes

- After moving or rotating components, wire endpoints must be updated to match the new pin locations.
- LTspice recalculates connectivity each time a schematic is opened or simulated.
- Keep a backup before making bulk text-editor changes.

---

## Source Waveform Specifications

Common voltage/current source waveforms (used in `SYMATTR Value`):

| Waveform | Syntax                                    | Example                              |
|----------|-------------------------------------------|--------------------------------------|
| DC       | `value`                                   | `5`                                  |
| Sine     | `SINE(offset amplitude frequency)`        | `SINE(0 1 1k)`                       |
| Pulse    | `PULSE(V1 V2 Tdelay Trise Tfall Ton Period)` | `PULSE(0 1.8 227n 0.1n 0.1n 40n 500n)` |
| PWL      | `PWL(t1 v1 t2 v2 ...)`                   | `PWL(0 0 1m 1 2m 0)`                |
| AC       | `AC amplitude`                            | `AC 1`                               |

---

## Example Schematics Location

LTspice ships example schematics at:

```
%LOCALAPPDATA%\LTspice\examples\
```

### Subdirectories

| Directory      | Content                                         |
|----------------|-------------------------------------------------|
| `Applications` | Application circuits for ADI products           |
| `Educational`  | Tutorial and educational example circuits       |

These examples demonstrate proper schematic construction and serve as templates for new designs.

---

## Interactive Schematic Editing

LTspice uses a **verb-noun** interface: select the action first (move, delete, copy, etc.), then select the object(s). Right-click or press Esc to exit any mode.

### Core Editing Commands

| Command | Description |
|---------|-------------|
| Draw Wire | Click to create wire segments; right-click to exit |
| Component | Browse and place from symbol library |
| Resistor / Capacitor / Inductor / Diode | Quick placement buttons |
| Label Net | Assign a name to a node |
| Place GND | Place ground symbol (node "0") |
| SPICE Directive | Place netlist text on schematic |
| SPICE Analysis | Enter simulation command |
| Text | Place non-electrical annotation |
| Delete | Click or drag box to delete objects |
| Move | Relocate objects |
| Stretch | Move objects while wires follow |
| Duplicate | Copy objects (Ctrl+V between schematics) |
| Rotate / Mirror | Change orientation |
| Undo / Redo | Reverse last action |
| Draw > Line/Rect/Circle/Arc | Non-electrical graphics (snap to grid; Ctrl defeats snap) |

### Wiring Rules

- Wires automatically cut through components during placement
- Wires through components are normally auto-deleted (configurable)
- Right-click finishes a wire segment

---

## Placing Components

### From Library Browser

Use **Edit > Component** or the toolbar button. Features:
- Type first letters of symbol name to jump in list
- Preview of symbol and description shown
- Analog.com Product Selector links to ADI tool
- Can open example circuits for ADI models
- Searches all configured symbol paths

### Quick Placement

Toolbar buttons for R, C, L, D provide instant placement without browsing.

---

## Editing Component Properties

### Three Editing Modes

| Mode | How to Access | Use When |
|------|---------------|----------|
| Expert | Right-click on visible attribute text | Changing a known value quickly |
| Assisted | Right-click on component body | Uncertain about SPICE syntax; want GUI helper |
| Super Expert | Ctrl + right-click on body | Need full attribute control |

### Assisted Mode Editors

Available for: R, C, L, D, Q, M, J, V, I, and hierarchical blocks. Opens specialized GUI with component database access.

### Super Expert Mode

Shows ALL symbol attributes with visibility checkboxes. Netlisting format:
```
<Prefix><InstName> node1 node2 [...] <SpiceModel> <Value> <Value2> <SpiceLine> <SpiceLine2>
```

---

## Custom Symbol Creation

### Workflow

1. **File > New Symbol**
2. **Draw the body** — lines, rectangles, circles, arcs (all non-electrical)
3. **Add pins** — Edit > Add Pin/Port
4. **Add attributes** — Edit > Attributes > Edit Attributes
5. **Set visibility** — Edit > Attributes > Attribute Window
6. **Save** as `.asy` file

### Pin Properties

| Property | Description |
|----------|-------------|
| Label Position | TOP, BOTTOM, LEFT, RIGHT (text justification) |
| Netlist Order | Order this pin appears in SPICE netlist line |
| Pin Name | For hierarchical blocks: must match net name in lower-level schematic |

### Important Attributes

| Attribute | Purpose |
|-----------|---------|
| Prefix | Element type character (R, C, M, X, etc.) |
| SpiceModel | Model or subcircuit filename |
| Value | Displayed on schematic |
| Value2 | Value as it appears in netlist |
| ModelFile | Library file to auto-include |

### Special Configurations

**Subcircuit with auto-library include**:
```
Prefix: X
SpiceModel: <library_filename>
Value2: <subcircuit_name>
```

**Hierarchical block**: Leave all attributes blank; change symbol type from "Cell" to "Block".

---

## Automatic Symbol Generation

### From Hierarchical Schematic

1. Edit the lower-level schematic
2. **Hierarchy > Open this Sheet's Symbol**
3. If no symbol exists, LTspice prompts to auto-generate one
4. Pin names match I/O port names in the schematic

**Important**: If you add/remove ports, you must delete and regenerate the symbol.

### From Subcircuit Netlist

1. Open a text netlist containing `.subckt` definitions
2. Place cursor on the `.subckt` line
3. Right-click > **Create Symbol**
4. LTspice generates the `.asy` file automatically

This is the recommended method for third-party models defined as subcircuits.

---

## Hierarchical Design

### Concept

Hierarchy allows:
- Larger circuits while retaining clarity
- Reuse of repeated circuitry
- Library blocks shared across projects

### Rules

1. Symbol name must match schematic filename (e.g., `preamp.asy` references `preamp.asc`)
2. Pin names on the symbol must match node names in the lower-level schematic
3. Names must be valid filenames (no spaces)
4. Symbol representing a block should have NO attributes defined
5. LTspice searches the schematic's directory first for symbols

### Navigation

- **Opening a block**: Right-click on block instance body → opens lower-level schematic
- **Cross-probing**: When opened this way, clicking nodes shows simulation data
- **Requirements for cross-probing**: Enable "Save Subcircuit Node Voltages" and "Save Subcircuit Device Currents" in settings
- **Passing parameters**: Right-click dialog allows entering instance parameters

### Node Naming in Hierarchy

| Name | Behavior |
|------|----------|
| `0` | Always global ground |
| `COM` | Graphical ground symbol, NOT global (useful for isolated domains) |
| `$G_VDD` | `$G_` prefix forces global regardless of hierarchy level |
| Regular names | Local to the subcircuit/block |

### Port Types

Ports can be marked Input, Output, or Bi-directional. This is visual only (no netlister impact) but improves readability.

---

## Symbol and Library Search Paths

### Default Search Priority

1. Folder of currently active schematic (and subfolders)
2. User-configured search paths (Settings > Search Paths tab)
3. User Files directory (default: `Documents\LTspice`, never overwritten by updates)
4. ADI installed library (`%LOCALAPPDATA%\LTspice\lib\`)

### Configuration (Tools > Settings > Search Paths)

| Setting | Purpose |
|---------|---------|
| User Files | Repository for custom symbols, models, schematics |
| Symbol Search Paths | Additional paths for component browser (subfolders included) |
| Simulation Library Search Paths | Paths for .include/.lib resolution |

- Environment variables supported in all paths
- All paths act as roots for relative path resolution
- Separate multiple paths with semicolons or one per line

---

## Drafting Options

Configurable in **Tools > Settings > Schematic**:

| Option | Description |
|--------|-------------|
| Allow direct component pin shorts | Don't auto-delete wires through components |
| Automatically scroll the view | Auto-scroll when mouse near edge |
| Mark unconnected pins | Draw small square at unconnected pins |
| Show schematic grid points | Visible grid on startup |
| Orthogonal snap wires | Force wires vertical/horizontal (Ctrl toggles) |
| Ortho stretch mode | Force stretched wires to stay orthogonal |
| Cut angled wires during stretch | Break non-orthogonal wires |
| Undo history size | Set undo/redo buffer depth |
| Pen thickness | Line width in pixels |
| Draft with thick lines | Publication-ready thick rendering |

---

## PCB Netlist Extraction

Export schematic as netlist for PCB layout: **Tools > Export Netlist**

### Supported Formats

Accel, Algorex, Allegro, Applicon Bravo, Applicon Leap, Cadnetix, Calay, Calay90, CBDS, Computervision, EE Designer, ExpressPCB, Intergraph, Mentor, Multiwire, PADS, Scicards, Tango, Telesis, Vectron, Wire List

### Important Notes

- Pin order for PCB tools often differs from LTspice/ADI pin numbering
- Create custom symbols matching your PCB tool's expected pin order if needed
- Different packages may have different pin assignments

---

*Documentation source: [github.com/analogdevicesinc/ltspice-reference](https://github.com/analogdevicesinc/ltspice-reference)*
