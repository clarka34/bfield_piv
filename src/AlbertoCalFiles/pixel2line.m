function [xyz0,direction]=pixel2line(L,C,calib_prefix,NZZ,ZZ)

% L - linne
% C - Column
% calib_prefix - Name of the calibration file
% NZZ=[1 7 13]; - Number of the plane  
% ZZ=[-6 0 6]; - Real position of the plane 

Np=length(ZZ);

for k=1:Np
    fname=[calib_prefix num2str(NZZ(k)) '.mat'];
    load(fname,'T');
    [Xtmp,Ytmp]=tforminv(T,[C L]);
    XX(k)=Xtmp;
    YY(k)=Ytmp;
end

[xyz0,direction]=fit3Dline([XX' YY' ZZ']);