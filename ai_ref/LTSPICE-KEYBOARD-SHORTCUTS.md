---
title: LTspice Keyboard Shortcuts Reference
description: Keyboard shortcuts for all LTspice operations on Windows, based on the official LTspice cheat sheet.
version: "24+"
last_modified_at: 2026-05-14
---

[← AI Reference](README.md)

# LTspice Keyboard Shortcuts Reference

*Last updated: 2026-05-14*  
*LTspice version: 24+*

Complete keyboard shortcuts for Windows. Based on the official LTspice keyboard shortcut cheat sheet.

**Official cheat sheet (PDF):** [standard](https://www.analog.com/media/en/news-marketing-collateral/solutions-bulletins-brochures/ltspice-keyboard-shortcuts.pdf) · [ink saver](https://www.analog.com/media/en/news-marketing-collateral/solutions-bulletins-brochures/ltspice-keyboard-shortcuts-ink-saver.pdf) (print-friendly)


---

## Place Components

| Icon | Shortcut | Action |
|------|----------|--------|
| <img src="images/toolbar/Wire.png" alt="Wire" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | W | Wire |
| <img src="images/toolbar/Ground.png" alt="Ground" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | G | Ground |
|  | Alt+G | Com |
| <img src="images/toolbar/Voltage.png" alt="Voltage Source" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | V | Voltage source |
| <img src="images/toolbar/Resistor.png" alt="Resistor" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | R | Resistor |
| <img src="images/toolbar/Capacitor.png" alt="Capacitor" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | C | Capacitor |
| <img src="images/toolbar/Inductor.png" alt="Inductor" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | L | Inductor |
| <img src="images/toolbar/Diode.png" alt="Diode" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | D | Diode |
| <img src="images/toolbar/Component.png" alt="Component" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | P | Component (opens component dialog) |
| <img src="images/toolbar/Label%20Net.png" alt="Label Net" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | N | Label net |
| <img src="images/toolbar/Text.png" alt="Text" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | T | Text/comment |
| <img src="images/toolbar/Spice%20Directive.png" alt="Spice Directive" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | . | SPICE directive (right-click text field to open "Help me Edit" dialog) |
|  | B | Bus tap |
|  | Shift+left-click | Toggle directive/comment |

*Press Esc or right-click to exit mode.*

---

## General Editing

| Icon | Shortcut | Action |
|------|----------|--------|
| <img src="images/toolbar/Delete.png" alt="Delete" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Ctrl+X | Delete |
| <img src="images/toolbar/Delete.png" alt="Delete" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Del | Delete |
| <img src="images/toolbar/Delete.png" alt="Delete" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Backspace | Delete |
| <img src="images/toolbar/Copy.png" alt="Duplicate" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Ctrl+C | Copy/duplicate* |
| <img src="images/toolbar/Move.png" alt="Move" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | M | Move* (select components to move) |
| <img src="images/toolbar/Stretch.png" alt="Stretch" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | S | Stretch* (select anchor points to move) |
| <img src="images/toolbar/Rotate.png" alt="Rotate" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Ctrl+R | Rotate |
| <img src="images/toolbar/Mirror.png" alt="Mirror" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Ctrl+E | Mirror |
| <img src="images/toolbar/Zoom%20In.png" alt="Zoom Area" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Z | **Schematic:** zoom area (drag over area), zoom in (click on scheme)<br>**Waveform:** zoom area is default mode |
| <img src="images/toolbar/Zoom%20Out.png" alt="Zoom Out" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Shift+Z | Zoom out |
| <img src="images/toolbar/Zoom%20to%20Fit.png" alt="Zoom Fit" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Space | Zoom to fit, zoom extents |
|  | Ctrl+G | Toggle grid |
| <img src="images/toolbar/Undo.png" alt="Undo" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Ctrl+Z | Undo |
| <img src="images/toolbar/Redo.png" alt="Redo" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Ctrl+Shift+Z | Redo |

*Choose mode first, then select component or waveform title.*  
*Press Esc or right-click to exit mode.*

---

## Waveform Viewing

Mouse actions are on label of waveform trace.

| Shortcut | Action |
|----------|--------|
| click or C | Add cursor and see measure |
| L | Label current cursor position |
| Shift+C or Esc | Clear all cursors |
| Alt+click | Highlight corresponding net in schematic |
| Ctrl+click | Integrate |
| drag | Move trace (to another pane) |
| drag, hold Ctrl | Copy trace (to another pane) |
| A | Add trace |
| P | Add pane above |
| B | Add pane below |
| U | Move active pane up |
| D | Move active pane down |
| Shift+S | Select steps |

*Click in waveform pane to apply keyboard functions to active frame.*

---

## Waveform Pan & Cursor

### No Cursors

| Shortcut | Action |
|----------|--------|
| ← → ↑ ↓ | Navigate |

### Cursor Present

| Shortcut | Action |
|----------|--------|
| ← → | Snap cursor to next time data point |
| ↑ ↓ | Cycle cursors through traces at current time data point |
| Shift+← → | Snap cursor to next data point<br>*Zoom-in ~50% when no cursors* |
| Ctrl or Shift+← → | Bump cursor 10 data points |
| Ctrl+Shift+← → | Bump cursor 100 data points |

### Mouse Panning

| Shortcut | Action |
|----------|--------|
| Ctrl | Pan with mouse |
| Ctrl+Shift | Pan left and right with mouse |
| Ctrl+Alt | Pan up and down with mouse |

---

## Schematic Options

| Shortcut | Action |
|----------|--------|
| hold Ctrl | Place angled wires |
| hold Ctrl | Draw shapes off grid |
| Ctrl+Shift+Alt+U | Show hidden text (e.g., parallel or series resistance) |
| Ctrl+U | Show/hide unconnected marks |
| Ctrl+A | Show/hide text anchor marks |

*Most options available in Settings.*

---

## Probe Schematic

*Probes available once simulation is running.*

| Icon | Shortcut | Action | What it Does |
|------|----------|--------|--------------|
| <img src="images/cursors/Probe%20Red.png" alt="Probe Voltage" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | click | **Probe Wire** | Plot voltage |
| <img src="images/cursors/CurrentProbeLeft.png" alt="Probe Current" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | click | **Probe Component** | Plot current |
| <img src="images/cursors/CurrentProbeLeft.png" alt="Probe Wire Current" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Alt+click | **Probe Wire** | Plot current |
| <img src="images/cursors/ProbeTemp.png" alt="Probe Power" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Alt+click | **Probe Component** | Plot instantaneous power |
|  | drag net-to-net | | Plot differential voltage |

---

## Edit Text & Component Parameters

| Action | Text | Component Body |
|--------|------|----------------|
| right-click → | Edit with helper if available | Edit limited parameters |
| Ctrl | Edit directly | Edit all parameters |

*Text preceded by an underscore, e.g., "_FAULT" is displayed with an overbar, "FAULT".*

---

## Simulator

| Icon | Shortcut | Action |
|------|----------|--------|
| <img src="images/toolbar/Simulator%20Settings.png" alt="Configure Analysis" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | A | Configure analysis |
| <img src="images/toolbar/Run.png" alt="Run Pause" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Alt+R | Run/pause |
| <img src="images/toolbar/Stop.png" alt="Stop" width="20" style="background:#fff;padding:2px;border-radius:3px;vertical-align:middle"> | Alt+S | Stop |
|  | Ctrl+L | View SPICE log |
|  | 0 | Reset sim waveform T = 0 |

*Schematics can be edited even as a simulation runs.*  
*Edits affect subsequent simulations.*

---

## Notes

- **Customization**: Keyboard shortcuts can be customized via Help > Keyboard Shortcut Cheat Sheet > Edit Keyboard Shortcuts
- **Platform**: This reference is for Windows v24+ and Mac v26+
- **Version-specific**: Shortcuts may vary between LTspice versions
- **Exit modes**: Press Esc or right-click to exit most editing modes
- **Context-sensitive**: Some shortcuts only work in specific contexts (schematic vs. waveform viewer)

---

## Related Documentation

- [LTSPICE-MENU-REFERENCE.md](LTSPICE-MENU-REFERENCE.md) — Complete menu hierarchy and shortcuts
- [LTSPICE-QUICKSTART.md](LTSPICE-QUICKSTART.md) — Getting started guide
- [WAVEFORM-VIEWER-GUIDE.md](WAVEFORM-VIEWER-GUIDE.md) — Detailed waveform viewer documentation
  

---

*Documentation source: [github.com/analogdevicesinc/ltspice-reference](https://github.com/analogdevicesinc/ltspice-reference)*

