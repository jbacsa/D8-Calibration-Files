# AGENTS.md

Context for agents working in this repository.

## What this is

A public archive of Bruker D8 diffractometer controller configuration: the
floppy boot disk contents, DEVICE.INI variants, and CNF files with a record of
what was changed and why.

This is **not a code repository.** It is a restore point and a maintenance
record for a specific instrument. The most valuable content is the reasoning
captured in `diff_in1_changes_summary.md`, particularly the list of changes that
were considered and deliberately not applied.

## Layout

| Path | Contents |
| --- | --- |
| `bootdisk/` | Contents of the D8 controller floppy, PTS-DOS based |
| `CurrentBootdisk/` | Dated capture of the current working boot disk |
| `diff_in1.cnf` and variants | Controller configuration, with `-original` and `-edit` forms |
| `diff_in1_changes*` | Change record in Markdown, TSV, and Excel |
| `alignment_repair.md` | Alignment diagnosis, repair procedure, and measurement record |

Suffix conventions in use: `-original` for the state before edits, `-edit` for a
working copy, `-wont-boot` for a known-bad variant kept deliberately as a
negative example, and `.DIFFRAC-HISTAR` for a configuration belonging to a
different detector setup.

## Rules

1. **Never delete a configuration variant.** Add new captures alongside existing
   ones. The whole point of the archive is that a bad configuration can be
   compared against a known-good one.
2. **Do not "tidy" the bootdisk.** The DOS system files, driver `.SYS` files, and
   `D8_CTRL.EXE` including its `.OLD` companion are a working set. Removing
   something that looks redundant can produce a disk that will not boot.
3. **Record the reasoning, not just the change.** When updating the change
   summary, keep the section covering changes that were considered and rejected.
4. **Verify before loading on hardware.** Configuration changes can drive
   hardware into itself. The `d8-instrument-config` skill has the pre-load
   checklist covering sign-flipped drive references, extended travel limits, and
   detector high voltage changes.

## This repository is public

Do not commit names, email addresses, service contact details, network
credentials, or site-specific information beyond what the instrument
configuration itself requires. Keep commit messages and documentation
technical.

## Skills

`d8-instrument-config` covers alignment diagnosis, the 0D before zeroing rule,
CNF and DEVICE.INI role separation, the recovery sequence for a lost
configuration, and the pre-load safety checklist. Load it before advising on any
change to instrument configuration.
