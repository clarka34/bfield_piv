%% USER INPUTS (define the OPTIONS for PIV analysis, and the directories of images for PIV
%% Specify the case directories
% SINGLE CASE PROCESS (note relative vs absolute paths)
% dir_case{1} = [pwd filesep 'example-cases' filesep 'axial-flow-case-1'];
% dir_case{1} = [pwd filesep 'example-cases' filesep 'kurt'];
% dir_case{1} = '/mnt/data-RAID-1/Kurt/Kurt/Test4_15mL_40BPM_50Sys';
% dir_case{1} = '/mnt/data-RAID-1/danny/Bamfield-PIV/example_cases/axial-flow-case-1';
% BATCH CASE PROCESS
% PIV_Wake_YawAngle20degree_083015_rotorside_2D
dir_case{1} = '/mnt/data-RAID-1/danny/Bamfield-PIV/PIV_Wake_YawAngle20degree_083015/PIV_Wake_YawAngle20degree_083015_rotorside_2D/PIV_Wake_YawAngle20degree_083015_rotorside_2D_TSR6_1ms';
dir_case{2} = '/mnt/data-RAID-1/danny/Bamfield-PIV/PIV_Wake_YawAngle20degree_083015/PIV_Wake_YawAngle20degree_083015_rotorside_2D/PIV_Wake_YawAngle20degree_083015_rotorside_2D_TSR6_1p2ms';
% dir_case{3} = '/mnt/data-RAID-1/danny/Bamfield-PIV/PIV_Wake_YawAngle20degree_083015/PIV_Wake_YawAngle20degree_083015_rotorside_2D/PIV_Wake_YawAngle20degree_083015_rotorside_2D_TSR7_1ms';
% dir_case{1} = '/mnt/data-RAID-1/Kurt/Kurt/Test5_20mL_57BPM_37Sys'; % upstream
% dir_case{2} = '/mnt/data-RAID-1/Kurt/Kurt/Test6_20mL_57BPM_37Sys'; % bifurcation
% dir_case{3} = '/mnt/data-RAID-1/Kurt/Kurt/Test3_15mL_40BPM_50Sys'; % bifurcation
% dir_Case{4} = '/mnt/data-RAID-1/Kurt/Kurt/Test4_15mL_40BPM_50Sys'; % upstream
%% Other settings
OPTIONS.LaserType       = 'pulse';          % choose 'pulse' or 'continuous' laser type
OPTIONS.logfiles        = false;            % usually a good idea to keep logs, except Matlab is crashing on "diary" for some reason
OPTIONS.parallel_nCPUs  = 4;                % enter the number of CPUs to use in parallel, or enter 'false'
OPTIONS.skip_case       = [];               % skip these cases (default to empty [] to run all cases)
OPTIONS.max_images      = [];               % if empty uses all image pairs, or can set a maximum number incase your computer runs out of memory
OPTIONS.firstTime       = false;            % starts from clean slate, deletes all files in directory and setups subfolders, keeping the raw images
OPTIONS.findZombies     = false;            % our camera sometimes drops the first or last (or both)  laser pulse, detect and remove "zombie" images
OPTIONS.ImageJ          = true;             % Use ImageJ to do pre-processing on the raw images?  This step brings each image pair to same background level, performs contrasting, and converts to 8-bit images (for MatPIV)
OPTIONS.FFMPEG          = true;             % if false then no movies are made via FFMPEG, or FFMPEG is not configured correctly on your system (also Matlab has some lame difficulties with running FFMPEG, it is possible to resolve, see notes within)
OPTIONS.fps             = 3;                % frames per second for creating movies 
OPTIONS.POD             = false;            % compute Proper Orthogonal Decomposition modes (incomplete)
OPTIONS.inflow          = 1.0;              % "inflow speed" (m/s) [experimental, this only affects creation of some figures]
%% MatPIV settings
OPTIONS.runMatPIV       = false;            % set to 'false' if you have already run MatPIV once, then it only re-runs the filtering & plotting stuff afterwards (useful for trying different post-processing options)
OPTIONS.t_sep           = 1/1000;           % Time separation between base and cross images (the laser pulses)
OPTIONS.overlap         = 0.5;              % overlap of interrogation regions (percent)
OPTIONS.win_size        = [128 128; ...     % 8 iterations of successively smaller window sizes
                           128 128; ...
                           64 64; ... 	
                           64 64; ...
                           32 32; ...
                           32 32; ...
                           16 16; ...
                           16 16];                       
OPTIONS.method          = 'multin';         % Use interrogation window offset (try the new 'multinfft')
OPTIONS.coordWorld      = [];               % no coordinate system defined yet, perform MatPIV all in pixel coordinates
OPTIONS.mmpp            = 27/1220;          % mm per pixel (alternative calibration to MatPIV's "woco" method.  This "mmpp" method uses a ruler instead of full calibration plate method.  Set as empty [] to stay in a pixelized world (27/1220, 0.0208)
OPTIONS.relpathToMask   = [];               % mask file needs to be in CALIBRATION folder of the directory, otherwise use empty [] if not using masks.  Can use multiple masks if multiple OPTIONS.dir_case are specified; example: instead of entering multiple like: {'polymask_Test5.mat', 'polymask_Test6.mat', 'polymask_Test3.mat', 'polymask_Test4.mat'} you have to change each time
OPTIONS.use_init_vel    = false;            % compute an initial velocity for each image pair?      
OPTIONS.applyFilters    = true;             % perform filtering via MatPIV methods (you may want to customize which filter method you use ... our camera provide good enough image quality, so did not require all filter methods)
OPTIONS.thold_snr       = 1.6;              % threshold for use with snr-filtering
OPTIONS.thold_peak      = 0.5;              % peak to peak filtering
OPTIONS.thold_global    = 'loop';           % threshold for use with globalfiltering (choose 3 or 'loop')
OPTIONS.thold_local     = 3;                % threshold for std. use with local filtering 
OPTIONS.thold_local_num = 5;                % number of vectors to apply the local filtering upon
OPTIONS.med             = 'median';         % Use median filtering in localfilt (UNUSED)
OPTIONS.int             = 'interp';         % interpolate outliers (UNUSED)
OPTIONS.method_vort     = 'leastsq';        % method for calculation vorticity. 'leastsq' is the preferred method in PIV to reduce effect of fluctuations. or try 'circulation'
OPTIONS.T_inv           = 1;                % Transformation Matrix (leave as 1 to keep in pixel coordinates ... otherwise give filename of .mat file containing the transformation matrix like: 'myCoordFile.mat')        

%% END there should be no USER INPUTS beyond this point
%  best luck and happy PIV, run the entire toolchain now:


piv_bfield(OPTIONS, dir_case); 	% run the toolchain

% can easily change options per case directory like:
% OPTIONS.inflow = 1.0;
% piv_bfield(OPTIONS, dir_case{1});
% OPTIONS.inflow = 1.0;
% piv_bfield(OPTIONS, dir_case{2});


