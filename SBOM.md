# Software Bill of Materials (BOM)

**Project**: LTspice Reference Documentation  
**Version**: 1.0.0-ga  
**Date**: 2026-06-02  
**Copyright**: Copyright 2026 Analog Devices, Inc.  
**License**: Apache License 2.0

---

## 1. Project Overview

Comprehensive reference documentation for LTspice, including markdown-formatted guides optimized for AI assistants and human users.

---

## 2. Documentation Files

### Root Level

| File | Purpose | Format |
|------|---------|--------|
| README.md | Project overview and navigation | Markdown |
| LICENSE.md | Apache License 2.0 full text | Markdown |
| BOM.md | Software Bill of Materials (this file) | Markdown |
| .gitignore | Git exclusion rules | Text |

### AI Reference Documentation (`ai_ref/`)

| File | Purpose | Lines | Format |
|------|---------|-------|--------|
| README.md | AI reference overview and setup instructions | 181 | Markdown |
| README_TOP.md | Brief AI assistant entry point | 3 | Markdown |
| LTSPICE-QUICKSTART.md | Installation and basic workflow guide | 217 | Markdown |
| LTSPICE-KEYBOARD-SHORTCUTS.md | Complete keyboard shortcuts reference | 181 | Markdown |
| LTSPICE-MENU-REFERENCE.md | Menu hierarchy and access keys | 232 | Markdown |
| SPICE-SYNTAX-REFERENCE.md | Netlist syntax and conventions | 193 | Markdown |
| CIRCUIT-ELEMENTS-REFERENCE.md | Component syntax and parameters | 834 | Markdown |
| SIMULATION-COMMANDS-REFERENCE.md | Dot commands and directives | 755 | Markdown |
| TROUBLESHOOTING-GUIDE.md | Convergence and performance solutions | 388 | Markdown |
| SCHEMATIC-REFERENCE.md | .asc file format and editing | 753 | Markdown |
| WAVEFORM-VIEWER-GUIDE.md | Waveform analysis and export | 309 | Markdown |
| DEVICE-MODELS-GUIDE.md | Device models and third-party integration | 273 | Markdown |
| MEASURE-DATABASE-REFERENCE.md | .MEAS SQLite database schema | 197 | Markdown |
| MEAS-REFERENCE.md | .MEAS statement examples | 753 | Markdown |
| FAQ-AND-TIPS.md | Frequently asked questions and tips | 239 | Markdown |

**Total Documentation Files**: 19  
**Total Documentation Lines**: ~5,500

---

## 3. LTspice Software Coverage

This documentation covers:

| Software | Version | Vendor | License | Notes |
|----------|---------|--------|---------|-------|
| LTspice | 24+ (Windows)<br>26+ (Mac) | Analog Devices, Inc. | Proprietary | Free SPICE simulator - documentation subject, not included in this repository |

**Compatibility**: Documentation written for LTspice versions released 2024 and later.

**Platform Coverage**: 
- Primary: Windows 11
- Secondary: macOS (menu/keyboard differences noted)
- Tertiary: Linux via WINE (installation instructions provided)

---

## 4. Tools and Dependencies

### Development Tools

| Tool | Purpose | Version | License | Required |
|------|---------|---------|---------|----------|
| Text Editor | Markdown editing | Any | Various | Yes |
| Git | Version control | 2.x+ | GPL-2.0 | Recommended |
| Markdown Renderer | Documentation preview | Any | Various | Optional |

### Reference Sources

| Source | Type | Usage |
|--------|------|-------|
| LTspice Help Documentation | Built-in help | Reference for accuracy verification |
| LTspice Example Circuits | `.asc` files | Syntax and usage examples |
| Analog Devices EngineerZone | Community forum | Community best practices |

---

## 5. External References

Documentation includes references to:

| Resource | URL | Type |
|----------|-----|------|
| Analog Devices LTspice | https://www.analog.com/ltspice | Official product page |
| EngineerZone LTspice Forum | https://ez.analog.com/design-tools-and-calculators/ltspice/ | Community support |
| LTspice Users Group | https://groups.io/g/LTspice | Independent community |
| LTpowerCAD | https://www.analog.com/en/design-center/ltpowercad.html | Related tool |

---

## 6. Third-Party Content

### Attributions

This documentation references concepts and syntax from:
- **Berkeley SPICE** - SPICE simulation concepts (University of California)
- **LTspice Built-in Help** - Command syntax and parameter definitions (Analog Devices)
- **LTspice Change Logs** - Version-specific features (Analog Devices)

### No External Code Dependencies

This project contains **documentation only** - no executable code, libraries, or runtime dependencies.

---

## 7. File Encoding

| File Type | Encoding | Notes |
|-----------|----------|-------|
| `.md` files | UTF-8 | All documentation files |
| `.asc` references | Windows-1252 | LTspice schematic format (external) |

**Important**: Documentation describes Windows-1252 encoding for `.asc` files but does not include any `.asc` files in this repository.

---

## 8. Compliance Notes

- **License**: Apache License 2.0 - permissive open source
- **Copyright**: Analog Devices, Inc.
- **Patent Grant**: Included via Apache 2.0 Section 3
- **Trademarks**: "LTspice" is a trademark of Analog Devices, Inc.
- **Export Control**: EAR99 (same as LTspice software)

---

## 9. Version History

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0-ga | 2026-06-02 | Initial release |

---

**Generated**: 2026-06-02  
**Maintained by**: Analog Devices, Inc.
