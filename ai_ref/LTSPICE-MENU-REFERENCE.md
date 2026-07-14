---
title: LTspice Menu Reference
description: Complete hierarchical listing of all menu options, access keys, and context menus in LTspice.
version: "24+"
last_modified_at: 2026-05-14
---

[← AI Reference](README.md)

# LTspice Menu Reference

*Last updated: 2026-05-14*  
*LTspice version: 24+*

Complete hierarchical listing of all menu options and keyboard shortcuts.


## Menu Access Keys

Menus can be accessed via Alt+[letter]:
- **Alt+F** = File
- **Alt+E** = Edit  
- **Alt-I** = Hierarchy
- [] = View
- [] = Simulate
- **Alt+T** = Tools
- **Alt+P** = Plot Settings (Waveform Viewer)
- **Alt+W** = Window
- **Alt+H** = Help

Within each menu, underlined letters (mnemonics) can be pressed directly without Alt.

**Example**: To access File > New Schematic:
- Press Alt+F (opens File menu), then press N
- Or use the direct shortcut: Ctrl+N


## File Menu (Alt+F)

- **New Schematic** (Ctrl+N) — Create new blank schematic
- **New Symbol** — Create new component symbol
- **Open** (Ctrl+O) — Open schematic, netlist, or waveform file
- **Open Examples...** — Browse built-in example circuits
  - Educational/ — Analysis examples
  - Applications/ — ADI product circuits
- **New Library**
  - Capacitor
  - Inductor
  - Resistor
- **Save** (Ctrl+S) — Save current file
- **Save As...** (Ctrl+Shift+S) — Save with new filename
- **Close** (Ctrl+W) — Close current file
- **Print** (Ctrl+P)
- **Print Preview** (V)
- **Print Monochrome** (M) — Toggle: Print schematics in black and white
- **Recent Files** (submenu)
- **Exit** (X) — Close LTspice


## Edit Menu - Available when .ASC file is active

- **Undo** (Ctrl+Z) — Reverse last action
- **Redo** (Ctrl+Shift+Z) — Reapply last undone action
- **Text** (T) - Add text comment to schematic
- **SPICE Directive** (.) - Add SPICE directive to schematic
- **Configure SPICE Analysis** (A) - Opens Configure Analysis Dialog
- **Resistor** (R) - Add resistor to schematic
- **Capacitor** (C) - Add capacitor to schematic
- **Inductor** (L) - Add inductor to schematic
- **Diode** (D) - Add diode to schematic
- **Component** (P) - open component dialog
- **Rotate** (Ctrl+R) - Rotate selected
- **Mirror** (Ctrl+E) - Mirror selected
- **Draw Wire** (W) - Draw wire segment
- **Label Net** (N) - Add Label to a Net
- **Place GND** (G) - Place Ground Component
- **Place Bus Tap** (B) - Place bus tap
- **Delete** (Backspace or Delete or Ctrl+X)
- **Duplicate** (Ctrl+C) — Clone selected component
- **Move** (M) — Enter move mode
- **Stretch** (S) — Move with connected wires
- **Paste** (Ctrl+V) - Paste copied elements
- **Draw → ...**
  - **Line**
  - **Rectangle**
  - **Ellipse**
  - **Arc**
  - **Line Style** - open line style dialog


## View Menu - When Schematic Window is active

- **Zoom Area** (Z) — Drag to define zoom region
- **Zoom Back** (Shift+Z) — Zoom out
- **Zoom to Fit** (Space) — Fit entire schematic in window
- **Recenter** — Center view on schematic origin
- **Show Grid** (Ctrl+G) — Toggle grid visibility
- **Mark Unconn. Pins** (Ctrl+U) — Highlight unconnected component pins
- **Mark Anchors** (Ctrl+A) — Show anchor points for text/components
- **Bill of Materials** (submenu) — Generate component list
- **Efficiency Report** (submenu) — Power conversion efficiency analysis
- **Update and View SPICE Netlist** — Regenerate and display netlist
- **SPICE Output Log** (Ctrl+L) — Show simulation messages and errors
- **Visible Traces** — Select which waveforms to display
- **Autorange Y-axis** — Auto-scale vertical axis
- **Marching Waves** (submenu) — Animated waveform display options
- **Set Probe Reference** — Define voltage measurement reference node
- **Toolbar** (checkmark) — Toggle toolbar visibility
- **Status Bar** (checkmark) — Toggle status bar visibility
- **Window Tabs** (checkmark) — Toggle window tab display


## View Menu - When Waveform Viewer Window is active

- **Zoom Area** (Z) — Drag to define zoom region
- **Zoom Back** (Shift+Z) — Zoom out
- **Zoom to Fit** (Space) — Fit entire waveform in window
- **Recenter** — Center view on waveform
- **SPICE Output Log** (Ctrl+L) — Show simulation messages and errors
- **FFT** — Plot FFT
- **Toolbar** — Toggle toolbar visibility
- **Status Bar**  — Toggle status bar visibility
- **Window Tabs**  — Toggle window tab display



## Simulate Menu - Available when .ASC file is active

- **Run/Pause** (Alt+R) — Execute simulation
- **Stop** (Alt+S) — Halt running simulation
- **Efficiency Calculation** (submenu)
  - **Mark Start** — Begin efficiency calculation region
  - **Mark End** — End efficiency calculation region
