function piv_bfield_figures(OPTIONS, dir_case)

disp('');
disp('-----------------------------------------------------------------------------------');
disp(' ______ _                           ');
disp('|  ____(_)                          ');
disp('| |__   _  __ _ _   _ _ __ ___  ___ ');
disp('|  __| | |/ _` | | | | .__/ _ \/ __|');
disp('| |    | | (_| | |_| | | |  __/\__ \');
disp('|_|    |_|\__, |\__,_|_|  \___||___/');
disp('           __/ |                    ');
disp('          |___/                     ');
disp(['making figures. dir_case: ' dir_case]);
disp('-----------------------------------------------------------------------------------');
disp('');
    
dir_figures = [dir_case filesep 'figures'];

% Define limits of colorbar scaling, this is flow dependent
% clims_Umag = [1000 4000];   % in pixel world
clims_Umag = [0.0 1.7];         % in meters world
% clims_u    = [-2000 2000]; 
clims_u    = [-0.7 0.7]; 


% define some colormaps
% pmkmp_maps = {'IsoAZ' 'IsoAZ180' 'Edge' 'Swtth' 'LinLhot' 'LinearL' 'IsoAZ'};  
cmap_LinLHot = flipud(pmkmp(11, 'LinLhot'));
cmap_bipolar = bipolar(21, 0.80);


% set some default font sizes
set(0,'defaultAxesFontSize', 24);
set(0,'defaultlinelinewidth',4)


% determine units for axis labels
if OPTIONS.T_inv == 1 && isempty(OPTIONS.mmpp)
    % pixels / second
    units_speed = ' (pixels / second)';
else
    % meters / second
    units_speed = ' (meters / second)';   
end



% .mat files of raw, and filtered and transformed vectors
files        = dir([dir_case filesep 'vectors' filesep 'raw' filesep '*.mat']);
fnames       = sort_nat({files.name}, 'ascend'); 	% sort the file list with natural ordering
fnames_raw   = fnames(:);                        	% reshape into a nicer list
files        = dir([dir_case filesep 'vectors' filesep 'instantaneous' filesep '*.mat']);
fnames       = sort_nat({files.name}, 'ascend'); 	% sort the file list with natural ordering
fnames_inst  = fnames(:);                        	% reshape into a nicer list
files        = dir([dir_case filesep 'vectors' filesep 'fluctuating' filesep '*.mat']);
fnames       = sort_nat({files.name}, 'ascend'); 	% sort the file list with natural ordering
fnames_fluct = fnames(:);                        	% reshape into a nicer list

%% plot instantaneous variables
parfor n = 1:numel(fnames_inst)

    
    %% Load in the variables to plot
    % load the .mat file of raw vectors 
    RAW = load([dir_case filesep 'vectors' filesep 'raw' filesep fnames_raw{n}]);
    pkh = RAW.pkh;
    snr = RAW.snr;
    
    % load the .mat file of instantaneous, filtered and transformed data 
    POST = load([dir_case filesep 'vectors' filesep 'instantaneous' filesep fnames_inst{n}]);
    x    = POST.x;
    y    = POST.y;
    fu   = POST.fu;
    fv   = -1 .* post.fv;    % because flow in images is going up-to-down
    fwz  = post.fwz;
    
    %% velocity magnitude 
    hFig = init_figure([]);
    
    Umag = sqrt(post.fu.^2 + post.fv.^2);
    
    contourf(post.x, post.y, Umag);

    colormap(cmap_LinLHot)
    
    title(['velocity magnitude ' units_speed])
    xlabel('')
    ylabel('')

    axis square
    colorbar;
    caxis(clims_Umag)
    
       
    saveas(hFig, [dir_figures filesep 'velocity_mag__' sprintf('%5.5d',n)], 'png')
    
    %% velocity U 
    hFig = init_figure([]);
           
    contourf(x, y, fu);
    
    colormap(cmap_bipolar)
    colorbar;
    
    title(['crossflow velocity ' units_speed])
    xlabel('')
    ylabel('')
    
    axis square
    colorbar;
    caxis(clims_u)
    caxis(clims_u)
        
    saveas(hFig, [dir_figures filesep 'velocity_u__' sprintf('%5.5d',n)], 'png')

    
    %% velocity V
    hFig = init_figure([]);
           
    contourf(x, y, fv);
    
    colormap(cmap_LinLHot)
    colorbar;
    
    title(['streamwise velocity ' units_speed])
    xlabel('')
    ylabel('')
    
    axis square
    colorbar;
    caxis(clims_Umag)
    
    saveas(hFig, [dir_figures filesep 'velocity_v__' sprintf('%5.5d',n)], 'png')
    
    
    %% Vorticity
    hFig = init_figure([]);
       
    contourf(x, y, fwz);
    
    colormap(cmap_bipolar)
    colorbar;
    
    axis square
    colorbar;
    caxis([-80 80])
    
    title('Vorticity (/s)')
    xlabel('')
    ylabel('')
    
    saveas(hFig, [dir_figures filesep 'vorticity_z__' sprintf('%5.5d',n)], 'png')
    
    
%     %% SLICE velocity U mag
%     hFig = init_figure([]);
%             
%     centerline_x = floor( size(x,1)/2 );
%     centerline_y = floor( size(x,2)/2 );   
%     
%     plot(1:size(x,1), Umag(centerline_y,:), '-r');
%     hold on
%     plot(1:size(y,2), Umag(:,centerline_x), '--b');
%     
%     hLeg = legend('slice crossflow','slice streamwise');
%     set(hLeg, 'color','none');
%         
%     grid on
%     title('velocity magnitude')
%     xlabel('distance along slice')
%     ylabel('speed (pixels / second)')
%     ylim([0 6000]);
%         
%     saveas(hFig, [dir_figures filesep 'slice_velocity_mag__' sprintf('%5.5d',n)], 'png')
%     
%     %% SLICE velocity U
%     hFig = init_figure([]);
%             
%     centerline_x   = floor( size(x,1)/2 );
%     centerline_y   = floor( size(x,2)/2 );
% 
%     plot(1:size(x,1), fu(centerline_y,:), '-r');
%     hold on
%     plot(1:size(y,2), fu(:,centerline_x), '--b');
%     
%     hLeg = legend('slice crossflow','slice streamwise');
%     set(hLeg, 'color','none');
%     
%     grid on
%     title('crossflow velocity')
%     xlabel('distance along slice')
%     ylabel('speed (pixels / second)')
%     ylim([-6000 6000]);
%     
%     saveas(hFig, [dir_figures filesep 'slice_velocity_u__' sprintf('%5.5d',n)], 'png')
% 
%     
%     %% SLICE velocity V
%     hFig = init_figure([]);
%             
%     centerline_x   = floor( size(x,1)/2 );
%     centerline_y   = floor( size(x,2)/2 );
%         
%     plot(1:size(x,1), fv(centerline_y,:), '-r');
%     hold on;
%     plot(1:size(y,2), fv(:,centerline_x), '--b');
%     
%     hLeg = legend('slice crossflow','slice streamwise');
%     set(hLeg, 'color','none');
%     
%     grid on
%     title('streamwise velocity')
%     xlabel('distance along slice')
%     ylabel('speed (pixels / second)')
%     ylim([-6000 6000]);
%     
%     saveas(hFig, [dir_figures filesep 'slice_velocity_v__' sprintf('%5.5d',n)], 'png')
%     
%     
%     %% SLICE vorticity
%     hFig = init_figure([]);
%             
%     centerline_x   = floor( size(fwz,1)/2 );
%     centerline_y   = floor( size(fwz,2)/2 );
%     
%     plot(1:size(fwz,1), fwz(centerline_y,:), '-r');
%     hold on;
%     plot(1:size(fwz,2), fwz(:,centerline_x), '--b');
%     
%     hLeg = legend('slice crossflow','slice streamwise');
%     set(hLeg, 'color','none');
%     
%     grid on
%     title('vorticity')
%     xlabel('distance along slice')
%     ylabel('vorticity (/s)')
%     ylim([-200 200]);
%     
%     saveas(hFig, [dir_figures filesep 'slice_vorticity_z__ ' sprintf('%5.5d',n)], 'png')
    
    
    %% cleanup (otherwise Matlab may give memory errors after creatting too many figure handles)
    close all;
    fclose all;
    
end % INSTANTANEOUS




%% plot statistical variables
% load in the statistics variables
STATS     = load([dir_case filesep 'vectors' filesep 'stats' filesep 'stats.mat']);
x         = STATS.x;
y         = STATS.y;
mean_u    = STATS.mean_u;
mean_v    = -1 .* STATS.mean_v;
mean_Umag = STATS.mean_Umag;
std_u     = STATS.std_u;
std_v     = STATS.std_v;
std_mag   = STATS.std_mag;
rms_u     = STATS.rms_u;
rms_v     = STATS.rms_v;
rms_mag   = STATS.rms_mag;
mean_wz   = STATS.mean_wz;
 
%% mean velocity magnitude normalized by inflow velocity
hFig = init_figure([]);

contourf(x, y, mean_Umag ./ OPTIONS.inflow);

colormap(cmap_LinLHot)

title(['mean velocity deficit magnitude, mean_U_mag / U_inflow'])
xlabel('mean_U_mag / U_inflow')
ylabel('')

axis square
colorbar;
caxis(clims_Umag)

saveas(hFig, [dir_figures filesep 'mean_velocity_mag_deficit'], 'png')

%% mean velocity magnitude 
hFig = init_figure([]);

contourf(x, y, mean_Umag);

colormap(cmap_LinLHot)
colorbar;

title(['mean velocity magnitude ' units_speed])
xlabel('')
ylabel('')

axis square
colorbar;
caxis(clims_Umag)

saveas(hFig, [dir_figures filesep 'mean_velocity_mag'], 'png')


%% mean velocity U 
hFig = init_figure([]);

contourf(x, y, mean_u);

colormap(cmap_bipolar)
colorbar;

title(['crossflow mean velocity ' units_speed])
xlabel('')
ylabel('')

axis square
colorbar;
caxis(clims_u)

saveas(hFig, [dir_figures filesep 'mean_velocity_u'], 'png')


%% mean velocity V
hFig = init_figure([]);

contourf(x, y, mean_v);

colormap(cmap_LinLHot)
colorbar;

title(['streamwise mean velocity ' units_speed])
xlabel('')
ylabel('')

axis square
colorbar;
caxis(clims_Umag)

saveas(hFig, [dir_figures filesep 'mean_velocity_v'], 'png')


%% Standard Deviation Magnitude
hFig = init_figure([]);

contourf(x, y, std_mag);

colormap(cmap_LinLHot)
colorbar;

title('standard deviation magnitude')
xlabel('')
ylabel('')
ylabel(cbar, ['standard deviation ' units_speed])

axis square
colorbar;
caxis([0 400])

saveas(hFig, [dir_figures filesep 'standard-deviation_mag'], 'png')


%% Mean Vorticity - NOT vorticity of the mean velocity
hFig = init_figure([]);

contourf(x, y, mean_wz);

colormap(cmap_bipolar)
colorbar;

axis square
colorbar;
caxis([-10 10])

title('mean vorticity (/s)')
xlabel('')
ylabel('')

saveas(hFig, [dir_figures filesep 'mean_vorticity_z'], 'png')



% %% SLICE mean velocity U mag
% hFig = init_figure([]);
% 
% centerline_x = floor( size(x,1)/2 );
% centerline_y = floor( size(x,2)/2 );   
% 
% plot(1:size(x,1), mean_Umag(centerline_y,:), '-r');
% hold on
% plot(1:size(y,2), mean_Umag(:,centerline_x), '--b');
% 
% hLeg = legend('slice crossflow','slice streamwise');
% set(hLeg, 'color','none');
%     
% grid on
% title('mean vorticity (/s)')
% xlabel('distance along slice')
% ylabel('mean speed (pixels / second)')
% 
% saveas(hFig, [dir_figures filesep 'mean_slice_velocity_mag'], 'png')
% 
% %% SLICE mean velocity U
% hFig = init_figure([]);
% 
% centerline_x   = floor( size(x,1)/2 );
% centerline_y   = floor( size(x,2)/2 );
% 
% plot(1:size(x,1), mean_u(centerline_y,:), '-r');
% hold on
% plot(1:size(y,2), mean_u(:,centerline_x), '--b');
% 
% hLeg = legend('slice crossflow','slice streamwise');
% set(hLeg, 'color','none');
% 
% grid on
% title('mean crossflow velocity')
% xlabel('distance along slice')
% ylabel('mean speed (pixels / second)')
% 
% saveas(hFig, [dir_figures filesep 'mean_slice_velocity_u'], 'png')
% 
% %% SLICE mean velocity V
% hFig = init_figure([]);
% 
% centerline_x   = floor( size(x,1)/2 );
% centerline_y   = floor( size(x,2)/2 );
% 
% 
% plot(1:size(x,1), mean_v(centerline_y,:), '-r');
% hold on;
% plot(1:size(y,2), mean_v(:,centerline_x), '--b');
% 
% hLeg = legend('slice crossflow','slice streamwise');
% set(hLeg, 'color','none');
% 
% grid on
% title('mean streamwise velocity')
% xlabel('distance along slice')
% ylabel('mean speed (pixels / second)')
% 
% saveas(hFig, [dir_figures filesep 'mean_slice_velocity_v'], 'png')
% 
% 
% %% SLICE mean vorticity
% hFig = init_figure([]);
% 
% centerline_x   = floor( size(mean_wz,1)/2 );
% centerline_y   = floor( size(mean_wz,2)/2 );
% 
% plot(1:size(mean_wz,1), mean_wz(centerline_y,:), '-r');
% hold on;
% plot(1:size(mean_wz,2), mean_wz(:,centerline_x), '--b');
% 
% hLeg = legend('slice crossflow','slice streamwise');
% set(hLeg, 'color','none');
% 
% grid on
% title('mean vorticity')
% xlabel('distance along slice')
% ylabel('mean vorticity (/s)')
% 
% saveas(hFig, [dir_figures filesep 'mean_slice_vorticity'], 'png')


%% Turbulence Intensity
hFig = init_figure([]);

TI = 100 * std_mag ./ mean_Umag;
% TI = 100 * (Umag - mean_Umag)./mean_Umag);
% TI = 100 * (sqrt(uP^2 + vP^2)) ./ mean_Umag);

