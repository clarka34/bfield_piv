function piv_bfield_prepare(OPTIONS, dir_case)

if OPTIONS.firstTime
    piv_bfield_cleancase(dir_case);
end
    
if OPTIONS.findZombies && OPTIONS.ImageJ
    % this just opens the image stack in ImageJ, then you should just
    % manually inspect the first and last image pairs, you will visually
    % see if there is any correlation, and then a GUI prompt asks you if
    % first or last images should be deleted (because it is a zombie)
    piv_bfield_findZombies(dir_case);
end
    
% run ImageJ to:
%   1) computes average intensity of base & cross images (laser pulse has
%   different intensity for the "base" & "cross" pulses, so compute the
%   average intensities separate), then subtract the average value from each
%   image stack, this brings the background levels to ~ zero
%   2) enhance contrast which reduces correlation peak-to-peak differences (this
%   operation does not require to be split between base & cross image stacks)
%   3) convert all to 8-bit images
    
% THIS REQUIRES IMAGEJ TO BE INSTALLED and callable from the command line
%     FUDGE -- Windows seems to require 8-bit at all times, while *nix
%     can accept 16-bit images -- I guess should convert to 8-bit first
%     to enforce cross-compatibility ... just use ImageJ to convert the
%     entire stack to 8-bit:
%     ... actually I cannot install on Windows for other Java related
%     errors
    
% case directory expected to contain these subfolders
dir_images_raw  = [dir_case filesep 'raw'];
dir_images_post = [dir_case filesep 'post'];
    
if OPTIONS.ImageJ  
    switch OPTIONS.LaserType    
        case 'pulse'
%             system(['imagej -t     imageJ-macro-runstack-pulse.ijm ' dir_images_raw ',' dir_images_post]);    % shows the GUI and windows pop-up, useful for debugging
            system(['imagej -batch imageJ-macro-runstack-pulse.ijm ' dir_images_raw ',' dir_images_post]);    % does not show any GUI or windows, better for headless mode
        case 'continuous'
%             system(['imagej -t     imageJ-macro-runstack-continuous.ijm ' dir_images_raw ',' dir_images_post]);    % shows the GUI and windows pop-up, useful for debugging            
            system(['imagej -batch imageJ-macro-runstack-continuous.ijm ' dir_images_raw ',' dir_images_post]);    % does not show any GUI or windows, better for headless mode
        otherwise
            error('[ERROR] what kind of laser?');
    end  
else
    copyfile(dir_images_raw,dir_images_post)
end

end % function