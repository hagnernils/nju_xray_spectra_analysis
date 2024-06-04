# Analysis of the X-ray spectra of ESO-377-024

Simply run the script (be sure to `chmod u+x` before to make it executable), it will
- download the skytile event file for all merged TMs of eROSITA
- use the [eSASS](https://erosita.mpe.mpg.de/dr1/eSASS4DR1/eSASS4DR1_cookbook/) suite to detect sources in the skytile
- extract the events at the galaxies position and prepare a source spectra for it
- bin the spectrum with different minimum counts

The `model.xspec` file gives a possible fit. Jump in the folder and load it into xspec with `@model.xspec`.
Be aware that the reduced Chi-square ratio is a bit low, indicating an overfit.

**Packages needed: `wget gzip` and the eSASS tools, `xspec` for the analysis of the spectrum.**
**I recommend the convenient [eSASS Docker containers](https://erosita.mpe.mpg.de/dr1/eSASS4DR1/eSASS4DR1_installation/#Docker_container).**
