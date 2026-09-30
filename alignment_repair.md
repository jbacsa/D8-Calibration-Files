# D8 alignment repair

Handoff record for restoring the angular zeros and sample height. Update the
status line and the record tables as work proceeds, and keep superseded entries
rather than deleting them.

**Status (2026-09-30):** file diagnosis complete. The configuration has not yet
been regenerated and the zeros have not yet been measured. The latest alignment
results, saved on the instrument PC, have not yet been reviewed here.

## Instrument

D8 with a θ/θ goniometer (A20, 250 mm radius from `fDiameter=500`), Co tube
(Kα1 1.78897 Å in the CNF), Göbel mirror, VANTEC-1 PSD on TCP, scintillation
counter on detector interface board base 140, and a quarter cradle with Phi,
Psi (Chi in the CNF), X, Y and Z. A zoom drive is also declared. Controller
firmware `D8_CTRL.EXE` is 6.03 (10-Feb-2010) and `D8_CTRL.OLD` is 3.04
(02-Mar-2006). `IC.DAT` points the controller at `DEVICE.INI`.

## Summary

The controller's boot-disk `DEVICE.INI` defines no scintillation counter. 0D,
which is needed to set the zeros, is therefore unavailable on the controller
even though the CNF enables it. The zeros are also inconsistent. The four
archived captures carry four different θ/θ reference pairs and two different Z
references, spread by up to 0.9° on each arm and 0.9 mm in Z, and none of them
is backed by a recorded measurement. On this goniometer 1 mm of sample height
moves a low-angle peak by about 0.44° in 2θ, so differences of this size are
enough to produce a millimetre-scale Z offset. The repair is to regenerate the
configuration through D8 Config with 0D restored and the hardware declarations
checked, then measure the zeros in 0D and record them here.

## Findings from the archived files

### 1. The controller has no 0D detector

`bootdisk/DEVICE.INI` has no `[DIB1]` or `[CHANNEL1]` section. The firmware
reads both: it carries parse errors for `[DIB` and `[CHANNEL` sections and the
keys `DHV`, `LLD1` and `WIDTH1`. The 2015 capture shows what D8 Config writes
for this instrument:

```
[DIB1]
BASEADR=140
DETECTOR=ScintillationCounter1

[CHANNEL1]
NAME=ScintillationCounter1
DHV=679.2
LLD1=0.298
WIDTH1=1.176
```

The CNF still enables the counter. `[Detector Interface Board 1]` and
`[Detector 1]` are both `sStatus=used`, with base address 140 and the same HV
and discriminator values. The fault is therefore on the controller side: the PC
offers 0D and the controller cannot supply it. The boot-disk file's header
reads "Scintillation and Vantec Detectors", but the file contains neither
detector section.

### 2. Reference positions differ in every capture

| Capture | TH-Tube (θ) | TH-Detector | θ/θ sum | Z (mm) |
| --- | --- | --- | --- | --- |
| `diff_in1.cnf-original` (2006) | 19.8658 | 23.3148 | 43.1806 | -1.2712 |
| `diff_in1.cnf`, from the 2007 source | 20.1178 | 22.4031 | 42.5209 | -2.1713 |
| `DEVICE.INI.DIFFRAC-HISTAR` (2015) | 20.1664 | 22.4031 | 42.5695 | -2.1713 |
| `bootdisk/DEVICE.INI` | 19.3148 | 22.9456 | 42.2604 | -1.27 |

In θ/θ geometry the scattering angle is the sum of the two arm angles, so the
2θ zero depends on the sum of the two references. The 2007 source file used for
the CNF edit is not in the archive. The values applied from it match neither
archived `DEVICE.INI` in full. Loading `diff_in1.cnf` over the boot-disk values
moves TH-Tube by +0.8030°, TH-Detector by -0.5425° and Z by -0.9013 mm.

### 3. The boot-disk TH-Tube block looks partly copied from TH-Detector

Three TH-Tube values in `bootdisk/DEVICE.INI` look borrowed from TH-Detector
rather than taken from any other capture of TH-Tube:

- `CONF_B=ED00` is TH-Detector's value. TH-Tube is `0100` in the 2006 CNF, the
  2015 capture and the current CNF.
- `LOWER=-10` is TH-Detector's value. TH-Tube is -5 in the other captures since
  2007.