contourf(x, y, TI); 

colormap(cmap_LinLHot)
colorbar;

title('Turbulence Intensity (%)')
xlabel('')
ylabel('')

axis square
colorbar;
caxis([1 40])

saveas(hFig, [dir_figures filesep 'turbulence-intensity'], 'png')

 
 
    
%% plot FLUCTUATING variables
parfor n = 1:numel(fnames_fluct)
    
        
    % load the .mat file of fluctuating, filtered and transformed data 
    FLUCT = load([dir_case filesep 'vectors' filesep 'fluctuating' filesep fnames_fluct{n}]);
    uP    = FLUCT.uP;
    vP    = FLUCT.vP;
    wzP   = FLUCT.wzP;
    
    %% fluctuating velocity magnitude 
    hFig = init_figure([]);
    
    UmagP = sqrt(uP.^2 + vP.^2);
           
    contourf(x, y, UmagP);

    colormap(cmap_LinLHot)
    colorbar;
    
    title(['fluctuating velocity magnitude ' units_speed])
    xlabel('')
    ylabel('')
    
    axis square
    colorbar;
    caxis([0 5000])
        
    saveas(hFig, [dir_figures filesep 'fluctuating_velocity_mag__' sprintf('%5.5d',n)], 'png')
    
    
    %% fluctuating velocity U 
    hFig = init_figure([]);
           
    contourf(x, y, uP);
    
    colormap(cmap_bipolar)
    colorbar;
    
    title(['fluctuating crossflow velocity ' units_speed])
    xlabel('')
    ylabel('')
    
    axis square
    colorbar;
    caxis(clims_u)
        
    saveas(hFig, [dir_figures filesep 'fluctuating_velocity_u__' sprintf('%5.5d',n)], 'png')

    
    %% fluctuating velocity V
    hFig = init_figure([]);
           
    contourf(x, y, vP);
    
    colormap(cmap_LinLHot)
    colorbar;
    
    title(['fluctuating streamwise velocity ' units_speed])
    xlabel('')
    ylabel('')
    
    axis square
    colorbar;
    caxis([0 200])
        
    saveas(hFig, [dir_figures filesep 'fluctuating_velocity_v__' sprintf('%5.5d',n)], 'png')
    
    
    %% fluctuating Vorticity 
    hFig = init_figure([]);
       
    contourf(x, y, wzP);
    
    colormap(cmap_bipolar)
    colorbar;
    
    axis square
    colorbar;
    caxis([-5 5])
    
    title('fluctuating Vorticity (/s)')
    xlabel('')
    ylabel('')
        
    saveas(hFig, [dir_figures filesep 'fluctuating_vorticity_z__' sprintf('%5.5d',n)], 'png')
    
    
