# bfield_piv (toolchain for Particle-Image-Velocimetry)

This code utilizes the MatPIV toolbox to perform the PIV calculations of velocity field.  Otherwise, the bulk of Matlab code here is to perform
* pre-processing of raw images - utilizes ImageJ macros to improve visibility of particles in the flow, and balance intensity levels between image pairs
* processing - sets up the input structures to run MatPIV and filters, and then computes the velocity fields
* post-processing - computes other flow statistics from the PIV velocity fields, and creates figures and movies

Wherever possible, bfield_Piv will run in parallel to drastically speed-up performance, and will fully utilize all CPU cores and run in headless mode for supercomputers.


# Example Usage - User Inputs and Setup - Batch Processing

The experiment in this example corresponds to PIV of turbulent wakes of marine-hydrokinetic-turbines.  Here is an image of the turbine in example; the interesting features include helical vortex trailing from blade tips, and expansion of the wake.  Here is a comparison of the photography, and velocity and vorticity fields computed via PIV.
FIGURE

To use bfield_piv, create a new directory, and then a subfolder name "raw" which holds your raw camera images.  After this code runs, it will result in the following directory structure:
FIGURE

* The "raw" directory contains the unedited camera images
* The "post" directory contains the camera images after improved by ImageJ processing, these are the images that PIV is performed upon
* The "vectors/raw" directory contains the results of MatPIV calculation of velocity fields
  * "raw" is the instantaneous velocity vectors, without any PIV filtering applied
  * "instantaneous" contains the velocity vectors, and "fluctuating" removes the mean flow component (now both folders have PIV filters applied)
  * "stats" contains statistical information, such as turbulence characteristics and mean velocity profiles (computed from the filtered fields)
  * "vtk" contains the vector fields now converted into VTK format (for processing outside Matlab)
* The "figures" folder contains the final image sequences and movies

Now, back to the initial setup ... the file "bfield_piv_inputs.m" shows how to setup the OPTIONS structure.  As you may have guessed, OPTIONS provides the complete set of User Inputs needed to drive the program.  Once you have setup the user inputs within OPTIONS, it is easy to batch process a series of experiments.  For example, in each experiment, I save the raw camera images into a unique directory, such as "test_1" and "test_2", and I can modify any of the OPTIONS in-between test cases.  For example:

CODE
CODE
CODE


# Advanced Usage - macro "like"

Review the main program, bfield_piv.m.  The flow of the bfield_piv program resembles a set a macros, such that each step does not always need to be performed in the same order.  For example, the most computationally expensive step is the calculation of velocity fields during the call to MatPIV toolbox; but once the raw velocity fields exist the user is free to experiment with different filters, statistics, figures, movies, etc.  Here is an example use case:


% name of the directory with raw images
dir_casename = 'asdf'
piv_bfield
% all of the "raw vectors" are saved, but say I want to change appearance of the figures.
% Next I would edit the "asdf.m" file, then re-run the toolchain, skipping the MatPIV step now:
CODE
CODE
% I want to try different filtering methods, so edit the "asdf.m" file and then re-run the scripts:
CODE
CODE
CODE


# Visualization
To create movies, the VTK format is produced in the "vtk" folder, and can be loaded into Visit or ParaView.  Some macros for ParaView are included, the "paraview_*.pvsm" files, to visualize Line-Integral-Convolution of the velocity fields.
FIGURE


# Supercomputer batch processing 

And finally, if you want to run this on a supercomputer to do batch processing, see the example "submit-job-Hyak-bfield_piv.sh".  This PBS script will run in headless mode on a supercomputer, and can be run like:

    qsub asdf.sh