- `REF=19.3148` has the same decimals as the 2006 TH-Detector reference
  (23.3148) and is exactly 4.0000 lower. That looks like a transcription, not a
  measured zero.

`Z REF=-1.27` is the 2006 value truncated. The formatting shows that the file
was not last written by the controller. The firmware contains its own
`DEVICE.INI` writer, with a `DEVICE.TMP` work file and fixed formats:
`REF=%.4lf`, `LOWER=%.4lf`, `CONF_B=%04x` (lowercase hex) and `RESOL=%E`. The
boot-disk file has `LOWER=-10`, `CONF_B=ED00` and `RESOL=0.0001`, and the same
is true of every archived `DEVICE.INI`. All of them were last written by D8
Config or by hand, and the boot-disk file reads as a hand edit.

`CONF_B` is a configuration word for the axis card. What `ED00` does on the tube
axis is not documented here, so restore it through D8 Config before trusting any
tube zero.

### 4. Hardware declarations disagree

| Drive | CNF (2006 and current) | `bootdisk/DEVICE.INI` | 2015 capture |
| --- | --- | --- | --- |
| Divergence slit | used, board base 980 slot 3 | commented out, slot empty | absent |
| Antiscatter slit | used, board base 980 slot 4, REF 185 | commented out, slot empty | base 980 slot 4, REF 172, phase current 0.16 |
| Zoom | `[Drive 14]` used, `iDriveNo=8`, but base 960 slot 4 lists `AUX1` | `[DRIVE8]` on base 960 slot 4 | as boot disk |

Board numbering differs between the file types. The CNF's Two Axis Indexer
Board 1 is `[AIB1]`, and its Four Axis Indexer Boards 1 and 2 are `[AIB2]` and
`[AIB3]`, so compare boards by base address. If either slit motor is physically
absent, saving from the current CNF declares phantom drives. If the zoom motor
is present, it needs its slot. This finding corrects item 2 of "Changes NOT
applied" in `diff_in1_changes_summary.md`: the CNF does contain the zoom drive,
but not its slot assignment.

### 5. Provenance gaps

- `dirlisting.txt` lists `DEVICE.INI` as 5,629 bytes (08/06/2020), but the
  archived file is 5,882 bytes, so it is not the file that listing describes.
  The archive does not establish which `DEVICE.INI` the controller boots from
  today.
- `CurrentBootdisk/` (captured 2026-07-02) contains only its Readme.
- The 2007 source `DEVICE.INI` is not archived.
- The skill names `fThetaFZeroOffset` as a past root cause, but it does not
  appear in any archived file. It must be kept on the instrument PC.

### 6. `DEVICE.INI-wont-boot` is the VANTEC's own configuration

This file holds `[DETECTOR 1] NAME=VANTEC-1 TYPE=PXC`, `[COMMUNICATION]`,
`[NETSETUP]`, `[RC 1]`, `[TDC 1]` and a 74-point `[FILTER 3]` calibration. It is
the file the VANTEC-1 controller keeps, not a D8 controller file. Loaded as
`DEVICE.INI`, it gives the firmware no `[DEVICE]`, `[DRIVEn]` or `[AIBn]`
sections, and the firmware has an explicit error for a missing `[DEVICE]`
section. That explains why the controller would not boot from it.

The file also differs from the CNF's `[Position Sensitive Detector]` block:

| Parameter | VANTEC file | CNF |
| --- | --- | --- |
| Delay line | 92212 | 93004.5 |
| Delay compensation (left/right) | 1114/1114 | 1506/1701 |
| Dithering | 0 | 420 |
| Second HV | 5661 | 5605 |
| Calibration | 74 points | 75 pairs |

The CNF calibration has 75 pairs, not the 72 given in the skill and the change
summary, and it is unchanged since 2006. Which calibration the detector is
running remains an open question. It affects 1D peak positions, not the 0D
zeros.

### 7. Minor

- In `bootdisk/DEVICE.INI` the `[RS]`, `[SHUTTER1]` and `[SHUTTER2]` headers
  are commented out but their keys are not. Those keys, including three more
  `NAME=` lines, are therefore read as part of `[COM2]`. This is harmless if the
  parser keeps the first `NAME=`, and regenerating the file in D8 Config removes
  it either way.
- `KD=0,1` is two fields (gain and flag), per the firmware format
  `KD=%.4lf,%u`. It is not a decimal comma.

