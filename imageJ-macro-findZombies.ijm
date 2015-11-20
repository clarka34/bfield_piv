//Runs script in batch mode if not commented out
// setBatchMode(true);      

args = split(getArgument(),','); 	// optional arguments for "input" and "output" directories
// arg = getArgument(); 	
// if (lengthOf(args) == 0) {
// 	// Run script by choosing the source directories
// 	dir_raw = getDirectory("Choose Directory of Raw Images");
// } else {
// 	// the user gave some directories
	dir_raw = args[0];
	// dir_raw = arg;	
// }

filenames   = getFileList(dir_raw);
num_images  = filenames.length;
// num_pairs   = filenames.length / 2;
filenames = dir_raw + File.separator + filenames[0];
// filenames_B = dir_raw + File.separator + filenames[1];
// name_new_A  = "A__SubtractBackground-Contrast-Convert__";
// name_new_B  = "B__SubtractBackground-Contrast-Convert__";


// run on the base image pair (A)
run("Image Sequence...", "open=[filenames] number=num_images starting=1 increment=1 file=tif sort");
// dumIm=getImageID();



// run("Z Project...", "projection=[Average Intensity]");
// imageCalculator("Subtract create stack", "raw","AVG_raw");
// run("Enhance Contrast", "saturated=0.35");
// run("Apply LUT", "stack");
// run("8-bit");
// run("Image Sequence... ", "format=TIFF name=" + name_new_A + " save=" + file_new_A);
// // close all the "A" images
// run("Close All");

// // run on the cross image pair (B)
// run("Image Sequence...", "open=[filenames_B] number=num_images starting=2 increment=2 file=tif sort");
// run("Z Project...", "projection=[Average Intensity]");
// imageCalculator("Subtract create stack", "raw","AVG_raw");
// run("Enhance Contrast", "saturated=0.35");
// run("Apply LUT", "stack");
// run("8-bit");
// run("Image Sequence... ", "format=TIFF name=" + name_new_B + " save=" + file_new_B);
// // close all the "B" images
// run("Close All");

// // close imageJ
// run("Quit");
