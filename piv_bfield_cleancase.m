function piv_bfield_cleancase(dir_case)

%% case directory expected to contain these subfolders
dir_images_post = [dir_case filesep 'post'];
dir_vectors     = [dir_case filesep 'vectors'];
dir_figures     = [dir_case filesep 'figures'];

%% now delete all files in each subdirectory
% [status, message, messageid] = rmdir(folderName,'s') removes the folder folderName and its contents from the current folder, returning the status, a message, and the MATLAB� message ID.
status = rmdir(dir_images_post,'s');
status = rmdir(dir_vectors,'s');
status = rmdir(dir_figures,'s');

success = mkdir(dir_images_post);
success = mkdir(dir_vectors);
success = mkdir([dir_vectors filesep 'raw']);
success = mkdir([dir_vectors filesep 'instantaneous']);
success = mkdir([dir_vectors filesep 'fluctuating']);
success = mkdir([dir_vectors filesep 'stats']);
success = mkdir([dir_vectors filesep 'vtk']);
success = mkdir(dir_figures);

% (the user should create the "raw" folder themselves and dump all images into)
% success = mkdir([dir_case filesep 'raw']);
% system(['mv ' dir_case filesep '*.tif ' dir_case filesep 'raw' filesep]);

% copy the ParaView state files into same directory (for convenience)
system(['cp *.pvsm ' dir_case filesep 'vectors' filesep 'vtk']);

if ~status || ~success
    fprintf(1, '[ERROR: cannot remove directories, check your file permissions priveledges, or close any open files] \n');
end

end % function