### Checked and consistent

- X and Y have been at +41.049 and +41.023 with `CONF_X=9560` in every capture
  since 2015. The sign flip in the CNF edit therefore brings the CNF into line
  with the controller rather than changing the hardware. The slow jog check
  still applies.
- The scintillation counter settings (679.2 V, LLD 0.298, window 1.176) were
  the controller's values in 2015.
- The Phi and Psi references, the CNF's VANTEC calibration and the generator
  defaults (35 kV, 40 mA) are unchanged since 2006.

## Repair procedure

This follows the skill's recovery sequence. Each step feeds the record tables
below.

**0. Capture before changing anything.** Copy every file on the floppy, with a
directory listing, into a new dated folder. Export the current CNF and
`DEVICE.INF` from D8 Config, and locate and archive the 2007 source
`DEVICE.INI`. Note the reference positions the controller reports now. Commit
all of this as new captures.

**1. Regenerate the configuration in D8 Config, not in a text editor.** Then
check the floppy `DEVICE.INI` it produces.

| Item | Set to | Reason |
| --- | --- | --- |
| Scintillation counter | used, base 140 | Restores 0D. Confirm `[DIB1]` and `[CHANNEL1]` appear in `DEVICE.INI`. |
| TH-Tube `uConfB` | 100 | Value in the 2006 factory CNF and the 2015 capture. `ED00` appears only in the hand-edited file. |
| TH-Tube lower limit | -5 | The -10 on the boot disk appears copied from TH-Detector. Confirm clearance at -5. |
| Divergence and antiscatter slits | used only if the motors are installed | Phantom hardware must be removed from both files. |
| Zoom drive | base 960 slot 4, if installed | The CNF lists `AUX1` in that slot. |
| Reference positions | leave as loaded, record them | Steps 3 and 4 supersede them. |

**2. Confirm 0D.** Check that the counter responds. Then run a discriminator
scan to confirm the photopeak sits in the 0.298/1.176 window, because the
settings date from 2007.

**3. Set the 2θ zero on the direct beam, in 0D.** Remove the sample, put an
absorber in the beam, fit a narrow receiving slit and set θ to 0. Scan 2θ
through zero in steps of 0.005° or finer. Fit the peak centre and set it to zero
on the Positioning Drives page. The direct beam is not split into Kα1 and Kα2,
so the Kα1 rule only applies at verification.

**4. Set Z and θ.** With a knife edge or flat reference at θ = 2θ = 0, scan Z
and set the half-intensity height. Then rock θ at that height and set the
maximum to zero. Repeat until successive corrections fall below 0.005° and
0.005 mm. Then repeat step 3, because in θ/θ geometry the tube zero enters the
2θ zero.

**5. Check persistence.** Confirm that the new reference positions are in the
floppy `DEVICE.INI`. Power-cycle the controller, re-home, and repeat one
direct-beam scan. If the controller wrote the file itself, it will now show the
firmware formatting described in finding 3. Archive the new floppy contents as a
new capture.

**6. Verify.** Measure a line-position standard in 0D and compare the Kα1
positions with calculated values. The height needed to put the peaks in place
should now be close to zero, which confirms that Z was a symptom. Then measure
the same peaks with the VANTEC in 1D. Any remaining offset belongs to the
detector reference channel (`fZeroOffset1=-5.55663` in the CNF, unchanged since
2006). Correct it on the PSD side, not through the drive references.

Si (a = 5.43114 Å) with Co Kα1 = 1.78897 Å:

| hkl | 111 | 220 | 311 | 400 | 331 | 422 |
| --- | --- | --- | --- | --- | --- | --- |
| 2θ Kα1 (°) | 33.149 | 55.528 | 66.218 | 82.414 | 91.761 | 107.577 |
| Kα2 offset from Kα1 (°) | 0.074 | 0.131 | 0.162 | 0.218 | 0.257 | 0.340 |

## Checking alignment results

Results from any alignment session make sense if they pass these tests.

1. **Measured in 0D.** If the controller file still lacks `[DIB1]`, the zeros
   were set with the VANTEC, and the 2θ zero includes the detector
   reference-channel offset. Such a result cannot separate the two and should
   be repeated after step 1.
