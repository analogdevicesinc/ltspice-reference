---
title: LTspice Schematic Design and Modification Guide
description: The .asc file format, schematic editing, symbols, and hierarchy — including Windows-1252 encoding caveats.
version: "26.1.2+"
---

[← AI Reference](README.md)

# LTspice Schematic Design and Modification Guide

This guide documents the `.asc` schematic file format used by LTspice, based on observation of example schematics shipped with the application.

---

## Table of Contents

1. [ASC File Format Overview](#asc-file-format-overview)
   - [File Encoding — Critical](#file-encoding--critical)
2. [Coordinate System and Grid](#coordinate-system-and-grid)
3. [Layout Quality Rules](#layout-quality-rules)
4. [Wires](#wires)
5. [Net Labels (Flags)](#net-labels-flags)
6. [Components (Symbols)](#components-symbols)
7. [Component Attributes](#component-attributes)
8. [Text and SPICE Directives](#text-and-spice-directives)
9. [Graphic Elements](#graphic-elements)
10. [Rotation and Mirroring](#rotation-and-mirroring)
11. [I/O Pins (Hierarchical Designs)](#io-pins-hierarchical-designs)
12. [Common SPICE Analysis Commands](#common-spice-analysis-commands)
13. [Design Best Practices](#design-best-practices)
14. [Example Walkthrough](#example-walkthrough)
---

## ASC File Format Overview

An `.asc` file is a plain-text file describing an LTspice schematic. The first line declares the format version:

```
Version 4.1
```

LTspice 24 writes `Version 4.1`. Older files carry `Version 4` and still load unchanged. **Emit `Version 4.1` for newly generated schematics**, and leave the existing value alone when editing a file in place.

The second line defines the sheet number and drawing area (width x height):

```
SHEET 1 2580 1252
```

The sheet bounds only control the default view and printable area — elements may sit at negative coordinates or beyond the stated size. 

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
- **Write `u` rather than `µ` in any value you author** (`2.2u`, not `2.2µ`) — unconditionally, not only when the tooling forces it. LTspice treats `u` as the micro multiplier, and an all-ASCII file cannot be corrupted this way. See [Value Notation](#value-notation).
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

A `SYMBOL` placed at `(sx, sy)` has pin world-coordinates determined by applying the orientation transform to each pin's local offset `(px, py)`, as tabulated in [Standard Symbol Geometry](#standard-symbol-geometry-local-coordinates) or returned by `get_symbol_content`:

| Orientation | world_x | world_y |
|-------------|---------|---------|
| R0   | sx + px | sy + py |
| R90  | sx - py | sy + px |
| R180 | sx - px | sy - py |
| R270 | sx + py | sy - px |
| M0   | sx - px | sy + py |
| M90  | sx + py | sy + px |
| M180 | sx + px | sy - py |
| M270 | sx - py | sy - px |

**Mirror order matters — rotate first, then flip horizontally.** The mirrored rows above are the rotation result with its *relative* x negated, not the rotation applied to a pre-negated `px`. The two orders happen to agree for M0 and M180, but they disagree for M90 and M270, so the shortcut "negate px, then rotate" silently produces wrong coordinates on half the mirror cases.

Mirroring also swaps which pin lands left versus right, so re-derive every pin after changing orientation rather than assuming the previous left/right assignment still holds.

### Standard Symbol Geometry (local coordinates)

**The table below is the first and, for the symbols it lists, the only source of symbol geometry you need.** It is a cached copy of the `get_symbol_content` tool's own output for the primitives, so routine work needs neither a round trip nor a file read. Each pin reads `name[n] = (px, py)` followed by its exit direction, where `n` is the **SPICE netlist order** — the position the pin occupies on the generated netlist line. Placement alone does not tell you node order, so for any device with three or more pins the bracketed number is what matters. Exit arrows are local directions at R0, remembering that **+y points down**: ↑ up, ↓ down, ← left, → right. **Keep-out** is the box a wire must stay out of, also local at R0. It unions the drawn ink with every visible pin anchor and **excludes** attribute text, which is why `voltage`'s box starts at its `+` pin rather than at the circle 8 px below it, and why clearing text is a separate rule with its own margin ([Text Keep-Out](#text-keep-out)). These are the tool's own figures, so a few edges land **off-grid** (`ind` at x=5, `FerriteBead2` at ±9) where a sampled arc stops between grid lines. That is the real edge; do not round it outward and then treat the rounded box as authoritative.

| Symbol | Prefix | Keep-out | Pins |
|--------|--------|----------|------|
| `res` | R | (0,16)–(32,96) | `A[1]=(16,16)`↑  `B[2]=(16,96)`↓ |
| `res2` | R | (0,0)–(32,64) | `A[1]=(16,0)`↑  `B[2]=(16,64)`↓ |
| `ind` | L | (5,16)–(32,96) | `A[1]=(16,16)`↑  `B[2]=(16,96)`↓ |
| `ind2` | L | (4,16)–(32,96) | `A[1]=(16,16)`↑  `B[2]=(16,96)`↓ |
| `cap` | C | (0,0)–(32,64) | `A[1]=(16,0)`↑  `B[2]=(16,64)`↓ |
| `polcap` | C | (0,0)–(32,64) | `A[1]=(16,0)`↑  `B[2]=(16,64)`↓ |
| `voltage` | V | (-32,16)–(32,96) | `+[1]=(0,16)`↑  `-[2]=(0,96)`↓ |
| `current` | I | (-32,0)–(32,80) | `+[1]=(0,0)`↑  `-[2]=(0,80)`↓ |
| `diode`, `schottky` | D | (0,0)–(32,64) | `+[1]=(16,0)`↑  `-[2]=(16,64)`↓ |
| `zener` | D | (-4,0)–(36,64) | `+[1]=(16,0)`↑  `-[2]=(16,64)`↓ |
| `LED` | D | (0,0)–(72,64) | `+[1]=(16,0)`↑  `-[2]=(16,64)`↓ |
| `npn`, `npn2`, `npn3` | QN | (0,0)–(64,96) | `C[1]=(64,0)`↑  `B[2]=(0,48)`←  `E[3]=(64,96)`↓ |
| `npn4` | QN | (0,0)–(64,96) | `C[1]=(64,0)`↑  `B[2]=(0,48)`←  `E[3]=(64,96)`↓  `S[4]=(64,48)`→ |
| `pnp`, `pnp2` | QP | (0,0)–(64,96) | `C[1]=(64,0)`↑  `B[2]=(0,48)`←  `E[3]=(64,96)`↓ |
| `pnp4` | QP | (0,0)–(64,96) | `C[1]=(64,0)`↑  `B[2]=(0,48)`←  `E[3]=(64,96)`↓  `S[4]=(64,48)`→ |
| `lpnp` | QP | (0,0)–(64,96) | `C[1]=(64,0)`↑  `B[2]=(0,48)`←  `E[3]=(64,96)`↓  `S[4]=(64,48)`→ |
| `nmos` | MN | (0,0)–(48,96) | `D[1]=(48,0)`↑  `G[2]=(0,80)`←  `S[3]=(48,96)`↓ |
| `pmos` | MP | (0,0)–(48,96) | `D[1]=(48,0)`↑  `G[2]=(0,80)`←  `S[3]=(48,96)`↓ |
| `nmos4` | MN | (0,0)–(48,96) | `D[1]=(48,0)`↑  `G[2]=(0,80)`←  `S[3]=(48,96)`↓  `B[4]=(48,48)`→ |
| `pmos4` | MP | (0,0)–(48,96) | `D[1]=(48,0)`↑  `G[2]=(0,80)`←  `S[3]=(48,96)`↓  `B[4]=(48,48)`→ |
| `njf` | JN | (0,0)–(48,96) | `D[1]=(48,0)`↑  `G[2]=(0,64)`←  `S[3]=(48,96)`↓ |
| `pjf` | JP | (0,0)–(48,96) | `D[1]=(48,0)`↑  `G[2]=(0,64)`←  `S[3]=(48,96)`↓ |
| `mesfet` | Z | (0,0)–(48,96) | `D[1]=(48,0)`↑  `G[2]=(0,80)`←  `S[3]=(48,96)`↓ |
| `sw` | S | (-48,16)–(32,96) | `A[1]=(0,16)`↑  `B[2]=(0,96)`↓  `NC+[3]=(-48,80)`←  `NC-[4]=(-48,32)`← |
| `csw` | W | (-32,0)–(32,80) | `+[1]=(0,0)`↑  `-[2]=(0,80)`↓ |
| `e` | E | (-48,16)–(32,96) | `+[1]=(0,16)`↑  `-[2]=(0,96)`↓  `P[3]=(-48,32)`←  `N[4]=(-48,80)`← |
| `e2` | E | (-48,16)–(32,96) | `+[1]=(0,16)`↑  `-[2]=(0,96)`↓  `P[3]=(-48,80)`←  `N[4]=(-48,32)`← |
| `f` | F | (-32,0)–(32,80) | `+[1]=(0,0)`↑  `-[2]=(0,80)`↓ |
| `g` | G | (-48,16)–(32,96) | `+[1]=(0,96)`↓  `-[2]=(0,16)`↑  `NC+[3]=(-48,32)`←  `NC-[4]=(-48,80)`← |
| `g2` | G | (-48,16)–(32,96) | `+[1]=(0,96)`↓  `-[2]=(0,16)`↑  `NC+[3]=(-48,80)`←  `NC-[4]=(-48,32)`← |
| `h` | H | (-32,16)–(32,96) | `+[1]=(0,16)`↑  `-[2]=(0,96)`↓ |
| `bv` | B | (-32,16)–(32,96) | `+[1]=(0,16)`↑  `-[2]=(0,96)`↓ |
| `bi` | B | (-32,0)–(32,80) | `+[1]=(0,0)`↑  `-[2]=(0,80)`↓ |
| `bi2` | B | (-32,0)–(32,80) | `+[1]=(0,80)`↓  `-[2]=(0,0)`↑ |
| `tline` | T | (-48,-16)–(48,16) | `I1[1]=(-48,-16)`←  `R1[2]=(-48,16)`←  `I2[3]=(48,-16)`→  `R2[4]=(48,16)`→ |
| `ltline` | O | (-48,-16)–(48,16) | `I1[1]=(-48,-16)`←  `R1[2]=(-48,16)`←  `I2[3]=(48,-16)`→  `R2[4]=(48,16)`→ |
| `load` | I | (0,0)–(40,64) | `A[1]=(16,0)`↑  `B[2]=(16,64)`↓ |
| `load2` | I | (-32,0)–(36,80) | `+[1]=(0,0)`↑  `-[2]=(0,80)`↓ |
| `FerriteBead` | L_Ferrite_Bead | (-16,-32)–(16,32) | `A[1]=(0,-32)`↑  `B[2]=(0,32)`↓ |
| `FerriteBead2` | L_Ferrite_Bead | (-9,-32)–(9,32) | `A[1]=(0,-32)`↑  `B[2]=(0,32)`↓ |
| `fra` | @ | (-16,-64)–(16,0) | `OUT[1]=(0,-64)`↑  `IN[2]=(0,0)`↓ |
| `fraprobe` | & | (-48,-96)–(48,0) | `O+[1]=(48,-80)`→  `O–[2]=(48,-16)`→  `I+[3]=(-48,-80)`←  `I–[4]=(-48,-16)`← |
| `ISO16750-2`, `ISO7637-2` | X | (-32,0)–(32,80) | `+[1]=(0,0)`↑  `-[2]=(0,80)`↓ |
| `opamp2` | X | (-32,32)–(32,96) | `In+[1]=(-32,80)`←  `In-[2]=(-32,48)`←  `V+[3]=(0,32)`↑  `V-[4]=(0,96)`↓  `OUT[5]=(32,64)`→ |

**Traps in this table:**
- `res2` does **not** share `res` pin offsets — it is 64 px between pins, not 80.
- `g` and `g2` put `+` at the **bottom** (`py=96`) and `-` at the top (`py=16`), the reverse of `voltage`, `e`, `h`, and `bv`.
- `bi2` likewise reverses `bi`: `+` is the **bottom** pin (`py=80`) and `-` the top (`py=0`). The two symbols look nearly identical on the sheet.
- `e` / `e2` and `g` / `g2` differ *only* in whether the control pins are swapped; picking the wrong one inverts the controlling sense with no geometric hint.
- `tline` / `ltline`, `FerriteBead`, `fra`, and `fraprobe` use **negative** `py`, so their bodies straddle or sit above the placement origin.
- `polcap` pin names are `A` and `B`, not `+` and `-`, even though the body is drawn polarized. `A[1]` is the positive terminal.
- The `ISO*` automotive transient sources netlist with prefix **`X`** (a subcircuit), not `V`.

#### Symbols Not in the Table

**Everything in this subsection applies only to a symbol the table above does not list.** For a listed symbol the row *is* the answer: do not call a tool, read a file, or re-derive what is already tabulated, and do not let either source argue you out of the row.

**For an unlisted symbol, call the `get_symbol_content` MCP tool — where the client has it.** That tool is served by the desktop LTspice MCP bridge, which ships with LTspice 26.1.2 and later; a client with no MCP connection, or one talking to an older LTspice, does not have it at all. Pass the symbol name as a `SYMBOL` card spells it — relative path, extension optional, `/` or `\` — and read `keep_out` (the box no wire may cross) and `pins` (each carrying `name`, `x`, `y`, `spice_order` and `exit_direction`) from the response. It resolves names through the same search path the schematic loader uses, so a bare stem such as `LT8609S` resolves as well as `PowerProducts/LT8609S`, and it reports the symbol the user currently has open in the editor, unsaved edits included, in preference to the library copy. A symbol with no geometry and no visible pins has no box to report — a vendor-encrypted part is the case that reaches this in practice — and answers with `keep_out_empty: "true"`, omitting `keep_out`. That is a real outcome rather than an error: treat the drawn extent as unknown and route with generous clearance, rather than reading it as an empty box.

**When the `get_symbol_content` MCP tool is available, do not obtain symbol geometry any other way.** Not by reading the `.asy` file, not by parsing its `LINE`/`RECTANGLE`/`CIRCLE`/`ARC` numbers, not by copying a similar-looking part, and not by reasoning about how the symbol is drawn. Those numbers do not mean what they appear to: an `ARC`'s first four bound a construction ellipse that can be far larger than the curve drawn inside it. Nor does a shared pin set imply a shared body — `LED` carries `diode`'s pins exactly, on a body 40 px wider.

#### Symbol Names and Library Layout

Symbols install under `%LOCALAPPDATA%\LTspice\lib\sym\`, and **that directory is not flat.** Only the passives, sources, and primitives tabulated above sit in `sym\` itself; the vast majority of installed symbols are one or more levels down, so `sym\<name>.asy` will not resolve for a real device:

| Subdirectory | Contents |
|--------------|----------|
| `PowerProducts\` | regulators, converters, gate drivers, PMICs |
| `Contrib\` | third-party vendor libraries, **nested further** by vendor / family / package |
| `opamps\` | op-amps |
| `Switches\` | analog switches and multiplexers |
| `SpecialFunctions\` | mixed-signal function blocks |
| `misc\` | behavioural primitives, `SOAtherm-*`, oddments |
| `References\` | voltage references |
| `ADC\`, `DAC\`, `Comparators\`, `FilterProducts\`, `Optos\`, `digital\`, `externals\` | as named |

The set of subdirectories varies with the install and with any vendor libraries added since, so treat the list as a starting point rather than a fixed inventory.

Do not go looking for the folder. Where it is available, `get_symbol_content` accepts a bare stem, resolves it through the loader's own search order, and returns the resolved absolute `path` — which is where the subdirectory spelling for a `SYMBOL` card comes from.

The subdirectory is part of how the symbol is referenced, not just where it happens to be filed. A `SYMBOL` line carries the path relative to `sym\`, with each separator written as a **doubled** backslash:

```
SYMBOL Comparators\\LT1719 304 224 R0
SYMBOL Contrib\\EPC\\EPC2204 464 -32 R0
```

Case is inconsistent in ADI's own example schematics (`opamps`, `Opamps`, and `OpAmps` all appear) because Windows path lookup is case-insensitive; match the directory as it exists on disk anyway.

### Pin Span Reference

Pin-to-pin distance drives whether two parts can sit on a shared pair of rails without a jog. Symbols with the same span but different offsets still align differently against the grid:

| Span | Offsets | Symbols |
|------|---------|---------|
| 64 px | py 0 → 64 | `cap`, `polcap`, `res2`, `load`, `diode` family |
| 64 px | py -32 → 32 | `FerriteBead`, `FerriteBead2` |
| 64 px | py -64 → 0 | `fra` |
| 80 px | py 0 → 80 | `current`, `csw`, `f`, `bi`, `bi2`, `load2`, `ISO16750-2`, `ISO7637-2` |
| 80 px | py 16 → 96 | `res`, `ind`, `ind2`, `voltage`, `e`, `e2`, `g`, `g2`, `h`, `bv`, `sw` |

The practical consequence: **`res` pins are 80 px apart while `cap` pins are 64 px apart.** Placing a capacitor in parallel with a resistor always leaves a 16 px shortfall to bridge.

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

**NPN in M0** (mirrored, base on the right): `SYMBOL npn 64 96 M0`
- Pin C: (64 - 64, 96 + 0) = **(0, 96)**
- Pin B: (64 - 0, 96 + 48) = **(64, 144)** — base now exits to the **right**
- Pin E: (64 - 64, 96 + 96) = **(0, 192)**

**NPN in M90**: `SYMBOL npn 64 96 M90`
- Pin C: (64 + 0, 96 + 64) = **(64, 160)**
- Pin B: (64 + 48, 96 + 0) = **(112, 96)**
- Pin E: (64 + 96, 96 + 64) = **(160, 160)**

Note how M90 uses `(sx + py, sy + px)`. Applying the "negate px first" shortcut would instead give C at (64, 32) — off by 128 px and connected to nothing.

### Complete Example: RC Low-Pass Filter

This example is drawn to satisfy every rule in [Layout Quality Rules](#layout-quality-rules), so it can be copied as a starting template.

```
Version 4.1
SHEET 1 880 400
WIRE -48 64 -48 112
WIRE 80 64 -48 64
WIRE 208 64 160 64
WIRE 256 64 208 64
WIRE 256 112 256 64
WIRE -48 240 -48 192
WIRE 256 240 256 176
FLAG -48 64 in
FLAG 208 64 out
FLAG -48 240 0
FLAG 256 240 0
SYMBOL voltage -48 96 R0
SYMATTR InstName V1
SYMATTR Value AC 1
SYMBOL res 176 48 R90
SYMATTR InstName R1
SYMATTR Value 1k
SYMBOL cap 240 112 R0
SYMATTR InstName C1
SYMATTR Value 100n
TEXT -48 296 Left 2 !.ac dec 100 1 10Meg
```

**Pin coordinates** (origin + transform from the tables above):

| Part | Placement | Pin | World coordinate |
|------|-----------|-----|------------------|
| V1 | `voltage -48 96 R0` | `+` | (-48, 112) |
| V1 | | `-` | (-48, 192) |
| R1 | `res 176 48 R90` | `A` | (160, 64) |
| R1 | | `B` | (80, 64) |
| C1 | `cap 240 112 R0` | `A` | (256, 112) |
| C1 | | `B` | (256, 176) |

**Connection verification**:
- V1 `+` (-48, 112) → `WIRE -48 64 -48 112`, a 48 px vertical exit stub carrying `FLAG -48 64 in`
- R1 `B` (80, 64) → `WIRE 80 64 -48 64`, leaving horizontally (its pin direction) and turning down only at x = -48
- R1 `A` (160, 64) → `WIRE 208 64 160 64`, 48 px horizontally to `FLAG 208 64 out`
- C1 `A` (256, 112) → `WIRE 256 112 256 64`, a 48 px vertical stub meeting the rail at the corner (256, 64)
- V1 `-` (-48, 192) → `WIRE -48 240 -48 192` → `FLAG -48 240 0`
- C1 `B` (256, 176) → `WIRE 256 240 256 176` → `FLAG 256 240 0`
- No wire joins R1 `A` to R1 `B` — a segment spanning both pins would short the resistor while still looking plausible on screen

Resulting netlist:

```spice
V1 in 0 AC 1
R1 out in 1k
C1 out 0 100n
.ac dec 100 1 10Meg
```

A -3 dB corner near 1.59 kHz. Note that R1 netlists as `out in`, not `in out`: in R90 the pin with SPICE order 1 (`A`) is the right-hand pin, which lands on `out`. Node order follows `SpiceOrder`, never left-to-right screen position.

### Caution: AI-Generated Schematic Modifications

Creating or modifying `.asc` schematics that involve placing components or routing wires is inherently error-prone for AI assistants. The coordinate math, rotation transforms, and wire connectivity rules make it very easy to produce schematics with misaligned pins, overlapping symbols, or broken connections. If a user asks to create a schematic or make changes that require moving components or rewiring, **warn them that the result may need manual correction in LTspice** and suggest they verify connectivity after opening the file.

Changes that only modify SYMATTR values (e.g., changing a component value or model name) or TEXT directives (e.g., changing `.tran 1m` to `.tran 5m`) are usually safe and reliable.

### Layout Guidelines for AI-Generated Schematics

1. **Compute pin world-coordinates first**: Before placing a symbol, calculate where its pins will land using the rotation formulas above.
2. **Verify connections**: Every intended connection must have matching coordinates — either two pins at the same point, or pins at wire endpoints.
3. **Avoid overlaps**: Ensure symbol bodies do not overlap. A `res` in R90 spans 80 units horizontally; a `voltage` in R0 spans 80 units vertically. Bodies must also stay clear of wires and text — see [Layout Quality Rules](#layout-quality-rules).
4. **Use wires for gaps**: If two connected pins are not at the same point, add a `WIRE` line connecting them.
5. **Ground flags need wire endpoints**: Every `FLAG` must be placed at a wire endpoint or at a point that coincides with a component pin.
6. **Keep components on the 16-unit grid**: Choose symbol placement coordinates that result in all pin world-coordinates being multiples of 16.

---

## Layout Quality Rules

Connectivity correctness is necessary but not sufficient. A schematic can netlist perfectly and still be unreadable, and **none of the rules in this section are visible to the netlist** — a generated `.asc` will pass every connectivity check while violating all of them. These are what separate a drawing that looks hand-made from one that looks machine-emitted.

| Rule | Value | Applies to |
|------|-------|------------|
| Grid unit | 16 px | everything |
| Pin exit stub | ≥ 48 px (3 grids) **outward, in the pin's own direction** | every pin |
| Flag clearance | ≥ 48 px from the pin it serves | `FLAG`, ground and named |
| Adjacent pin columns/rows | ≥ 96 px (6 grids) | parts sitting side by side |
| Series gap along a rail | ≥ 48 px of clear wire | between consecutive devices |
| Initial component spacing | ~256 px (16 grids) between origins | first placement pass |
| Symbol body keep-out | no crossing at all; ≥ 16 px of daylight when routing past | every wire segment |
| Attribute text clearance | ≥ 16 px from the symbol outline | visible `WINDOW` text |
| Text keep-out | no overlap with any body, wire, flag, or other text | `WINDOW` attributes, `TEXT`, `FLAG` labels |
| Directive line spacing | 32 px between `TEXT` baselines | the SPICE block |

### Placement Strategy

The rules below are constraints to satisfy; this is the process that satisfies them cheaply. Most layout pain comes from treating placement as a one-shot step and then trying to rescue it with wire.

**Build in this order:**

1. Place symbols using pin math, so the 48 px and 96 px targets are already met before any wire exists
2. Route each pin's exit stub outward, then the rails that join the stubs — around bodies, never across them
3. Add flags on stubs, never on pins
4. Place the SPICE directive block below the circuit
5. Walk the [post-edit layout gate](#post-edit-layout-gate) pin by pin
6. Confirm the netlist, then simulate

**Routing is an input to placement, not an afterthought.** Decide roughly where the rails will run *before* committing symbol coordinates. A part positioned without regard to its wiring will need to move later anyway, and by then it has neighbours that also have to move.

**Minimize bends.** Position parts so wire runs are straight. Each unnecessary direction change is a place the reader has to re-orient. Shifting a single part by one grid unit routinely removes two bends — for example, nudging a resistor up 16 px to put its pin on the same row as the rail it feeds.

**Spacing values are floors, not targets.** The 48 px and 96 px numbers define a feasible region, not exact positions. Parts may slide freely within that region to straighten a wire run, and doing so is usually the right fix. Do not snap everything to exactly 96 px and then bend wire around the result.

**Prefer moving parts over adding wire.** When a clearance rule fails, relocate the symbol on the 16 px grid. Patching the gap with extra jogged segments satisfies the arithmetic while making the drawing worse.

**Iterate once placement is complete.** After everything is down and wired, do a deliberate refinement pass: look for bends that a small shift would remove, rails that are nearly but not quite aligned, and parts sitting at an arbitrary offset because that is simply where they landed. This pass is what makes a schematic look composed rather than assembled.

### Composition Conventions

The clearance rules above constrain individual parts. These conventions govern the drawing as a whole, and a schematic can satisfy every numeric rule while still reading as machine-emitted because it ignores them.

**Signal flows left to right.** Input source at the left edge, load or output node at the right, intermediate stages in signal order between them. A reader should be able to trace the circuit without backtracking. Feedback paths are the exception and route right-to-left above or below the forward path.

**Separate signal routing from ground routing.** Keep a dedicated horizontal ground bus below the circuit and bring every ground connection down to it, rather than scattering independent ground flags at whatever height each part happens to sit. Signal rails stay in the body of the drawing; the ground bus stays out of it.

**Place symmetric circuits symmetrically.** Differential pairs, push-pull stages, bridge arms, and matched RC branches should be mirror images with equal-length wire segments on both sides. Unequal stub lengths on a matched pair are read as a schematic error even when the netlist is identical.

**Leave room to modify.** Do not pack parts to the minimum clearances across the whole sheet. Leave clear space at the edges and between functional blocks so a later addition does not force a wholesale re-layout — the 96 px floor is what a crowded region may fall to, not the spacing to design toward.

### Pin Exit Stub

Every pin leaves its symbol with at least **48 px of wire in the same direction as the pin** before any 90° turn. Only after that stub may the wire turn to join a rail.

**The stub runs outward — away from the symbol body.** "In the pin direction" names an axis *and a sense*: the sense that increases distance from the body. A vertical pin does not stub "up or down" as a free choice. On an R0 `res`, the top pin `A` at local `(16,16)` stubs **up** and the bottom pin `B` at local `(16,96)` stubs **down**. Running `A`'s wire downward past the zig-zag to reach a rail below the part is connectivity-correct and visibly wrong — the wire lies over the symbol it feeds, and the netlist is identical, so nothing will flag it.

**The outward direction is given, not derived.** Every pin in [Standard Symbol Geometry](#standard-symbol-geometry-local-coordinates) carries its exit arrow, and `get_symbol_content` returns an `exit_direction` per pin for everything else. Take it from there, because the shortcuts reached for instead are wrong on common parts. *Which box edge is the pin nearest?* sends an `nmos` gate at local `(0,80)` **down** along the body — 16 px from the bottom edge against 24 px from the left — when it exits **left**. *Which way does the drawn lead point?* holds for axial parts and fails on a BJT, whose collector lead `LINE 16 32 64 0` runs diagonally to a pin that must still be exited **up**.

**A pin may sit inside its own symbol's keep-out box**, so "inside the box" is never by itself evidence of a violation. `nmos5` buries its bulk pin `B` 48 px in; `LTC6416` its `V+` 64 px. Such a pin has no edge normal to read, which is one more reason to take the direction from the tool rather than construct it. A stub leaving its own pin outward stays legal while it is still inside its symbol's box; see [No Wire Across a Symbol Body](#no-wire-across-a-symbol-body).

**An op-amp's `V+`/`V-` can put the shortest path in the forbidden direction.** Both exit vertically, so wherever the supply rail runs horizontally, the shortest path to it is an immediate sideways turn — the one direction the rule above forbids.

**Rotation carries the outward direction with the symbol.** The transform table in [Pin World-Coordinate Calculation](#pin-world-coordinate-calculation) applies unchanged to a direction vector `(dx, dy)` — drop the `sx`/`sy` terms and transform the relative part alone:

| Orientation | outward vector | Orientation | outward vector |
|-------------|----------------|-------------|----------------|
| R0 | (dx, dy) | M0 | (-dx, dy) |
| R90 | (-dy, dx) | M90 | (dy, dx) |
| R180 | (-dx, -dy) | M180 | (dx, -dy) |
| R270 | (dy, -dx) | M270 | (-dy, -dx) |

So the `res` top pin's local outward `(0,-1)` becomes `(1,0)` — **right** — at R90, and `(-1,0)` at R270. Derive it per pin rather than assuming "a horizontal part stubs left and right" and then picking whichever side the rail happens to be on; that shortcut is right half the time and folds the stub back over the body the other half. The **mirror order caveat** applies here too: the mirrored rows are the rotation result with its *x* negated, not the rotation of a pre-negated `dx`.

**Never land a perpendicular bus directly on a pin.** This is the single most common generated-schematic tell — attaching a horizontal `OUT` rail straight onto a vertical resistor pin because it "looks like a textbook divider." The netlist is identical either way, so nothing will flag it.

Check *every* pin of *every* symbol, including mid-chain nodes such as the bottom of a divider's upper resistor.

### No Wire Across a Symbol Body

**No wire segment may pass through or over a symbol body.** A wire touches a symbol only at a pin coordinate, and only as the outward stub above. This is a hard rule rather than a preference: LTspice draws wires and symbols in one plane with no occlusion, so a segment crossing a body is visually indistinguishable from a connection to whatever it crosses — a wire over an op-amp triangle reads as a pin that does not exist. The netlist stays silent, because crossing is not connecting.

**The check.** Transform each symbol's local **keep-out box** — from the table above, or from `get_symbol_content` — into **world** coordinates the same way as its pins, then re-normalize the two corners to min/max, since a rotation swaps which corner is which. For every `WIRE x1 y1 x2 y2` and every symbol, a violation is:

- the segment's interior entering the box,
- the segment running along a box edge, or
- the segment ending inside the box anywhere other than that symbol's own pin.

**One exemption, and only one:** a segment that starts at one of *that* symbol's own pins and runs outward along the pin's axis. It stays legal for as long as it runs straight outward, which matters because a keep-out box can legitimately extend past the pin the stub leaves from — a pin can sit 16 px or deeper inside its own symbol's box, as `nmos5`'s bulk pin and `LTC6416`'s `V+` do. Every other segment of every other net is subject to the box in full, including a stub belonging to a *neighbouring* symbol.

**Prefer moving the part.** A wire that wants to cross a body is usually reporting a placement fault: the part sits between two nodes that must connect, or in the wrong orientation, or on the wrong side of a rail. Rotating it, or moving it 16–32 px off the rail's row, removes the crossing outright. This is the same [prefer moving parts over adding wire](#placement-strategy) trade as everywhere else.

**When the part must stay put, route around it with ≥ 16 px of daylight.** Take the wire out to a clear column or row and turn there. Two clean right angles read better than a line through a body, and those corners are not what [minimize bends](#placement-strategy) is about — that rule targets *unnecessary* bends.

**Three common causes of crossings:**

- **Rails drawn in one span.** A ground bus or supply rail emitted as a single `WIRE` from the leftmost to the rightmost node sails through everything sitting at that Y. Break the run at each node it is meant to touch, and check each resulting span. Where such a span also passes through a pin coordinate it stops being cosmetic and becomes the routing short from [Auditing an Existing Schematic](#auditing-an-existing-schematic).
- **Wide-bodied parts.** A vertical column one grid unit clear of a `voltage` source's pins is not clear of the source — its circle is 32 px wider on each side. Check against the keep-out box, never against the pin column.
- **Late additions.** A part dropped into an apparent gap after routing is finished lands on existing wire. Re-run the crossing check over the **whole sheet** after adding any symbol, not just over the wires added with it.

### GND Approach

The ground symbol is vertical, so **only a vertical wire may attach to `FLAG x y 0`**. A horizontal ground rail must T-junction onto that vertical stub **≥ 48 px above the flag**, never onto the flag itself, and that junction must also sit ≥ 48 px from any other pin on the same net.

### Named Nets on the Stub

Place `IN` / `OUT` labels on the pin-exit stub itself, in the pin direction. Do **not** add a sideways spur whose only purpose is to hold a label. If V1's `+` faces up, run the stub straight up ≥ 48 px and put the flag at the top of it.

### Parallel RC Placement

`res` pins are 80 px apart; `cap` pins are 64 px apart. That 16 px shortfall has to go somewhere.

Placement by resistor orientation, using identical pin-line spacing (**96 px**) in all four cases:

| Resistor rotation | Capacitor placement | Typical cap rotation |
|-------------------|---------------------|----------------------|
| R0 (vertical) | left of resistor | R0 |
| R90 (horizontal) | below resistor | R270 (or R90) |
| R180 (vertical, flipped) | right of resistor | R0 |
| R270 (horizontal) | above resistor | R270 |

Keep **both resistor exit stubs equal** at 48 px, then absorb the 16 px difference on the **capacitor** rail, after the capacitor's own exit stub. Do not shorten one resistor stub to make the ends meet — that produces a visibly lopsided pair. Verify afterwards that both parts land on the same two nets in the netlist.

Use the **same center-to-center spacing in all four cases**. The natural mistake is to place horizontal pairs closer together than vertical ones, because a horizontal pair has more visual room; the result is a sheet whose parallel pairs are inconsistently spaced depending on rotation.

**Self-test for this rule:** one R+C pair in each of R0, R90, R180, and R270 on a single sheet exercises every parallel-routing case at once. If all four netlist as two-element parallel branches on the same node pairs and all four look alike, the routing logic is correct; a bug in the 16 px absorption or in the stub direction shows up in exactly one quadrant.

### SPICE Directive Placement

1. **Below the circuit.** Put the directive block under all symbols, wires, and flags — typically below the ground bus — never beside or on top of the drawing.
2. **No overlap with anything.** Directives must not cover ground flags, net labels, symbol bodies, instance names or values, or wires.
3. **No overlap with each other.** Stack them in one column with ~32 px between `TEXT` baselines.
4. **Grow the sheet** if the block would fall past the bottom edge.

### Attribute Text Placement

Visible instance attributes are positioned by the symbol's `WINDOW` offsets, not by free `TEXT` elements. These rules are how to satisfy the [text keep-out](#text-keep-out) for instance names and values specifically.

1. **Justification** — choose `Left`, `Right`, `VTop`, `VBottom`, etc. so the string grows *away* from the symbol body and away from nearby wires.
2. **Clearance** — keep ≥ 16 px between the nearest edge of the text and the symbol outline, and from other objects.
3. **Re-check after rotating** — evaluate attribute placement in the *final* orientation, not the one you placed it in.
4. **Long values** — strings like `PULSE(...)` need real room; place the part where its value has open space rather than letting the text overlap the symbol or dense routing.
5. **Fallback** — if no placement clears the circuitry on a crowded sheet, keep the original `WINDOW` and justification. Do not make the layout worse with speculative moves.
6. **BJTs and MOSFETs** — leave their attribute text (instance name, value, etc.) at the symbol's default `WINDOW` positions except in rare cases. If that text would overlap something, move the transistor or the neighbouring parts and wires instead.

### Text Keep-Out

**No text may overlap a symbol body, a wire, a flag, or another string.** Three kinds of text land on a sheet, and the rule binds all three:

| Text | Positioned by | Anchor |
|------|---------------|--------|
| Instance name, value, SpiceLine | `WINDOW` offsets on the symbol | symbol origin + offset, transformed with the symbol |
| Directives and comments | `TEXT x y justification fontSize` | the given coordinate |
| Net labels | `FLAG x y netname` | drawn beside the flag point |

**Reserve a box, not a point.** A `TEXT` or `WINDOW` line gives an anchor; what has to clear the drawing is the rectangle the rendered string occupies. For the default `fontSize 2`, budget **~16 px of height** and **~8 px per character** of width, and grow the box from the anchor in the justification direction — `Left` grows rightward, `Right` grows leftward, the `V*` justifications grow vertically. Those are deliberately round numbers for reserving space, not metrics: real glyph widths are font-dependent, so treat a box that only just fits as one that does not, and confirm anything crowded by opening the sheet in LTspice.

`PULSE(...)`, `SINE(...)`, and model names run 20–40 characters — 160–320 px of width. A long `SYMATTR Value` is the string most likely to reach across a neighbouring rail, and the overlap is the hardest kind to see in the file: the anchor sits harmlessly beside its own symbol, and the wire the string lands on is declared somewhere else entirely. Two objects that collide on screen can be hundreds of lines apart in the `.asc`, so this check has to be done from computed boxes, not by reading down the file.

**Net labels need the space beyond the stub, not on it.** LTspice draws the name adjacent to the flag point rather than on the wire, so the sheet past the end of the stub is what must be clear — one more reason a named-net stub runs its full 48 px into open space instead of stopping where a rail already runs.

**Move the part before the text.** The usual first choice is to move the part or spread the block until its attribute text clears the drawing at its default position — the 96 px spacing floor is a minimum for crowded regions, not a target to design toward. Moving attribute text is a judgement call, acceptable when moving the part would cost more, such as extra wire jogs or excessive empty space. A moved string must stay close enough to its own part that it is clearly associated with it, not with a neighbour. On BJTs and MOSFETs it should very rarely be moved at all ([Attribute Text Placement](#attribute-text-placement) rule 6). If neither the part nor the text has a clean option, keep the symbol's default `WINDOW` and justification, per rule 5: an overlap left at the default position is at least the one a reader expects, and is better than a speculative move that makes the region worse.

**Vertical stacks need vertical room too.** Keep 32 px between `TEXT` baselines in the directive block, then check both ends of the stack: the first line must clear the ground bus above it, and the last line must not run past the bottom of the sheet. A block that outgrows its space is [grown downward with the sheet](#spice-directive-placement), never upward into the circuit.

### Post-Edit Layout Gate

Run this after **every** change that creates a schematic or adds or moves symbols, wires, or flags — including first-time builds, full rebuilds, and late one-part additions. Run it *before* simulating and *before* reporting the schematic as finished, and re-run it after each fix.

**A correct netlist does not close out the task.** Netlist OK ≠ layout OK.

1. **Compute pins, not origins** — derive every pin's world coordinate from the pin table plus the orientation transform; wire endpoints must hit those coordinates.
2. **Scan for diagonals** — read every `WIRE x1 y1 x2 y2` line and check whether it changes **both** X and Y. No wire may. Replace each diagonal with an orthogonal pair of segments through an explicit corner point. This is a purely mechanical text check and catches the most visually obvious defect in the file.
3. **Pin exit stubs** — ≥ 48 px on every pin, running **outward** in the pin's own direction, with no stub folded back along the body and no perpendicular bus landing on a pin.
4. **Body crossings** — no `WIRE` segment enters, runs along the edge of, or terminates inside any symbol's world keep-out box. The only legal contact is that symbol's own pin, exited outward.
5. **Series gaps** — ≥ 48 px of clear wire between consecutive devices on a rail.
6. **Adjacent spacing** — ≥ 96 px between the closest pins of side-by-side parts.
7. **Ground** — only vertical wires touch `FLAG ... 0`; horizontal T-junctions are ≥ 48 px from the flag and from other pins.
8. **Flags** — every flag lies on a wire, ≥ 48 px from the pin it serves, on the pin-direction stub.
9. **Directives** — below the circuit, non-overlapping.
10. **Text keep-out** — reserve a box for every instance name, value, directive, comment, and net label, and confirm none of those boxes lands on a symbol body, a wire, a flag, or another string. Where a crowded sheet leaves no clear box, the default `WINDOW` fallback applies — note it rather than silently accepting a random overlap.
11. **Netlist confirm** — intended connectivity, no accidental shorts, labels on the intended nodes, and every `NC_*` node accounted for as an intentionally open pin.
12. **Re-gate after late edits** — if anything changed after step 11, return to step 1.

### When the Gate Does Not Apply

The gate covers **geometry changes**. Skip it for:

- Read-only questions about a schematic, or describing a circuit that is already open
- Inspecting a netlist or a simulation log
- Running a simulation when no layout edit was made
- Value-only edits — changing a `SYMATTR Value` or a `TEXT` directive's parameters, with no symbol, wire, `FLAG`, or `TEXT` position moved
- Edits confined to a `.plt` plot-settings file

**Do not skip it because the circuit is simple or the netlist looks right.** Neither is evidence about layout, and simple circuits are where the geometry pass is most often dropped.

### Definition of Done

A schematic edit is complete when **all three** hold:

1. The gate above passes end to end
2. The generated netlist is clean — correct connectivity, no unintended merges, and any `NC_*` nodes are pins you meant to leave open
3. The simulation runs, unless the user declined to run it

A clean netlist alone is not done, and a successful simulation alone is not done. Report the work as finished only against all three.

**Failure modes worth naming**, since each has produced a broken drawing that netlisted cleanly:

- Optimizing topology and values, then skipping the geometry pass entirely
- Rebuilding a circuit without re-checking stubs and gaps that the old layout satisfied
- Wrong rotation or mirror pin math, then "connecting somehow" with extra wire instead of moving the symbol
- Dropping a late component beside an existing one without re-measuring the 96 px spacing
- Stubbing a pin the wrong way along its axis, so the wire runs back across the part it feeds
- Emitting a ground or supply rail as one full-width segment, straight through whatever sits at that Y
- Rotating a part and re-deriving its pin coordinates but not its stub directions
- Placing a directive block or a long `Value` string by its anchor point without reserving the box the text occupies
- Placing a flag on a pin, off-wire, or mid-body instead of on a stub
- Adding a sideways spur purely to hold a net label
- Fixing only what surfaces as `NC_*` in the netlist, leaving stub violations invisible and uncorrected
- Drawing a wire that spans both pins of a two-terminal part, shorting it out
- Emitting a diagonal wire because both endpoints were correct pin coordinates and no intermediate corner was computed

### Auditing an Existing Schematic

The gate is written for a schematic you just produced. Auditing one you did not — a file edited by hand in the GUI, or generated earlier — is a different task: you are looking for symptoms rather than verifying your own arithmetic. Read the `.asc` and check for each of these.

| Symptom | What to look for in the file |
|---------|------------------------------|
| Overlapping symbols | Two `SYMBOL` origins close enough that the bodies intersect, given each part's span |
| Unintentionally open pins | `NC_*` nodes in the netlist — see the caveat below before treating any of them as a fault |
| Placeholder values | `SYMATTR Value` left as a bare `R`, `C`, `L`, or `V` — the symbol default was never filled in |
| Diagonal wires | Any `WIRE` line changing both X and Y |
| Wires across bodies | A `WIRE` whose span brackets a symbol's world keep-out box on one axis and falls inside it on the other |
| Stubs folded back | A wire leaving a pin *toward* its own symbol's keep-out box rather than away from it |
| Text on the drawing | A `TEXT`, a `WINDOW`-placed attribute, or a `FLAG` label whose reserved box lands on a body, a wire, or another string |
| Flags on pins | A `FLAG` whose coordinate equals a pin world coordinate instead of sitting on a stub |
| Stray flags | A `FLAG` at `(0,0)` or otherwise not on any wire — usually a mis-click left behind |
| Overlapping directives | Two `TEXT` elements with the same or near-identical baseline, or a `TEXT` sitting over the drawing |
| Attribute text on the body | `WINDOW` offsets that place `InstName` or `Value` inside the symbol outline |
| Routing shorts | One long wire run collecting more pins than intended — a vertical segment past a transistor picking up both collector and emitter, for instance |

**`NC_*` is not by itself an error.** LTspice invents a node name like `NC_01` for every pin with nothing attached, and plenty of pins are allowed to be left open, for example the SYNC, MODE, or PG/PGOOD pins of some power supply products. Circuits may also deliberately include unconnected pins, for example to perform an open-circuit voltage measurement or disconnect an output load.

So treat each `NC_*` as a **question**: is this pin open on purpose? Only an open pin that the topology needs connected is a defect. What makes a real one easy to spot is that it is usually accompanied by a *nearby* wire endpoint — a wire drawn to the symbol origin instead of the pin, or to a stale pin coordinate from before a rotation — rather than by no wire at all. LTspice's **Mark unconnected pins** drafting option exists to make open pins visible for review, not to flag them as wrong.

**Separate nodes that must differ.** The routing-short case is worst on high-impedance nets, where a stray connection changes the DC operating point without producing any obviously wrong-looking geometry. When two nets are meant to stay distinct — a transistor base and its collector, an op-amp input and its output — confirm in the netlist that they are two different node names, rather than trusting that the drawing separates them.

Late edits are the common origin of all of these: a part moved without re-measuring, or a wire extended to reach a new component and passing through an existing pin on the way.

---

## Wires

Wires represent electrical connections between two points.

### Syntax

```
WIRE x1 y1 x2 y2
```

### Rules

- **Wires must be orthogonal** — each `WIRE` changes X or Y, never both. A diagonal is electrically valid and LTspice will draw it, but it is the loudest visual signal that a schematic was generated rather than drawn. Route through an explicit corner point instead: two segments, `WIRE x1 y1 x2 y1` then `WIRE x2 y1 x2 y2`.
- Wires connect at their endpoints.
- When three or more wires meet at a single point, LTspice automatically creates a junction dot.
- Wire endpoints must exactly coincide with component pin locations to form connections.
- **A wire never crosses a symbol body** — it touches a symbol only at a pin, and leaves that pin outward for ≥ 48 px before turning. Crossing is not connecting, so the netlist will not report it; see [No Wire Across a Symbol Body](#no-wire-across-a-symbol-body) and [Pin Exit Stub](#pin-exit-stub).

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

### Value Notation

**Write `u` for micro, never `µ`.** This is an authoring rule for every value you emit, not merely a workaround for UTF-8-only tooling. LTspice reads `u` and `µ` identically, but `µ` is byte `0xB5` in the Windows-1252 file and is the single most common way an `.asc` gets corrupted in an edit round-trip — see [File Encoding](#file-encoding--critical). Existing `µ` characters in a file you are editing may stay as they are; anything you write should use `u`. The same reasoning applies to `Ω`: write `1k`, not `1kΩ`.

**Omit the unit suffix.** Write `1u`, not `1uF`; `10k`, not `10kΩ`; `4.7m`, not `4.7mH`. LTspice tolerates a trailing unit letter on many values, but it is redundant — the element type already determines the unit — and it becomes actively wrong when the suffix letter collides with a multiplier. `1F` reads as 1 femto, not 1 farad.

**Engineering multipliers**, case-insensitive:

| Suffix | Multiplier | Suffix | Multiplier |
|--------|-----------|--------|-----------|
| `T` | 1e12 | `m` | 1e-3 |
| `G` | 1e9 | `u` | 1e-6 |
| `Meg` | 1e6 | `n` | 1e-9 |
| `K` | 1e3 | `p` | 1e-12 |
| | | `f` | 1e-15 |
| | | `a` | 1e-18 |

**`M` is milli, not mega.** Suffixes are case-insensitive, so `1M` and `1m` both mean 1e-3, and mega must be spelled `Meg`. Writing `1M` for a 1 MΩ resistor produces a 1 mΩ resistor — a factor of 10⁹ — and the simulation runs without complaint. Likewise `1Meg` for a capacitor value, not `1MEG` or `1e6` if you want the schematic to read conventionally (all three parse).

Plain scientific notation (`1e6`, `4.7e-9`) is always accepted and is unambiguous where a multiplier would be confusing.

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

`(x1,y1)`–`(x2,y2)` is the bounding box of the **construction ellipse**; `(x3,y3)` and `(x4,y4)` are **rays from that ellipse's centre**, not points on the curve, and the sweep from the first to the second runs counterclockwise on screen. The drawn extent is usually much smaller than the bounding box, so never treat those first four numbers as a keep-out; take a symbol's box from [Standard Symbol Geometry](#standard-symbol-geometry-local-coordinates) or from `get_symbol_content`.
---

## Rotation and Mirroring

Components support 8 orientations. The `M` forms are **rotate first, then mirror horizontally** — the operations do not commute, so the order is part of the definition:

| String | Meaning                                                              |
|--------|----------------------------------------------------------------------|
| `R0`   | No rotation (default)                                                |
| `R90`  | 90 degrees clockwise                                                 |
| `R180` | 180 degrees rotation                                                 |
| `R270` | 270 degrees clockwise (90 degrees CCW)                               |
| `M0`   | Mirror horizontally                                                  |
| `M90`  | Rotate 90 degrees clockwise, **then** mirror horizontally             |
| `M180` | Rotate 180 degrees, then mirror horizontally — a net vertical flip   |
| `M270` | Rotate 270 degrees clockwise, **then** mirror horizontally            |

`M90` and `M270` are the two that punish getting the order backwards: mirroring first and *then* rotating 90 degrees produces `M270`'s geometry, and mirroring first then rotating 270 produces `M90`'s. The two orders coincide only for `M0` and `M180`.

To convert an orientation into pin coordinates, use the eight-row transform table in [Pin World-Coordinate Calculation](#pin-world-coordinate-calculation).

Mirroring changes which side each pin exits from, which in turn changes which direction its [pin exit stub](#pin-exit-stub) must run. Re-derive the stub directions after any orientation change.

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

### Every Schematic Needs an Analysis Directive

A schematic with no analysis directive will not simulate. If none is present and the intent is unclear, add `.op` (DC operating point) as the safe default before running.

Exactly one analysis directive should be active at a time. Comment the others out with a leading `;` rather than deleting them.

### AC Analysis Needs an AC Source Amplitude

`.ac` performs a small-signal analysis around the DC operating point, and it excites only sources that declare an AC amplitude. At least one source must carry `AC <amplitude>` in its value:

```
SYMATTR Value AC 1
```

`AC 1` is the conventional amplitude choice, because every node voltage then reads directly as the transfer function to that input.

### Measurement Syntax Gotchas

`.meas` is evaluated in post-processing, so its syntax is checked only at the end of a run. The AC magnitude form trips people up constantly:

```spice
.meas AC fc WHEN db(V(Vout))=-3
```

| Wrong | Why |
|-------|-----|
| `.meas AC fc WHEN VdB(Vout)=-3` | `VdB()` is not a function |
| `.meas AC fc WHEN db(Vout)=-3` | missing the `V()` wrapper |
| `.meas AC fc WHEN V(Vout)dB=-3` | not valid syntax |

AC analysis returns complex values; `db()` takes the magnitude and converts it to decibels, so the voltage must be wrapped in `V()` *inside* `db()`.

Prefer `.meas` output in the log over reading raw waveform data when all you need is a scalar.

---

## Design Best Practices

1. **Always include a ground node**: Every circuit must have at least one `FLAG x y 0`.

2. **Name important nets**: Use descriptive flag names (`IN`, `Vout`, `VCC`) for nodes you want to probe or reference.

3. **Align to grid**: Place all components and wire endpoints on the 16-unit grid to ensure proper connectivity.

4. **Use orthogonal wires**: Every `WIRE` changes X or Y, never both. Scanning the file for lines where `x1 != x2 && y1 != y2` catches this mechanically.

5. **One analysis command per simulation**: While multiple can exist, only the active (uncommented) analysis runs.

6. **Place analysis commands at the bottom**: Convention is to put `.tran`, `.ac`, etc. below the circuit.

7. **Verify connectivity**: Ensure wire endpoints touch component pins exactly. Misaligned connections are a common source of errors.

8. **Use hierarchical design for complex circuits**: Break large designs into subcircuit blocks with I/O pins.

9. **Never span a two-terminal part with a single wire**: A segment running from one pin to the other shorts the component while looking entirely normal on screen.

10. **Check the generated netlist, not just the drawing**: Look for two nets that unexpectedly merged, and for `NC_*` nodes on pins that were supposed to be connected. Not every `NC_*` is a fault — substrate and bulk pins, unused subcircuit pins, and deliberately open nodes all produce one.

11. **Apply the [Layout Quality Rules](#layout-quality-rules)**: Connectivity is the floor, not the finish line. Run the [post-edit layout gate](#post-edit-layout-gate) after any geometry change.

12. **Write values in ASCII with no unit suffix**: `1u`, `10k`, `4.7n` — and `Meg`, never `M`, for mega. See [Value Notation](#value-notation).

13. **Draw the signal left to right**: Source at the left, output at the right, ground on a bus underneath. See [Composition Conventions](#composition-conventions).
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

**Connectivity**

- [ ] Start with `Version 4.1` and `SHEET 1 width height`
- [ ] Place wires to connect component pins (endpoints must align exactly)
- [ ] Add at least one ground flag (`FLAG x y 0`)
- [ ] Place all required symbols with proper rotation
- [ ] Set `SYMATTR InstName` for every component
- [ ] Set `SYMATTR Value` for components that need values, using `u` not `µ` and no unit suffix
- [ ] Add at least one analysis command as a `TEXT` element with `!` prefix
- [ ] For `.ac`, at least one source carries an `AC <amplitude>` term
- [ ] Verify all wire endpoints connect to pins (misalignment = open circuit)
- [ ] Confirm no wire spans both pins of a two-terminal part (silent short)

**Layout** — see [Layout Quality Rules](#layout-quality-rules)

- [ ] No `WIRE` line changes both X and Y (no diagonals)
- [ ] Every pin has a ≥ 48 px exit stub in the pin's own direction
- [ ] No perpendicular bus or net label lands directly on a pin
- [ ] Adjacent pin columns/rows are ≥ 96 px apart
- [ ] Only a vertical wire touches each `FLAG ... 0`
- [ ] Every `FLAG` sits on a wire ≥ 48 px from its pin
- [ ] Signal flows left to right; grounds collect on a bus below the circuit
- [ ] The SPICE `TEXT` block is below the circuit, non-overlapping, and inside the sheet
- [ ] Generated netlist shows no accidental shorts, and every `NC_*` node is a pin left open on purpose
- [ ] **Re-run this list after any late addition** — adding one part invalidates it

Then apply the [definition of done](#definition-of-done): checklist, clean netlist, and a completed simulation.

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
- Before editing an unfamiliar schematic, walk [Auditing an Existing Schematic](#auditing-an-existing-schematic) — inherited defects are easy to mistake for your own after a change, and easy to blame on your change when they predate it.
- Any edit in the "Move", "Add", "Delete", or "Rotate" rows above is a geometry change and requires the [post-edit layout gate](#post-edit-layout-gate). Value and analysis edits do not.

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