%     %% SLICE fluctuating velocity U mag
%     hFig = init_figure([]);
%             
%     centerline_x = floor( size(x,1)/2 );
%     centerline_y = floor( size(x,2)/2 );   
% 
%     plot(1:size(x,1), UmagP(centerline_y,:), '-r');
%     hold on
%     plot(1:size(y,2), UmagP(:,centerline_x), '--b');
%     
%     hLeg = legend('slice crossflow','slice streamwise');
%     set(hLeg, 'color','none');
% 
%     grid on
%     title('fluctuating velocity magnitude')
%     xlabel('distance along slice')
%     ylabel('speed (pixels / second)')
%     ylim([0 5000]);
%         
%     saveas(hFig, [dir_figures filesep 'slice_fluctuating_velocity_mag__' sprintf('%5.5d',n)], 'png')
%     
%     %% SLICE fluctuating velocity U
%     hFig = init_figure([]);
%             
%     centerline_x   = floor( size(x,1)/2 );
%     centerline_y   = floor( size(x,2)/2 );
%         
%     plot(1:size(x,1), uP(centerline_y,:), '-r');
%     hold on
%     plot(1:size(y,2), uP(:,centerline_x), '--b');
%     
%     hLeg = legend('slice crossflow','slice streamwise');
%     set(hLeg, 'color','none');    
%     
%     grid on
%     title('fluctuating crossflow velocity')
%     xlabel('distance along slice')
%     ylabel('speed (pixels / second)')
%     ylim([-3000 3000]);
%     
%     saveas(hFig, [dir_figures filesep 'slice_fluctuating_velocity_u__' sprintf('%5.5d',n)], 'png')
% 
%     
%     %% SLICE fluctuating velocity V
%     hFig = init_figure([]);
%             
%     centerline_x   = floor( size(x,1)/2 );
%     centerline_y   = floor( size(x,2)/2 );
%         
%     plot(1:size(x,1), vP(centerline_y,:), '-r');
%     hold on;
%     plot(1:size(y,2), vP(:,centerline_x), '--b');
%     
%     hLeg = legend('slice crossflow','slice streamwise');
%     set(hLeg, 'color','none');    
%         
%     grid on
%     title('fluctuating streamwise velocity')
%     xlabel('distance along slice')
%     ylabel('speed (pixels / second)')
%     ylim([-3000 3000]);
%     
%     saveas(hFig, [dir_figures filesep 'slice_fluctuating_velocity_v__' sprintf('%5.5d',n)], 'png')
%     
%     
%     %% SLICE fluctuating vorticity
%     hFig = init_figure([]);
%             
%     centerline_x   = floor( size(wzP,1)/2 );
%     centerline_y   = floor( size(wzP,2)/2 );
%     
%     plot(1:size(wzP,1), wzP(centerline_y,:), '-r');
%     hold on;
%     plot(1:size(wzP,2), wzP(:,centerline_x), '--b');
%     
%     hLeg = legend('slice crossflow','slice streamwise');
%     set(hLeg, 'color','none');    
%         
%     grid on
%     title('fluctuating vorticity')
%     xlabel('distance along slice')
%     ylabel('vorticity (/s)')
%     ylim([-200 200]);
%     
%     saveas(hFig, [dir_figures filesep 'slice_fluctuating_vorticity_z__ ' sprintf('%5.5d',n)], 'png')

    
    %% fluctuating TKE
    hFig = init_figure([]);
    
    TKE = 0.5 * (uP.^2 + vP.^2);
           
    contourf(x, y, TKE);

    colormap(cmap_LinLHot)
    colorbar;
    
    title('')
    xlabel('')
    ylabel('')
    ylabel(cbar, ['turbulent kinetic energy ' units_speed])
    
    axis square
    colorbar;
%     caxis([0 500])
    % 
    saveas(hFig, [dir_figures filesep 'TKE__' sprintf('%5.5d',n)], 'png')
    
    
  
    
    %% cleanup (otherwise Matlab may give memory errors after creatting too many figure handles)
    close all;
    fclose all;
    
    
end
    
   
    
%% crop white space from all figure
crop(dir_figures);
    

end % function



















