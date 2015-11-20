function piv_bfield_vectors(OPTIONS, dir_case)

%% PROCESSING velocities and vorticity

% case directory expected to contain these subfolders
dir_images_post = [dir_case filesep 'post'];
dir_vectors     = [dir_case filesep 'vectors'];

files  = dir([dir_images_post filesep '*.tif']);
fnames = sort_nat({files.name}, 'ascend');          % sort the file list with natural ordering
fnames = fnames(:);                                 % reshape into a nicer list

if isempty(fnames)
    error('[ERROR] The "post" directory contains no images');
end

% ASSIGN image pairs (base and cross)
num_pairs   = numel(fnames) / 2;
% im_b        = fnames(1:2:end);
% im_c        = fnames(2:2:end);
im_b        = fnames(1:num_pairs);
im_c        = fnames(num_pairs+1:end);

if isempty(OPTIONS.max_images)
    % keep all the images
else
    if OPTIONS.max_images > num_pairs
        % keep all the iamges
    else
        % keep only the first 
        num_pairs   = OPTIONS.max_images;
        im_b(num_pairs+1:end) = [];
        im_c(num_pairs+1:end) = [];
    end
end

% determine stencil size for vorticity calculation method
switch OPTIONS.method_vort
    case 'circulation'
        offset = 2 - 1;
    case 'leastsq'  % or Richardson
        offset = 3 - 1;
    otherwise
        error('[ERROR] unrecognized options for method_vort');
end 
    
% compute the initial velocity (this might speed up MatPIV, but I have only seen like few percent speedup)
if OPTIONS.use_init_vel
    [~, ~, init_u, init_v, ~, ~] = matpiv([dir_images_post filesep im_b{1}], ...
                                          [dir_images_post filesep im_c{1}], ...
                                          OPTIONS.win_size, ...
                                          OPTIONS.t_sep, ...
                                          OPTIONS.overlap, ...
                                          OPTIONS.method, ...
                                          OPTIONS.coordWorld, ...
                                          OPTIONS.pivMask);
else
    init_u = [];
    init_v = [];
end


parfor n = 1:num_pairs   
    
    n
     
    % NOTE: use matpiv in pixel/second coordinates, and perform the world
    %       coordinate transfomation afterwards  
    if OPTIONS.use_init_vel   
        [x, y, u, v, snr, pkh] = matpiv([dir_images_post filesep im_b{n}], ...
                                        [dir_images_post filesep im_c{n}], ...
                                        OPTIONS.win_size, ...
                                        OPTIONS.t_sep, ...
                                        OPTIONS.overlap, ...
                                        OPTIONS.method, ...
                                        OPTIONS.coordWorld, ...
                                        OPTIONS.pivMask, ...
                                        init_u, ...
                                        init_v);
%                                     
%         % store the new initial velocity for the next iteration
%         init_u = u;  % WARNING: using initial guess in a parfor loop is non-deterministic
%         init_v = v;
%         
    else
        [x, y, u, v, snr, pkh] = matpiv([dir_images_post filesep im_b{n}], ...
                                        [dir_images_post filesep im_c{n}], ...
                                        OPTIONS.win_size, ...
                                        OPTIONS.t_sep, ...
                                        OPTIONS.overlap, ...
                                        OPTIONS.method, ...
                                        OPTIONS.coordWorld);
    end                                                            	
    % save the raw data
    par_save([dir_vectors filesep 'raw' filesep 'raw__' sprintf('%5.5d', n)], ...
             x, y, u, v, snr, pkh)
         
         
    % FILTERING of the raw velocity fields
    fu = u; % "raw data" is no longer needed
    fv = v;
    if OPTIONS.applyFilters         
        [fu, fv] = piv_bfield_filters(OPTIONS, x, y, fu, fv);
    end
   
         
    % Coordinate Transformation from pixels to centimeters
    x   = OPTIONS.T_inv * x;
    y   = OPTIONS.T_inv * y;
    fu  = OPTIONS.T_inv * fu;
    fv  = OPTIONS.T_inv * fv;
    
    % interpolate the outliers because otherwise figures & movies look bad,
    % and vorticity
    [fu, fv] = naninterp(fu, fv, 'linear', x, y);

    % VORTICITY 
    % interpolate the outliers because computing the curl fails miserably if many NANs are present, and figures/movies look bad
    fwz = vorticity(x, y, fu, fv, OPTIONS.method_vort);
    fwz = padarray(fwz,[offset offset]);                % pad with zeros to make same size as velocity arrays
    
    % save instantaneous variables, the filtered and transformed vectors (even if no filtering/transform was performed, just so filenaming is consistent)
    par_save([dir_vectors filesep 'instantaneous' filesep 'instantaneous__' sprintf('%5.5d', n)], ...
             x, y, fu, fv, fwz)
         
    % export instantaneous variables as VTK files, compatible with ParaView and VisIt
    z   = zeros(size(x));         % fake 3rd dimension coordinate
    fw  = zeros(size(x));         % fake 3rd dimension velocity
    fwx = zeros(size(x));         % fake 1st dimension vorticity
    fwy = zeros(size(x));         % fake 2nd dimension vorticity
    vtkwrite([dir_vectors filesep 'vtk' filesep 'vtk_velocity_instantaneous__' sprintf('%5.5d', n) '.vtk'], ...
             'structured_grid',x,y,z, 'vectors','velocity',fu,fv,fw)  
    vtkwrite([dir_vectors filesep 'vtk' filesep 'vtk_vorticity_instantaneous__' sprintf('%5.5d', n) '.vtk'], ...
             'structured_grid',x,y,z, 'vectors','vorticity',fwx,fwy,fwz)
         
         
end


end % function

