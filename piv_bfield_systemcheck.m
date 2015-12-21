function STATUS = piv_bfield_systemcheck()
%piv_bfield_systemcheck will check if the system has all dependent software 
% installed and working. Check for: 
% Matlab Toolboxes, ImageJ, FFMPEG , (VisIt/ParaView ? )... 

STATUS = false; % assume everything good at first

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

