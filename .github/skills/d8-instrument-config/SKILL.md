---
name: d8-instrument-config
description: Diagnose and repair Bruker D8 diffractometer configuration and alignment, covering CNF and DEVICE.INI files, the D8 Config and Commander utilities, angular zero setting, detector mode selection, and safe reloading of configuration onto the instrument. Use for any D8 hardware, alignment, or controller configuration work.
---

# Bruker D8 configuration and alignment

Instrument in scope is a Bruker D8 Discover with a Co tube, a VANTEC-1 position
sensitive detector, Gobel mirrors, and a four-circle Eulerian cradle. The
controller boots from a floppy disk under PTS-DOS, so the configuration lives
partly on legacy media and the instrument PC is off network.

Software: D8 Commander, the D8 Config utility, D8 Tools, DIFFRAC.SUITE.

## Diagnostic principles

**A large Z offset is a symptom, not a cause.** When Z has to be driven far from
zero before diffraction appears, suspect angular zero errors before assuming a
genuine sample height problem. The geometry is

```
delta_2theta ~= -2s * cos(theta) / R
```

Confirm the diagnosis by checking that Z collapses back toward zero once the
angular zeros are corrected.

**Restore 0D before setting any zeros.** In 1D mode the VANTEC-1 centroid
conflates the goniometer 2theta zero with the detector reference-channel offset,
so the two cannot be separated. The 0D scintillation counter separates them.

A scintillation counter showing `sStatus=not used` in the Detector Interface
Board and Detector blocks of the CNF has been deactivated. This produces a
characteristic asymmetric fault where 1D still works and 0D does not.

**Zero on the Kalpha1 peak only.** The Gobel mirror resolves the Kalpha1 and
Kalpha2 doublet at roughly a 2 to 1 intensity ratio, so zeroing on Kalpha2
introduces a systematic error.

## Never hand-edit configuration files

Do not open CNF or DEVICE.INI in Notepad. UAC VirtualStore redirection and UTF-8
BOM encoding cause silent write failures, where the edit appears to save and has
no effect on the instrument.

Import and re-save through the D8 Config utility, which regenerates the CNF and
DEVICE.INF together and keeps them consistent.

| File | Holds |
| --- | --- |
| `DEVICE.INI` | Axis reference values and zeros |
| CNF detector blocks and `DEVICE.INF` | Detector mode availability, managed by D8 Config |

Phantom hardware, meaning hardware declared in configuration but physically
absent, must be removed from both DEVICE.INI and the CNF, and the removal must
propagate through D8 Config or the two fall out of sync.

## Recovery sequence for a lost configuration

1. Restore 0D via D8 Config by re-enabling the scintillation counter, then
   re-save so the CNF and DEVICE.INF regenerate together.
2. Set the 2theta zero in 0D mode on the direct beam.
3. Correct the theta zero using the Positioning Drives page.
4. Confirm the zeros are written to the floppy DEVICE.INI and survive a reboot.
5. Verify that Z collapses toward zero.

## Method

Diagnose by systematic file diffing before changing anything. Comparing a
current CNF against a known-good one has repeatedly located root causes,
including shifted `fThetaFZeroOffset` and `fZeroOffset1` values, deactivated
detectors, deactivated motorised slit drives, and generator defaults dropped to
standby values.

**Beware old DEVICE.INI imports.** A 2007-era import corrupted the reference
positions on this instrument. Always check the date and provenance of a
DEVICE.INI before importing it, and check the recorded values against the lab
notebook rather than assuming the file is authoritative.

Preserve diagnostic state in a Markdown handoff document so context survives
across sessions and interruptions.

## Before loading a changed configuration on the instrument

Configuration changes can drive hardware into itself. Work through this before
any aggressive moves.

- **Sign-flipped reference positions on X and Y drives.** Jog both at slow speed
  in each direction and confirm the motion matches the GUI controls. If a
  positive command moves the stage the wrong way, the firmware sign convention
  does not match the CNF and those reference positions must be reverted.
- **Extended lower limits**, for example theta to -5 or Z to -2. Confirm there is
  no physical interference at the new travel before homing.
- **Large detector high voltage changes.** A shift of the order of 820 V to 680 V
  is substantial. It may be a deliberate operating point for a different tube and
  detector combination, or it may be wrong for the current one. If the
  discriminator window shows no clear photopeak afterwards, re-tune.
- **`iDeviceCRC` mismatch warnings** from the Configuration Program are not
  driven by DEVICE.INI. That value is the controller's own fingerprint and needs
  separate verification against what the controller reports.

Preserve deliberately: the VANTEC calibration polynomial in the
`[Position Sensitive Detector]` block, which is a 72-point calibration, and the
detector TCP addresses. Neither should be regenerated casually.

## Repository conventions

This repository is a **public archive of working configuration**, not code.

- Treat committed configuration as a restore point. Add new captures alongside
  the old rather than overwriting, following the existing pattern of suffixed
  variants such as `-original`, `-edit`, and `-wont-boot`.
- The `-wont-boot` variant is kept deliberately as a negative example. Do not
  delete it.
- Record what changed and why in a summary document, including changes
  considered and rejected, since the reasoning is the valuable part.
- **This repository is public.** Do not commit names, email addresses, service
  contact details, network credentials, or site-specific information beyond what
  the instrument configuration itself requires.
