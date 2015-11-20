function STATUS = piv_bfield_systemcheck()
%piv_bfield_systemcheck will check if the system has all dependent software 
% installed and working. Check for: 
% Matlab Toolboxes, ImageJ, FFMPEG , (VisIt/ParaView ? )... 

STATUS = false; % assume everything good at first


%% ADD TO PATH dependencies that this toolbox uses (there are more ideas to implement)
% addpath( genpath([pwd filesep 'src' filesep 'MatPIV-1.7']) );
addpath( genpath([pwd filesep 'src' filesep 'MatPIV-1.7_bugfix']) );
addpath( genpath([pwd filesep 'src' filesep 'sort_nat']) );
addpath( genpath([pwd filesep 'src' filesep 'bipolar_colormap']) );
% addpath( genpath([pwd filesep 'src' filesep 'linspecer']) );
% addpath( genpath([pwd filesep 'src' filesep 'pmkmp']) );
% addpath( genpath([pwd filesep 'src' filesep 'export_fig']) );
% addpath( genpath([pwd filesep 'src' filesep 'toolbox_image']) );
% addpath( genpath([pwd filesep 'src' filesep 'docsgen_dot_tools']) );
% addpath( genpath([pwd filesep 'src' filesep 'fdep_21jun2010']) );
% addpath( genpath([pwd filesep 'src' filesep 'plot_depfun_20150521']) );


%% check Matlab toolboxes are installed
% Check that user has the Image Processing Toolbox installed.
hasIPT = license('test', 'image_toolbox');
if ~hasIPT	
    STATUS_IPT = true;
    disp('[ERROR] Image Processing Toolbox is not found');
else
    disp('Image Processing Toolbox is found')
end


%% check ImageJ
if ispc         % on Windows
    [status, result] = system('where imagej');
elseif isunix   % on GNU/Linux
    [status, result] = system('which imagej');
else
    % which OS ?
end

if status > 0
    STATUS_IMAGEJ = true;
    disp('[ERROR] ImageJ is not installed, or Matlab cannot find it');
else
    disp('ImageJ is found')
end


%% check FFMPEG
[status, result] = system('ffmpeg -version');
if status > 0
    STATUS_FFMPEG = true;
    disp('[ERROR] FFMPEG is not installed, or Matlab cannot find it');
    disp('[DEBUG] for Matlab to find FFMPEG, try to start Matlab with similar command:');
    disp('[DEBUG] LD_PRELOAD=/usr/lib64/libstdc++.so.6.0.19 matlab');   % this might require different version of libstdc
else
    disp('FFMPEG is found')
end


%% check VisIt/ParaView (not sure if need this yet)


end % function

