function F = interppixel2line(NL,NC,NiL,NiC,calib_prefix,NZZ,ZZ)

% F=interppixel2line(NL,NC,NiL,NiC,calib_prefix,NZZ,ZZ)
%
% NL = number of lines per image (px)
% NC = number of columns per image (px)
% NiL = number of interpolating points in lines
% NiC = number of interpolating points in columns
% calib_prefix - Name of the calibration file
% NZZ=[1 7 13]; - Number of the plane  
% ZZ=[-6 0 6]; - Real position of the plane 

stepL=floor(NL/NiL);
stepC=floor(NC/NiC);

LL=1:stepL:NL;
CC=1:stepC:NC;

[L C]=ndgrid(LL,CC);

% L=reshape(L,1,[]);
% C=reshape(C,1,[]);

% V=zeros(size(L,1),size(L,2),5);
V=zeros(size(L,1),size(L,2),6);


for k=1:size(L,1)
    for j=1:size(L,2)
        [xyz0,direction]=pixel2line(L(k,j),C(k,j),calib_prefix,NZZ,ZZ);
        %V(k,j,:)=[xyz0(1:2) direction'];
        V(k,j,:)=[xyz0 direction'];
    end
end

% size(V)
% size(C)

F(1).f=griddedInterpolant(L,C,V(:,:,1));
F(2).f=griddedInterpolant(L,C,V(:,:,2));
F(3).f=griddedInterpolant(L,C,V(:,:,3));
F(4).f=griddedInterpolant(L,C,V(:,:,4));
F(5).f=griddedInterpolant(L,C,V(:,:,5));
F(6).f=griddedInterpolant(L,C,V(:,:,6));

end


