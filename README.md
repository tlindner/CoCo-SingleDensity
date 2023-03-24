# CoCo-SingleDensity
DECB patch for CoCo 3 to switch to single density diskette mode

To use:

Copy disk image to real disk. On a CoCo 3, type `RUN "SD`.
This wil change DECB to be in single density mode. Normal Color Computer disks will not be readable.

You can `DSKINI` new disks, and can `DSKI$` to read data and `DSKO$` to write data.

New disk image format is 9 256 bytes sectors per track, numbered from 1 to 9.

--
tim lindner
March 24, 2023
tlindner@macmess.org