- **Settings**
- **Configure Analysis** (A) - Opens Configure Analysis Dialog


## Tools Menu

- **Copy bitmap to Clipboard** — Copy schematic or waveform as bitmap image
- **Write image to .emf file** — Export as Enhanced Metafile
- **Settings** — Open comprehensive settings dialog
  - **Compression** tab
  - **Save Defaults** tab
  - **SPICE** tab
  - **Schematic** tab
  - **Netlist** tab
  - **Search Paths** tab
  - **Waveforms** tab
  - **Operation** tab
  - **Hacks** tab
  - **Internet** tab
- **Color Preferences** — Customize UI colors dialog
  - Schematic colors
  - Waveform colors
  - Netlist editor colors
- **Update components** — Download latest component models and libraries from Analog Devices
  - Shows date of last successful update
  - Use to ensure you have the newest component models
  - Recommended before troubleshooting model-related issues or FRA problems
- **Export Netlist** — Generate netlist for PCB layout


## Plot Settings Menu (Waveform Viewer)

- **Visible Traces** — Select which waveforms to display
- **Add trace** (A) — Add new waveform to plot
- **Delete Traces** (Backspace or Del) — Remove selected waveforms
- **Select Steps** (Shift+S) — Choose which parameter steps to display
- **Place Cursor on Active Trace** (C) — Position cursor on selected waveform
- **Clear All Cursors** (Shift+C or Esc) — Remove all measurement cursors
- **Redraw** (F5) — Refresh waveform display
- **Add Plot Pane Above Active Pane** (P) — Insert new plot pane above
- **Add Plot Pane Below Active Pane** (B) — Insert new plot pane below
- **Move Active Pane Up** (U) — Reorder plot panes upward
- **Move Active Pane Down** (D) — Reorder plot panes downward
- **Delete Active Pane** — Remove current plot pane
- **Sync. Horiz. Axes** (checkmark) — Synchronize time/frequency axis across panes
- **Grid** (Ctrl+G) (checkmark) — Toggle grid visibility
- **Reset Colors** — Restore default trace colors
- **Mark Data Points** — Show simulation data points on waveforms
- **Eye Diagram** (submenu) — Eye diagram display options
- **Undo** (Ctrl+Z) — Reverse last plot change
- **Redo** (Ctrl+Shift+Z) — Reapply last undone change
- **Autorange Y-axis** (Ctrl+Y) — Auto-scale vertical axis
- **Manual Limits** — Set custom axis ranges
- **Autoranging** (checkmark) — Enable/disable automatic axis scaling
- **Notes & Annotations** (submenu) — Add text and markup to plots
- **Save Plot Settings As...** — Store current plot configuration
- **Open Plot Settings File...** (O) — Load saved plot configuration
- **Reload Plot Settings** (Ctrl-Space)
- **Edit Plot Defs File**



## Window Menu - Available when any window is open

- **Tile Horizontally** — Arrange windows side-by-side horizontally
- **Tile Vertically** — Arrange windows stacked vertically
- **Cascade** — Arrange windows in overlapping cascade
- **Close Everything** — Close all open windows
- **Arrange Icons** — Organize minimized window icons
- **[Numbered list of open windows]** — Switch to specific window (checkmark indicates active window)


## Help Menu

- **LTspice Help** (F1) — Open help documentation
- **Keyboard Shortcut Cheat Sheet** — Always-on-top shortcut reference
  - **Edit Keyboard Shortcuts** button — Customize shortcuts
- **Open Examples...** — Browse example circuits
- **Get Support on EngineerZone** — Access Analog Devices community forum
- **Go to Analog.com** — Open Analog Devices website
- **Go to myAnalog** — Access myAnalog portal
- **Show Model Change Log** — Component/model update history
- **Show LTspice Change Log** — Program version history
- **Check for LTspice updates...** — Download latest program version
- **About LTspice** — Version and license information



## Symbol Editor Menu (When .asy file is open)

### Edit Menu
- **Undo** (Ctrl+Z) — Reverse last action
- **Redo** (Ctrl+Shift+Z) — Reapply last undone action
- **Attributes** (submenu) — Symbol attribute settings
  - **Edit Attributes** — Set symbol properties
  - **Attribute Window** — Visibility settings
- **Add Pin/Port** (P) — Create symbol pin
- **Move** (M) — Move selected element
- **Stretch** (S) — Stretch/resize element
- **Rotate** (Ctrl+R) — Rotate selected element
- **Mirror** (Ctrl+E) — Mirror selected element
- **Delete** (Backspace or Del) — Delete selected element
- **Duplicate** (Ctrl+C) — Clone selected element


## Notes

- **Customization**: Keyboard shortcuts can be customized via Help > Keyboard Shortcut Cheat Sheet > Edit Keyboard Shortcuts
- **Context-sensitive**: Some menu items only appear in specific contexts (schematic vs. waveform viewer vs. symbol editor)
- **Platform**: This reference is for Windows version
- **Version-specific**: Menu options may vary between LTspice versions

---

*Documentation source: [github.com/analogdevicesinc/ltspice-reference](https://github.com/analogdevicesinc/ltspice-reference)*
