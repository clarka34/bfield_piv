function piv_bfield_vectors(OPTIONS, dir_case)

%% PROCESSING velocities and vorticity

% case directory expected to contain these subfolders (should be setup automatically by "prepare")
dir_images_post = [dir_case filesep 'post'];
dir_images_post = [dir_case filesep 'post2_every10'];
dir_vectors     = [dir_case filesep 'vectors'];

files  = dir([dir_images_post filesep '*.tif']);
fnames = sort_nat({files.name}, 'ascend');          % sort the file list with natural ordering
fnames = fnames(:);                                 % reshape into a nicer list

if isempty(fnames)
    error('[ERROR] The "post" directory contains no images ... ');
end


switch OPTIONS.LaserType    
    case 'pulse'
        % ASSIGN image pairs (base and cross)
        num_pairs = numel(fnames) / 2;
%         im_b      = fnames(1:2:end);
%         im_c      = fnames(2:2:end);
        im_b      = fnames(1:num_pairs);
        im_c      = fnames(num_pairs+1:end);      
    case 'continuous'
        num_pairs = numel(fnames) - 2;
        im_b      = fnames(1:end-1);
        im_c      = fnames(2:end);
    otherwise
        error('[ERROR] what kind of laser?');
end



% decide if you want to process ALL the images or just a subset
if isempty(OPTIONS.max_images)
    % keep all the images
else
    if OPTIONS.max_images > num_pairs
        % keep all the images
    else
        % keep only the first 
        num_pairs   = OPTIONS.max_images;
        im_b(num_pairs+1:end) = [];
        im_c(num_pairs+1:end) = [];
    end
end

% determine stencil size for vorticity calculation method
switch OPTIONS.method_vort  % it is the ghost size minus 1 for the 
    case 'circulation'
        offset = 2 - 1;
    case 'leastsq'  % or Richardson
        offset = 3 - 1;
    otherwise
        error('[ERROR] unrecognized options for method_vort');
end 
    
% compute the initial velocity (this might speed up MatPIV, but have only seen like few percent speedup
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


% parfor n = 1:num_pairs
parfor (n = 1:num_pairs, OPTIONS.parallel_nCPUs)      % for debugging ... testing for temporary variables  
    if OPTIONS.runMatPIV
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
                                             OPTIONS.relpathToMask, ...
                                             init_u, ...
                                             init_v);

    %         % store the new initial velocity for the next iteration
    %         init_u = u;  % WARNING: using initial guess in a parfor loop is non-deterministic
    %         init_v = v;

        else
            [x, y, u, v, snr, pkh] = matpiv([dir_images_post filesep im_b{n}], ...
                                            [dir_images_post filesep im_c{n}], ...
                                            OPTIONS.win_size, ...
                                            OPTIONS.t_sep, ...
                                            OPTIONS.overlap, ...
                                            OPTIONS.method, ...
                                            OPTIONS.coordWorld, ...
                                            OPTIONS.relpathToMask);
        end
        
        % DO MASK THINGS
        if ~isempty(OPTIONS.relpathToMask)
            MASK = load([char(dir_case) filesep 'CALIBRATION' filesep char(mask_n)]);   % load the .mat mask file (created with MatPIV utility)
            m    = double( MASK.maske.msk );
            m    = m(9:8:end,9:8:end); % downsampling (THIS IS HARDCODED - should generalize this by detecting image size?)

            % PUT ON THE MASK (SOMEBODY STOP ME ... anybody remember that movie?) 
            u = m .* u;
            v = m .* v;
        end

        % Coordinate Transformation from pixels to meters
        xT = OPTIONS.T_inv * x;         % avoid "temporary variables" here, also do not "double transform" the data
        yT = OPTIONS.T_inv * y;
        uT = OPTIONS.T_inv * u;
        vT = OPTIONS.T_inv * v;
        if ~isempty(OPTIONS.mmpp)
            xT = xT*OPTIONS.mmpp/1000;      % (meters)
            yT = yT*OPTIONS.mmpp/1000;      % (meters)
            uT = uT*OPTIONS.mmpp/1000;      % (meters/second)
            vT = vT*OPTIONS.mmpp/1000;      % (meters/second)
        end
    
        % save the raw data, and has been transformed into real world coordinates (unless use specify pixel world)
        raw_x   = xT; % cumbersome to rename variable so many times
        raw_y   = yT;
        raw_u   = uT;
        raw_v   = vT;
        raw_snr = snr;
        raw_pkh = pkh;
        par_save([dir_vectors filesep 'raw' filesep 'raw__' sprintf('%5.5d', n)], ...
                 raw_x, raw_y, raw_u, raw_v, raw_snr, raw_pkh)

    end
        
    % FILTERING of the raw velocity fields
    if OPTIONS.runMatPIV && OPTIONS.applyFilters
        % MatPIV was re-run, so "raw data" has changed
        [u, v] = piv_bfield_filters(OPTIONS, x, y, u, v, snr, pkh);
        
    elseif ~OPTIONS.runMatPIV && OPTIONS.applyFilters
        % not re-running MatPIV, but applying a new filter
        % at this point the raw velocity vectors are already saved to hard
        % drive, should load them from hard drive to apply new filtering
        RAW    = load([dir_vectors filesep 'raw' filesep 'raw__' sprintf('%5.5d', n) '.mat']);
        [u, v] = piv_bfield_filters(OPTIONS, RAW.x, RAW.y, RAW.u, RAW.v, RAW.snr, RAW.pkh);
        
    elseif ~OPTIONS.runMatPIV && ~OPTIONS.applyFilters
        % not re-running MatPIV, and not applying a new filter (so only the post-processing stuff will be re-run)
        % the "filtered data" are already saved to hard drive, so load them now
        RAW = load([dir_vectors filesep 'raw' filesep 'raw__' sprintf('%5.5d', n)]);
        u   = RAW.u;
        v   = RAW.v;
        
    else
        error('[ERROR] unrecognized options related to re-running MatPIV or filtering');
    end
    
    % "raw data" is no longer needed, consider it now "filtered data"
    fu = u;
    fv = v;
    
    if ~OPTIONS.runMatPIV && ~OPTIONS.applyFilters
        % not re-running MatPIV, and not applying a new filter (so only the post-processing stuff will be re-run)
        % at this point, the 'instantaneous' .mat files, and corresponding
        % VTK files are saved to hard drive ... do nothing
        
    else
        % either MatPIV was re-run, or a new filtering was applied (the "raw data" has been changed)
        
        % interpolate the outliers because otherwise figures & movies (post-processing) look bad, especially vorticity
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
           
end

end % function

