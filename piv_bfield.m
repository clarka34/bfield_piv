% NOTES & TO-DO:
% ==============
% * provide an initial guess for the velocity field, based upon
%   the computed valuse from previous iteration
%   idea for bugfix related to missing velinterp function ... use MatPIV v1.6 and replace imrgb using imfinfo
%   for example, you have a directory full of TIFFs (Thousands of
%   Incompatible File Formats), and some are indexed, some are RGB, etc. In this case, recommend to determine the image type directly from the output of imfinfo.
% * remove the console output from MatPIV ... or at least minimize it
% * add some console output for each stage (1-prepare, 2-vectors, 3-stats, 4-figures, 5-movies, ...)
% * write the output .mat files in compatible form to OpenPIV Spatial Toolbox (because I think it has developed POD analysis)
% * don't write post-processed filenames as "A__" and "B__"
%   it will better to keep numerical order to view images
% * figure out if ParaView or VisIt (or VAPOR?) can provide easier POD, LIC
%   and FTLE analysis ... update: ParaView provides built-in LIC, but could not find anything in VisIt
% * to make FFMPEG usable by Matlab, try something like (tested with R2011b): 
%   sudo ln -s /usr/lib64/libraw1394.so.11.1.0 /usr/local/MATLAB/R2011b/sys/os/glnxa64/libraw1394.so.8
%   sudo ln -sf /usr/lib64/libstdc++.so.6.0.19 /usr/local/MATLAB/R2011b/bin/glnxa64/libstdc++.so.6
%   OR just open matlab like this from command prompt (THIS SEEMS LIKE THE BEST SOLUTION, it works for me now - on R2011b): 
%   LD_PRELOAD=/usr/lib64/libstdc++.so.6.0.19 matlab
% * easter egg if you find what the "bfield" stands for ... 

function piv_bfield(OPTIONS,dir_case)

%% STARTUP add to the path any dependencies that this toolbox uses
% addpath( genpath([pwd filesep 'src' filesep 'MatPIV161']) );
% addpath( genpath([pwd filesep 'src' filesep 'MatPIV-1.7']) );
addpath( genpath([pwd filesep 'src' filesep 'MatPIV-1.7_bugfix']) );
addpath( genpath([pwd filesep 'src' filesep 'sort_nat']) );
addpath( genpath([pwd filesep 'src' filesep 'bipolar_colormap']) );
% addpath( genpath([pwd filesep 'src' filesep 'linspecer']) );
addpath( genpath([pwd filesep 'src' filesep 'pmkmp']) );
% addpath( genpath([pwd filesep 'src' filesep 'vivid']) );
% addpath( genpath([pwd filesep 'src' filesep 'colormaps_mathworks_v11']) );
% addpath( genpath([pwd filesep 'src' filesep 'export_fig']) );
% addpath( genpath([pwd filesep 'src' filesep 'toolbox_image']));
addpath( genpath([pwd filesep 'src' filesep 'par_save']) );
addpath( genpath([pwd filesep 'src' filesep 'vtkwrite']) );
addpath( genpath([pwd filesep 'src' filesep 'crop']) );
% addpath( genpath([pwd filesep 'src' filesep 'figuremaker']) );


%% INITIALIZE parallel Matlab (tested in R2015b ... it may not work in older versions like R2011b)
% because of reasons, ensure that you have no files open when opening the parallel pool
fclose('all');

delete(gcp('nocreate')); % in case we are re-sizing the pool, or this option deactivated
if OPTIONS.parallel_nCPUs > 1           
    parpool('local',OPTIONS.parallel_nCPUs);
end

%% RUN the entire toolchain of this toolbox

% start a clean logfile
diary off
% for n = 1:numel(dir_case)
      
    if OPTIONS.logfiles
        % start a new logfile for each directory of images
        logfile = [dir_case filesep 'log.dir_case'];
        disp(logfile);
        diary(logfile);   
    end
    
    % user can specify to skip certain directories
%     if any(n == OPTIONS.skip_case)
%         disp('something wrong in these cases, skipping, see your lab journal for details ... ')
%         diary off
%         continue
%     end
    
    % display sweet logo (see the awesome FIGLET program)
    disp('');
    disp('-----------------------------------------------------------------------------------');
    disp(' _______  ___   __   __          _______  _______  ___   _______  ___      ______  ');
    disp('|       ||   | |  | |  |        |  _    ||       ||   | |       ||   |    |      | ');
    disp('|    _  ||   | |  |_|  |        | |_|   ||    ___||   | |    ___||   |    |  _    |');
    disp('|   |_| ||   | |       |        |       ||   |___ |   | |   |___ |   |    | | |   |');
    disp('|    ___||   | |       |        |  _   | |    ___||   | |    ___||   |___ | |_|   |');
    disp('|   |    |   |  |     |  _____  | |_|   ||   |    |   | |   |___ |       ||       |');
    disp('|___|    |___|   |___|  |_____| |_______||___|    |___| |_______||_______||______| ');
    disp(['running dir_case: ' dir_case]);
    disp('-----------------------------------------------------------------------------------');
    disp('');

        
    %% 1) PRE-PROCESS the images (to clean them up) 
    % performs 3 operations: clean/prepare directory, detect "zombie images", ImageJ pre-processing
%     piv_bfield_prepare(OPTIONS, dir_case);
      
    % CALIBRATION IMAGE
    % should image calibration be automated in this script??? probably, but for now just load a transformation matrix from a .mat file
    % image_cal       = [dir_case filesep 'Calibration_PIV_Wake_YawAngle20degree_083015_tailsideside_0D0.tif'];
    
    %% 2) PROCESS the vector fields: velocity,vorticity
    % this is where MatPIV is called to performs the correlations between images, and filtering
    piv_bfield_vectors(OPTIONS, dir_case)
    
    %% 3) POST-PROCESS compute statistics
    % computes statistical quantities from image stack
    piv_bfield_stats(OPTIONS, dir_case)
      
    %% 4) POST-POST PROCESS make figure and movies
    % this prints figures of the vector/scalar fields
    piv_bfield_figures(OPTIONS, dir_case)
    
    if OPTIONS.FFMPEG
        % this creates a movie out of each scalar/vector field
        piv_bfield_movies(OPTIONS, dir_case);
    end
    
    
    %% all done, close the current logfile
    diary off
    
    
% end


%% CLEANUP shutdown safely
delete(gcp('nocreate'));
% isOpen = matlabpool('size');
% if isOpen > 0
%     matlabpool close;           % Close the distributed computing (this might vary between Matlab toolbox versions)        
% end


end % function

