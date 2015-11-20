function piv_bfield_findZombies(dir_case)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

system(['imagej -macro imageJ-macro-findZombies.ijm ' dir_case filesep 'raw' ',']);
    
dirInfo = dir([dir_case filesep 'raw']);                % Get structure of directory information
isDir = [dirInfo.isdir];                                % A logical index the length of the 
                                                     	%   structure array that is true for
                                                     	%   structure elements that are
                                                    	%   directories and false otherwise
dirNames = {dirInfo(isDir).name};                       % A cell array of directory names
fileNames = {dirInfo(~isDir).name};                     % A cell array of file names

cwd = pwd;
cd([dir_case filesep 'raw']);

% Construct a questdlg (question dialog) with three options
qstring = 'Is first image a ZOMBIE_IMAGE?';
choice1 = questdlg(qstring,'detect 1st zombie image',...
                  'Yes','No','No');
              
qstring = 'Is last image a ZOMBIE_IMAGE?';
choice2 = questdlg(qstring,'detect last zombie image',...
                  'Yes','No','No');              
% Handle response
switch choice1
    case 'Yes'
        disp([choice1 ' deleted 1st image (it is zombie image)'])
        delete(fileNames{1});
    case 'No'
        disp([choice1 ' keeping 1st image (it is correct)'])
end
% Handle response - Last Image
switch choice2
    case 'Yes'
        disp([choice2 ' deleted last image (it is zombie image)'])
        delete(fileNames{end});
    case 'No'
        disp([choice2 ' keeping last image (it is correct)'])
end

cd(cwd);

end % function

