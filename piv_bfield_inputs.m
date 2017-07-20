%% USER INPUTS (define the OPTIONS for PIV analysis .. OPTIONS should be updated for each case directory "dir_case")
%% Other settings
OPTIONS.LaserType        = 'continuous';         % choose 'pulse' or 'continuous' laser type
OPTIONS.logfiles         = true;            % usually a good idea to keep logs, except Matlab is crashing on "diary" for some reason
OPTIONS.parallel_nCPUs   = 4;               % enter the number of CPUs to use in parallel, or enter '0' to run without the Parallel Toolbox
OPTIONS.skip_case        = [];              % skip these cases (default to empty [] to run all cases)
OPTIONS.max_images       = 10;              % if empty uses all image pairs, or can set a maximum number incase your computer runs out of memory
OPTIONS.firstTime        = true;            % starts from clean slate, deletes all files in directory and setups subfolders, keeping the raw images
OPTIONS.findZombies      = false;           % our camera sometimes drops the first or last (or both) laser pulse, detect and remove "zombie images"
OPTIONS.ImageJ           = true;            % use ImageJ to do pre-processing on the raw images?  This step brings each image pair to same background level, performs contrasting, and converts to 8-bit images (for MatPIV)
OPTIONS.FFMPEG           = true;            % if false then no movies are made via FFMPEG, or FFMPEG is not configured correctly on your system (also Matlab has some lame difficulties with running FFMPEG, it is possible to resolve, see notes within)
OPTIONS.fps              = 3;               % frames per second for creating movies 
OPTIONS.POD              = false;           % compute Proper Orthogonal Decomposition modes (incomplete, this feature not implemented yet)
OPTIONS.phase_avg        = false;           % PIV data is phase averaged (incomplete, this feature not implemented yet)
OPTIONS.inflow           = [];           	% "inflow speed" (m/s) [experimental, this only affects creation of some figures ... can leave empty []]
% OPTIONS.inflow           = 1.0;         	% "inflow speed" (m/s) [experimental, this only affects creation of some figures ... can leave empty []]
%% MatPIV settings (for the "processing" step)
OPTIONS.runMatPIV        = true;            % set to 'false' if you have already run MatPIV once, then it only re-runs the filtering & plotting stuff afterwards (useful for trying different post-processing options)
OPTIONS.t_sep            = 1/1000;       	% time separation between base and cross images (the laser pulses)
OPTIONS.overlap          = 0.5;          	% overlap of windows/interrogation regions
% OPTIONS.win_size         = [128 128; ...   	% 8 iterations of successively smaller window sizes
%                             128 128; ...
%                             64 64; ... 	
%                             64 64; ...
%                             32 32; ...
%                             32 32; ...
%                             16 16; ...
%                             16 16];     
OPTIONS.win_size         = [128 128; ...   	% 8 iterations of successively smaller window sizes
    128 128; ...
    128 128; ... 	
    64 64; ...
    64 64];                       
OPTIONS.method           = 'multin';        % use interrogation window offset (try the new 'multinfft')
OPTIONS.coordWorld       = [];              % no coordinate system defined yet, perform MatPIV all in pixel coordinates
OPTIONS.mmpp             = 1/86.5;   
% mm per pixel (alternative calibration to MatPIV's "woco" method.  This "mmpp" method uses a ruler instead of full calibration plate method.  Set as empty [] to stay in a pixelized world (carotid: 27/1220, turbine: 0.0208)
%OPTIONS.mmpp             = 0.0208;          % mm per pixel (alternative calibration to MatPIV's "woco" method.  This "mmpp" method uses a ruler instead of full calibration plate method.  Set as empty [] to stay in a pixelized world (carotid: 27/1220, turbine: 0.0208)
OPTIONS.T_inv            = 1;               % transformation matrix (leave as 1 to keep in pixel coordinates ... otherwise give filename of .mat file containing the transformation matrix like: 'myCoordFile.mat')        
OPTIONS.relpathToMask    = [];              % mask file needs to be in CALIBRATION folder of the directory, otherwise use empty [] if not using masks
OPTIONS.use_init_vel     = false;           % compute an initial velocity for each image pair?      
OPTIONS.applyFilters     = true;            % perform filtering via MatPIV methods (you may want to customize which filter method you use ... our camera provide good enough image quality, so did not require all filter methods)
% OPTIONS.thold_snr        = 1.6;             % threshold for use with snr-filtering
OPTIONS.thold_snr        = 1.3;             % threshold for use with snr-filtering
OPTIONS.thold_peak       = 0.5;             % peak to peak filtering
OPTIONS.thold_local      = 3;               % threshold for std. use with local filtering 
OPTIONS.thold_local_num  = 5;               % number of vectors to apply the local filtering upon
OPTIONS.thold_local_stat = 'median';        % use type filtering in localfilt. suggest 'median'
OPTIONS.thold_global     = 3;               % threshold for use with globalfiltering (choose 3 (plus or minus 3 std from mean) or 'loop' ... loop is causing extreme memory usage/errors)
OPTIONS.Nglobal          = 2;               % iterations for use with globalfiltering
OPTIONS.int              = 'interp';        % interpolate outliers
OPTIONS.method_vort      = 'leastsq';       % method for calculation vorticity. 'leastsq' is the preferred method in PIV to reduce effect of fluctuations. or try 'circulation'


%% BEST LUCK and HAPPY PIV, run the entire toolchain now: like piv_bfield(OPTIONS, dir_case);
%% SPECIFY the case directories, change any of the OPTIONS between running the toolchain on case directory (dir_case)

% %%
% dir_case = [pwd filesep 'example-cases' filesep 'axial-flow-case-1'];
% OPTIONS.inflow = 1.0;
% piv_bfield(OPTIONS, dir_case);

% %%
% dir_case = [pwd filesep 'example-cases' filesep 'kurt'];
% OPTIONS.inflow = 0.5;
% piv_bfield(OPTIONS, dir_case);

%%
% dir_case = '/mnt/data-RAID-1/danny/Bamfield-PIV/PIV_Wake_YawAngle20degree_083015/PIV_Wake_YawAngle20degree_083015_rotorside_2D/PIV_Wake_YawAngle20degree_083015_rotorside_2D_TSR6_1ms';
% OPTIONS.inflow = 1.0;
% piv_bfield(OPTIONS, dir_case);

%%
% dir_case = '/mnt/data-RAID-1/danny/Bamfield-PIV/PIV_Wake_YawAngle20degree_083015/PIV_Wake_YawAngle20degree_083015_rotorside_2D/PIV_Wake_YawAngle20degree_083015_rotorside_2D_TSR6_1p2ms';
% OPTIONS.inflow = 1.2;
% piv_bfield(OPTIONS, dir_case);

%% US TESTING
dir_case = [pwd filesep 'example-cases' filesep 'us_testing'];
if OPTIONS.firstTime
    piv_bfield_cleancase(dir_case);
end
OPTIONS.inflow = 1.0;
OPTIONS.t_sep = 1/1000;
piv_bfield(OPTIONS, dir_case);