2. **Read against the references loaded at the time.** An offset reads as
   loaded reference minus correct reference, as long as no reference switch has
   moved. With the boot-disk references loaded, each earlier capture predicts a
   distinct set of results:

   | Correct capture | θ rocking centre | Z half-cut | Direct beam, θ at 0 |
   | --- | --- | --- | --- |
   | 2006 CNF | -0.551° | +0.001 mm | -0.920° |
   | 2007 source | -0.803° | +0.901 mm | -0.260° |
   | 2015 capture | -0.852° | +0.901 mm | -0.309° |

   A result that reproduces one row identifies the last good zero. A result
   that matches no row suggests a mechanical change, and the new measurements
   stand on their own. If the CNF edit was loaded instead, the same rule gives
   +0.252°, -0.900 mm and -0.660° for the 2006 row, -0.049°, 0 mm and -0.049°
   for the 2015 row, and +0.803°, -0.901 mm and +0.260° for the boot-disk
   values.
3. **Consistent with each other.** Z sensitivity is 0.44° of 2θ per mm at low
   angle, 0.40° at 60° and 0.32° at 90°. A Z that users needed before the
   repair should correspond to the measured 2θ and height errors on that scale.
4. **Clean residuals on the standard.** Kα1 residuals should be within about
   0.01° with no trend in 2θ. A constant residual is a 2θ zero error, and a
   residual that scales with cos θ is a height error. A residual near 0.025° at
   Si 111 means the unresolved doublet centroid was fitted, and one near 0.074°
   means Kα2 was taken for Kα1.
5. **Persistent.** The zeros are in the floppy `DEVICE.INI` and reproduce within
   0.005° after a power cycle.
6. **Physically plausible.** Corrected references should stay within about 1°
   (arms) and 1 mm (Z) of the archived values unless hardware was changed. A
   correction of several degrees points to a homing problem, for example the
   TH-Tube `CONF_B` question, rather than a zero error.

## Record

Fill in at the instrument.

### Before repair

| Quantity | Value | Date and conditions |
| --- | --- | --- |
| Z used for routine samples | | |
| Reflection used to judge alignment, and its offset | | |
| Detector modes working (0D, 1D) | | |
| `DEVICE.INI` on floppy (size, date) | | |

### Reference positions

| Drive | On floppy before | Measured offset | After | After power cycle |
| --- | --- | --- | --- | --- |
| TH-Detector | | | | |
| TH-Tube | | | | |
| Z | | | | |

### Verification

| Standard and reflection | Calculated Kα1 2θ | Observed 0D | Observed 1D | Z used |
| --- | --- | --- | --- | --- |
| | | | | |

## Changes considered and not made

1. **Copying `[DIB1]` and `[CHANNEL1]` from the 2015 capture into the boot-disk
   file.** This would restore 0D fastest. But hand edits are how the boot-disk
   file reached its current state, and D8 Config must regenerate the CNF,
   `DEVICE.INF` and `DEVICE.INI` together to keep them consistent.
2. **Adopting one archived reference set.** None is a recorded measurement, and
   they differ by roughly 25 to 90 times a 0.01° alignment tolerance.
3. **Reverting to the 2006 factory CNF.** The X and Y axes have run reversed
   since at least 2015, with `CONF_X` and the reference sign changed together.
   Reverting would reverse them again, and the 2006 zeros are no more a
   measurement of the present hardware than the later ones.
4. **Editing `CONF_B`, the slit declarations or the zoom declarations in the
   archived files.** These are recorded above as settings for D8 Config, and the
   archive keeps each file as captured.
5. **Changing the VANTEC calibration or `fZeroOffset1`.** A 1D offset can only
   be attributed to the detector once the 0D zeros are set.

## Open questions

- Which `DEVICE.INI` is on the floppy now, and which references were loaded when
  the latest results were taken?
- Are the divergence slit, antiscatter slit and zoom motors installed?
- What do the `ED00` and `0100` settings of `CONF_B` select on the tube axis?
- Where is `fThetaFZeroOffset` kept, and has it changed?
- Which calibration is the VANTEC running: the CNF's or its own?
- `DEVICE.INI.DIFFRAC-HISTAR` declares the scintillation counter and the VANTEC
  (`[DETECTOR] NAME=PXC`, the type code the VANTEC's own file uses). Was it this
  detector setup under another name, or a different setup as AGENTS.md
  describes?
