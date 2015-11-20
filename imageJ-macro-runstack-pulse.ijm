//Runs script in batch mode if not commented out
setBatchMode(true);      

args = split(getArgument(),","); 	// optional arguments for "input" and "output" directories
if (lengthOf(args) == 0) {
	// Run script by choosing the source/destination directories
	dir_raw = getDirectory("Choose Directory of Raw Images");
	dir_new = getDirectory("Choose Directory of Processed Images");
} else {
	// the user gave some directories
	dir_raw = args[0];
	dir_new = args[1];	
}

filenames   = getFileList(dir_raw);
num_images  = filenames.length;
num_pairs   = filenames.length / 2;
filenames_A = dir_raw + File.separator + filenames[0];
filenames_B = dir_raw + File.separator + filenames[1];
name_new_A  = "A__SubtractBackground-Contrast-Convert__";
name_new_B  = "B__SubtractBackground-Contrast-Convert__";
file_new_A  = dir_new + File.separator + name_new_A + "00000.tif";
file_new_B  = dir_new + File.separator + name_new_B + "00000.tif";

// print('A: ' + filenames_A);
// print('B: ' + filenames_B);

// run on the base image pair (A)
run("Image Sequence...", "open=[filenames_A] number=num_images starting=1 increment=2 file=tif sort");
dumIm=getImageID();
run("Z Project...", "projection=[Average Intensity]");
imageCalculator("Subtract create stack", "raw","AVG_raw");
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT", "stack");
run("8-bit");
run("Image Sequence... ", "format=TIFF name=" + name_new_A + " save=" + file_new_A);
// close all the "A" images
run("Close All");

// run on the cross image pair (B)
run("Image Sequence...", "open=[filenames_B] number=num_images starting=2 increment=2 file=tif sort");
run("Z Project...", "projection=[Average Intensity]");
imageCalculator("Subtract create stack", "raw","AVG_raw");
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT", "stack");
run("8-bit");
run("Image Sequence... ", "format=TIFF name=" + name_new_B + " save=" + file_new_B);
// close all the "B" images
run("Close All");

// close imageJ
run("Quit");
