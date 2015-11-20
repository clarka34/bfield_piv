function piv_bfield_movies(OPTIONS, dir_case)


%% make movie using FFMPEG

files  = dir([dir_case filesep 'figures' filesep '*.png']);
fnames = sort_nat({files.name}, 'ascend'); 	% sort the file list with natural ordering
fnames = fnames(:);                        	% reshape into a nicer list

for n = 1:numel(fnames)
    % drop the __00000.png (9 characters)
   names_prefix{n} = fnames{n}(1:end-9);
    
end

% find the number occurences of each filename, anything with only 1
% occurence cannot be made into movie
    
[uniqueStrings, ~, v] = unique(names_prefix(:));
% occurrence = accumarray(v,1); %// Or: occurrence = histc(v,unique(v));

k = 0;
for n = 1:numel(uniqueStrings)   
    if strcmp(uniqueStrings{n}(end-1:end), '__')
        % the last two characters are "__" indications a image sequence
        k = k + 1;
        movie_names{k} = uniqueStrings{n};
    end   
end


iminfo = imfinfo([dir_case filesep 'figures' filesep fnames{1}]);
w      = iminfo.Width;
h      = iminfo.Height;


dir_here  = pwd;
dir_there = [dir_case filesep 'figures']; 
cd(dir_there);
for k = 1:numel(movie_names)
    system(['ffmpeg -framerate ' num2str(OPTIONS.fps) ' -i ' movie_names{k} '%05d.png -s:v ' num2str(w) 'x' num2str(h) ' -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p ' 'movie_' movie_names{k} '.mp4']);
end
cd(dir_here);

end % function

