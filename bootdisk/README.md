Boot disk files from the D8 floppy

The controller boots PTS-DOS from this floppy. `AUTOEXEC.BAT` runs
`D8_CTRL.EXE`, and `IC.DAT` names `DEVICE.INI` as the configuration the
controller loads. The `DEVICE.INI` variants kept here are not interchangeable.

| File | What it is |
| --- | --- |
| `DEVICE.INI` | Controller configuration. The header is dated 2007, but the file has no scintillation counter section, and its Theta and 2Theta references match no other capture. It is 5,882 bytes here but 5,629 bytes in `dirlisting.txt`, so it is not the file that listing describes. |
| `DEVICE.INI.DIFFRAC-HISTAR` | Controller configuration dated 07/07/2015. It has the scintillation counter (`[DIB1]`, `[CHANNEL1]`), `[DETECTOR] NAME=PXC`, and the zoom and antiscatter slit drives. It is the most complete controller file in the archive. |
| `DEVICE.INI-wont-boot` | Not a controller file. It is the VANTEC-1 PSD's own configuration (detector, TDC, network and calibration settings). It has no `[DEVICE]`, `[DRIVEn]` or `[AIBn]` sections, which is why the controller would not boot from it. |
| `DEVICE-ST.INI`, `DEVICE-TXS.INI` | Bruker templates for a D8 NANOSTAR with a HI-STAR detector, one for a sealed tube and one for a TXS generator. Not this instrument. |
| `D8_CTRL.EXE` | Controller firmware 6.03, 10-Feb-2010. |
| `D8_CTRL.OLD` | Previous firmware 3.04, 02-Mar-2006. |

The comparison behind these notes is in `alignment_repair.md` in the repository
root.
