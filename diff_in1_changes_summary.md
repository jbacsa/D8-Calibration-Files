# diff_in1.cnf Update Summary

Source: DEVICE.INI dated 03/07/2007 (Ping Yang), referenced against the 2006 diff_in1.cnf.

## Changes applied

| Section | Parameter | Old value | New value |
|---|---|---|---|
| Water Cooling Unit | fXFlowSensorConversionFactor | 0.0028 | 0.0029 |
| Detector 1 (Scintillation) | fHighVoltage | 822.6 | 679.2 |
| Detector 1 (Scintillation) | fDiscrim1LowerLevel | 0.788 | 0.298 |
| Detector 1 (Scintillation) | fDiscrim1WindowWidth | 1.078 | 1.176 |
| Drive 1 (Theta) | fReferencePosition | 19.8658 | 20.1178 |
| Drive 1 (Theta) | fLowerLimit | -2 | -5 |
| Drive 1 (Theta) | fUpperLimit | 60 | 66 |
| Drive 1 (Theta) | fFastSpeed | 400 | 200 |
| Drive 2 (2Theta) | fReferencePosition | 23.3148 | 22.4031 |
| Drive 2 (2Theta) | fLowerLimit | -2 | -10 |
| Drive 2 (2Theta) | fUpperLimit | 120.1 | **120.1 (preserved per your instruction)** |
| Drive 3 (Phi) | fLowerLimit | -190 | -360 |
| Drive 3 (Phi) | fUpperLimit | 190 | 360 |
| Drive 5 (X-Drive) | fReferencePosition | -41.438 | 41.049 (sign flipped) |
| Drive 5 (X-Drive) | fSlowSpeed | 5 | 2 |
| Drive 5 (X-Drive) | uConfX | 9360 | 9560 |
| Drive 6 (Y-Drive) | fReferencePosition | -40.618 | 41.023 (sign flipped) |
| Drive 6 (Y-Drive) | fSlowSpeed | 5 | 2 |
| Drive 6 (Y-Drive) | uConfX | 9360 | 9560 |
| Drive 7 (Z-Drive) | fReferencePosition | -1.2712 | -2.1713 |
| Drive 7 (Z-Drive) | fLowerLimit | -1.6 | -2 |
| Drive 7 (Z-Drive) | fUpperLimit | 2.6 | 3 |
| Drive 7 (Z-Drive) | fFastSpeed | 1 | 0.2 |
| Drive 7 (Z-Drive) | fAccelerationTime | 0.2 | 0.6 |
| Drive 7 (Z-Drive) | fMoveLimit | 10 | 5 |

## Changes NOT applied (intentionally)

1. **Drive 2 (2Theta) upper limit kept at 120.1** instead of the DEVICE.INI value of 66, per your instruction. This preserves the full 2-theta scan range.
2. **Zoom drive (microscope) not added.** DEVICE.INI has a Zoom drive on AIB2 that the .cnf does not include. Adding it cleanly requires the Configuration Program GUI to assign drive number and AIB slot correctly.
3. **Drive 4 (Chi/Psi)** values matched between both files, so nothing changed.
4. **Drive 8 (Divergence Slit) and Drive 9 (Antiscattering Slit)** were not in DEVICE.INI, so they retain their original .cnf values.
5. **TCP addresses (192.168.23.2 ports 4250/4251)** unchanged: the detector still lives where it lived.
6. **VANTEC calibration polynomial** unchanged: the 72-point calibration in [Position Sensitive Detector] is preserved exactly.

## Things to verify when loading on the instrument

1. **X-Drive and Y-Drive sign flip:** before any aggressive moves, jog X and Y at slow speed in both directions and confirm the motion direction matches what you expect from the GUI controls. If a positive command moves the stage the wrong way, the sign convention in the firmware does not match the .cnf and you will need to revert these two reference positions.

2. **Drive 1 (Theta) lower limit of -5:** allow negative Theta further than before. Confirm there is no physical interference at negative Theta before homing.

3. **Drive 7 (Z-Drive) lower limit of -2:** also extended. Verify clearance.

4. **Scintillation counter HV change from 822.6 V to 679.2 V** is substantial. This may have been a deliberate adjustment for a different operating point, or it may be wrong for the current tube/detector combination. If the discriminator window does not show a clear photopeak after this change, you may need to re-tune.

5. **The Configuration Program may flag the iDeviceCRC=CCCD value** as mismatched against the actual hardware. This is not driven by DEVICE.INI; it is the controller's fingerprint and would need separate verification with Bruker or by reading what the controller reports.
