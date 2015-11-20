function [xyz0,direction]=fit3Dline(XYZ)

xyz0=mean(XYZ);
A=bsxfun(@minus,XYZ,xyz0); %center the data

[U,S,V]=svd(A);

direction=cross(V(:,end),V(:,end-1) );
