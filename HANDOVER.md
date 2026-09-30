# Handover: D8 alignment repair

Last session: 2026-09-30. The work is on branch
`claude/d8-alignment-repair-a8h8gk`, which is not merged and has no pull
request. Start here, then read `AGENTS.md`,
`.github/skills/d8-instrument-config/SKILL.md` and `alignment_repair.md`, which
holds the full record.

## Where things stand

- **Done:** a diagnosis of every archived CNF and `DEVICE.INI`, from the files
  only, and the records listed below. No configuration has been regenerated or
  loaded, and no zeros have been measured.
- **Waiting:** the latest alignment results are saved in the DIFFRAC_PLUS folder
  on the instrument PC's network drive and have not been reviewed. A cloud
  session cannot reach that drive. The numbers must be pasted in, or the work
  continued in a session running on that PC.
- **Constraint:** the scintillation counter gives unreliable results, so
  alignment is being done with the VANTEC for now. `alignment_repair.md` has an
  interim procedure for this (steps V1 to V5).

Records added in this session:

| File | Purpose |
| --- | --- |
| `alignment_repair.md` | Findings, D8 Config settings, 0D and VANTEC procedures, result checks, record tables, decisions and open questions |
| `alignment_report_2026-09-30.docx` | Word summary of findings and actions, for sharing |
| `diff_in1_changes_summary.md` | New section "Cross-check against the boot disk (2026-09-30)" |
| `bootdisk/README.md` | Guide to the `DEVICE.INI` variants |

## Key findings

1. The boot-disk `DEVICE.INI` has no `[DIB1]` or `[CHANNEL1]` section, so the
   controller holds no settings for the scintillation counter. This is the
   first suspect for the unreliable counter.
2. The Theta, 2Theta and Z reference positions differ in all four archived
   captures, and none of them is a recorded measurement.
3. The boot-disk TH-Tube block has three values that look borrowed from
   TH-Detector: `CONF_B=ED00`, `LOWER=-10` and `REF=19.3148`.
4. The CNF declares both motorized slits, which the boot disk has commented out.
   It also lists `AUX1` in the slot where the boot disk has the zoom drive.
5. The archived boot-disk `DEVICE.INI` (5,882 bytes) is not the floppy file
   listed in `dirlisting.txt` (5,629 bytes). `CurrentBootdisk/` holds only a
   Readme, and the 2007 source file is not archived.
6. `DEVICE.INI-wont-boot` is the VANTEC's own configuration file. Its timing
   (TDC) settings and calibration differ from the CNF's PSD block.

## Next steps

1. Read the floppy `DEVICE.INI`. Note its size, date and reference positions,
   and whether `[DIB1]` and `[CHANNEL1]` are present. Capture the floppy and the
   current CNF into the repository as a new dated capture.
2. If the counter sections are missing, regenerate the configuration in D8
   Config (repair step 1 in `alignment_repair.md` has the settings table). Then
   check the counter and its photopeak.
3. Align in 0D if the counter works (repair steps 3 to 6). Otherwise use the
   VANTEC (steps V1 to V5).
4. Review the latest results against "Checking alignment results" in
   `alignment_repair.md`.
5. Fill in the record tables, confirm the zeros survive a power cycle, and
   archive the new floppy contents.
6. Once the counter works, split the combined 2θ zero with one 0D direct-beam
   scan (step V5).

## Information needed from the instrument

- Direct-beam centre, Z half-cut and θ rocking centre, and which detector was
  used (0D or VANTEC).
- Reference positions loaded before the measurements, and those set afterwards.
- VANTEC direct-beam positions with the detector at 2θ = -2, -1, 0, +1 and +2°.
- Peak positions (Kα1) for Si or another standard.
- Whether the slit and zoom motors are installed.
- Any Detector-Interface-Board message when the controller boots.

## Quick check for results

With the boot-disk references loaded, each earlier capture predicts these
results:

| Correct capture | θ rocking centre | Z half-cut | Direct beam |
| --- | --- | --- | --- |
| 2006 CNF | -0.55° | 0.00 mm | -0.92° |
| 2007 source | -0.80° | +0.90 mm | -0.26° |
| 2015 capture | -0.85° | +0.90 mm | -0.31° |

The θ and Z columns also hold for the VANTEC. The direct-beam column holds for
the VANTEC only if its own offset is right. `alignment_repair.md` has the full
tests, the predictions for other loaded references, and the Si residual
signatures.

## Rules to keep

- Never hand-edit CNF or `DEVICE.INI` files. Regenerate them through D8 Config.
- Never delete or overwrite a configuration variant. Add new captures alongside
  the old ones.
- Restore 0D before zeroing. The VANTEC interim procedure is a recorded
  exception, and its 2θ zero is marked as combined.
- The repository is public: no names, email addresses, site details or
  credentials. DIFFRAC plus RAW headers can contain user and site names, so
  check result files before committing them.

## Flagged, not acted on

- `diff_in1_changes_summary.md` names a person in its source line. So does the
  header comment in `bootdisk/DEVICE.INI`, which is a captured file and should
  stay as it is.
- The password hash for the VANTEC web login is in the `[PSD Controller]` block
  of all three CNFs and the `[NETSETUP]` block of `DEVICE.INI-wont-boot`. It is
  also in the git history, so redacting the files alone would not remove it.
- The skill describes the VANTEC calibration as 72-point, but the CNF holds 75
  pairs.
- AGENTS.md describes `.DIFFRAC-HISTAR` as a different detector setup, but the
  file declares this instrument's detectors. This is listed as an open
  question.

## Starter prompt

Paste this into the new session. If that session cannot read the repository,
attach `HANDOVER.md` and `alignment_repair.md` as well.

```
I'm continuing the D8 alignment repair in the D8-Calibration-Files repository,
branch claude/d8-alignment-repair-a8h8gk. Read HANDOVER.md first, then
AGENTS.md, the d8-instrument-config skill and alignment_repair.md. The
scintillation counter is unreliable, so I'm aligning with the VANTEC for now.
Here are my latest results: [paste]. Check them against "Checking alignment
results" in alignment_repair.md and tell me what they imply.
```
