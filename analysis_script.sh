export OMP_NUM_THREADS=10 # use multiple threads, speeds up considerably

EMIN=0.5 #default 0.5
EMIN_=500
EMAX=10.0 #default 2.0
EMAX_=10000
skytile_eventlist_link=https://erosita.mpe.mpg.de/dr1/erodat/data/download/126/169/EXP_010/em01_169126_020_EventList_c010.fits.gz
skytile_eventfile="em01_169126_020_EventList_c010.fits"

wget $skytile_eventlist_link
gunzip $skytile_eventfile.gz
mkdir -p eso_377_024 # prepare subfolder for results

# combine event file, without good-time-interval (GTI) filtering
evtool eventfiles="$skytile_eventfile" outfile="events_image_comb.fits" image=yes emin=$EMIN emax=$EMAX size="auto" clobber=yes #gti="GTI"

expmap inputdatasets="events_image_comb.fits" emin=$EMIN emax=$EMAX templateimage="events_image_comb.fits" mergedmaps="output_expmap.fits" #--withdetmaps='yes' # gtitype="GTI" #--withfilebadpix='yes'

# discard pixels with exposure of less than 20% of the maximum exposure
ermask expimage="output_expmap.fits" detmask="detmask.fits" threshold1=0.2 threshold2=100.

# TODO check the energy conversion factor
erbox images="events_image_comb.fits" boxlist="boxlist_local.fits" emin=$EMIN_ emax=$EMAX_ expimages="output_expmap.fits" detmasks="detmask.fits" bkgima_flag=N ecf=1

# create background map
erbackmap image="events_image_comb.fits" expimage="output_expmap.fits" boxlist="boxlist_local.fits" detmask="detmask.fits" bkgimage="bkg_map.fits" emin=$EMIN_ emax=$EMAX_ cheesemask="cheesemask.fits" fitmethod="smooth" clobber=Y

# erbox in map mode
erbox images="events_image_comb.fits" boxlist="boxlist_map.fits" expimages="output_expmap.fits" detmasks="detmask.fits" bkgimages="bkg_map.fits" emin=$EMIN_ emax=$EMAX_ ecf=1

# source characterization (TODO check: Extended model can be Gaussian or Beta)
ermldet mllist="mllist.fits" boxlist="boxlist_map.fits" images="events_image_comb.fits" expimages="output_expmap.fits" detmasks="detmask.fits" bkgimages="bkg_map.fits" extentmodel=beta srcimages="sourceimage.fits" emin=$EMIN_ emax=$EMAX_

catprep infile="mllist.fits" outfile="catalogue.fits"

# source extraction
#-----------------------
# extract all
#srctool eventfiles="events_image_comb.fits" todo=ALL srccoord="catalogue.fits" srcreg='fk5;circle * * 60"' backreg='fk5;annulus * * 90" 120"' clobber=yes

## extract only around coordinate
srctool eventfiles="events_image_comb.fits" prefix="eso_377_024/" todo="ALL" srccoord="icrs;11:12:33.3615,-36:25:30.836" srcreg='icrs;circle * * 60"' backreg='icrs;annulus(*,*,90.0",120.0")' lctype="SRCGTI" tstep=0.05 xgrid="0.1 0.25" clobber=yes

# binning for the Source Spectra
# ------------------------------------
cd eso_377_024
merged_detectors_filename=020_Source*
rm -f *.pha
for i in {5,10,15,20,25}; do
    grppha $merged_detectors_filename $i.pha comm="group min $i & exit"
    # Uncomment to also bin other files
    #for sourcefile in *SourceSpec*.fits; do
    #    grppha $sourcefile $sourcefile.grp comm="group min $i & exit"
    #done
done

echo "You can find the binned event files in the current folder eso_377_024"
