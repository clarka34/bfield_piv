function [pimg,pos2D,T,Tinv,aRoi]=cali2Dg_v1(fname,bgnd,lnoise,Size_dot,Delta_dot,aRoi)
%
% [pimg,pos2D,T,Tinv]=cali2Dd(fname,ctr_finding,Size_dot,Delta_dot,lnoise,area)
% cali2Dg_v1('Calibration_PIV_Wake_YawAngle20degree_083015_tailsideside_0D0.tif','',2,20,10)
% fname = calibration image file
% ctr_finding = 'com' or 'com_nw' or 'gaussian'
% Size_dot : typical diameter, in pixels, of dots in mask image
% Delta_dot : grid spacing of calibration mask in mm
% lnoise : typical lengthscal of image noise;
%
% pimg : center coordinates in original image
% pos2D : center coordinates in real world
% T : transformation from real world to image
% Tinv : transformation from image to real world

%Modify by Miguel Lopez-Caballero %% 03/04/2014

%promptstr='This program process calibration images and compute calibration parameters for PTV experiments.\n\n';
ncams=1;
gridsize=Delta_dot;
movingaxis='z';
maskaxis=['x', 'y'];

%img_inversion = input('If the patterns are darker than background, you need to invert the image. \n Do you want to invert? (y/n)  ', 's');
nfig = figure;
for icam = 1:ncams
    axispos=0;
    pimg = [];
    pos3D = [];   
   
    % Image processing
 %   im=imcomplement(imread(fname));
    imb=imread(fname);
    if ~isempty(bgnd)
        %bkg=imcomplement(imread(bgnd));
        bkg=imread(bgnd);
    else
        bkg=imopen(imb,strel('disk',ceil(3*Size_dot)));
    end
    
    Iimg=imsubtract(imb,bkg);
  %  Iimg=im+(bkg-imb)*4;
    
    clear bkg imb
    Iimg=bpass(Iimg,lnoise,Size_dot);
    hy = fspecial('disk',ceil(Size_dot/4));
    Iimg = imfilter(double(Iimg), hy, 'replicate');
    clear hy
    
    %
    [Npix_y Npix_x] = size(Iimg);
    
    figure(nfig);
    redo = 'y';
    while strcmp(redo, 'y')
        xc=[];
        yc=[];
        Ap=[];
        Ith = zeros(Npix_y, Npix_x);
        h1 = subplot('position', [0.05 0.3 0.4 0.6]);
        h2 = subplot('position', [0.05 0.08 0.4 0.15]);
        h3 = subplot('position', [0.55 0.3 0.4 0.6]);
        subplot(h1);
        imagesc(Iimg);colormap(gray);
        hold on;
        title(fname);
        
        %%
        disp('Now please indicate a square or rectangular region of interest in real space');
        
        if ~exist('aRoi','var')
            [BW_roi,xi,yi]=roipoly;
            aRoi=[xi(1:4) yi(1:4)];
        else
            [BW_roi,xi,yi]=roipoly(Iimg,aRoi(1:4,1),aRoi(1:4,2));
            aRoi=[xi(1:4) yi(1:4)];
        end
        a0=[0 0; 1 0; 1 1; 0 1];
        T0=cp2tform(aRoi,a0,'projective');
        
        %%
        Ith=zeros(size(Iimg));
        Nhist = hist(reshape(double(Iimg), size(Iimg,1)*size(Iimg,2), 1), [0:255]);
        
        subplot(h2);
        semilogy([0:255], Nhist, 'b-');
        axis([0 255 1 10000]);
        th = input('Please choose threshold   ');
        Amin=10;
        
        %imm=bwareaopen(Iimg>th,0.5*Size_dot^2);
        imm=bwareaopen(Iimg>th,Size_dot);
        SS=regionprops(imm>0.3,'Centroid','Area');
        Apsub=[SS.Area]';
        XX=reshape([SS.Centroid],2,[])';
        xc=XX(:,1);
        yc=XX(:,2);
        
        Ap = [Ap ; Apsub];
        Ith = double((Iimg)>th);
        
        subplot(h3);
        [Itht,xx,yy]=imtransform(Iimg,T0,'Size',size(Ith));
        imagesc(xx,yy,Itht);colormap('gray')
        hold on;
        
        xc0=xc;
        yc0=yc;
        [xc,yc]=tformfwd(T0,xc0,yc0);
        
        plot(xc, yc, 'r+');
        hold off
        
        redo = input('Do you want to re-process the image? (y/n)   ', 's');
    end
    Np = length(xc);
		
    % Manually remove some points if it's more convenient
    rmman = input('Do you want to manually remove some possibly wrong particles? (y/n)  ', 's');
    if (lower(rmman(1)) == 'y')
        ind = ones(Np,1);
        nrm = 0;
        rmzone=input('Do you want to remove a full zone?  ','s');
        hold on
        if (lower(rmzone(1))=='y')
            nb_zones=input('How many zones do you want to remove?  ');
            for i=1:nb_zones
                disp('Click the top left and bottom right of the second figure')
                [xzone1 yzone1]=ginput(1);
                [xzone2 yzone2]=ginput(1);
                irm=find(xc>xzone1 & xc<xzone2 & yc>yzone1 & yc<yzone2);
                nrm=nrm+length(nrm);
                ind(irm)=0;
                plot(xc(irm), yc(irm), 'ro');
            end
            
        end
        
        disp('Please click the particle centers that you want to remove.');
        disp('Right click the mouse when you are done.');
        but = 1;
        
        while but ~= 3
            [xrm yrm but] = ginput(1);
            if but == 1
                dist = (xc-xrm).^2+(yc-yrm).^2;
                [mindist irm] = min(dist);
                plot(xc(irm), yc(irm), 'ro');
                ind(irm) = 0;
                nrm = nrm+1;
            end
        end
        hold off
        xc = xc(logical(ind));
        yc = yc(logical(ind));
        xc0 = xc0(logical(ind));
        yc0 = yc0(logical(ind));
        
        Ap = Ap(logical(ind),:);
        Np = length(xc);
        disp(strcat(num2str(nrm), ' points have been removed. Please check the image again'));
        
        imagesc(xx,yy,Itht)
        hold on;
        plot(xc, yc, 'r+');
        hold off
    end
    
    % Find three base points that defines a triad
    disp('Now please indicate the three base point on the mask by click mouse on the thresholded image in order [0 0], [1 0], [0 1].');
    % First base point
    but = 0;
    while but ~= 1
        [x0 y0 but] = ginput(1);
    end
    dist = (xc-x0).^2+(yc-y0).^2;
    [mindist i0] = min(dist);
    subplot(h3);
    hold on
    plot(xc(i0), yc(i0), 'bo');
    i0xind = 0;
    i0yind = 0;
    
    % Second base point
    but = 0;
    while but ~= 1
        [x1 y1 but] = ginput(1);
    end
    dist = (xc-x1).^2+(yc-y1).^2;
    [mindist i1] = min(dist);
    plot(xc(i1), yc(i1), 'bo');
    i1xind = 1;
    i1yind = 0;
    
    % Third base point
    but = 0;
    while but ~= 1
        [x2 y2 but] = ginput(1);
    end
    dist = (xc-x2).^2+(yc-y2).^2;
    [mindist i2] = min(dist);
    plot(xc(i2), yc(i2), 'bo');
    i2xind = 0;
    i2yind = 1;
    
    % Now determine the point coordinates
    % first, form two base vectors on the mask
    e1 = [i1xind-i0xind, i1yind-i0yind];
    e2 = [i2xind-i0xind, i2yind-i0yind];
    % The projection of these two vectors on image plane
    e1p = [xc(i1)-xc(i0), yc(i1)-yc(i0)];
    e2p = [xc(i2)-xc(i0), yc(i2)-yc(i0)];
    e1pnorm = sum(e1p.^2);
    e2pnorm = sum(e2p.^2);
    e1pe2p = sum(e1p.*e2p);
    d = (e1pnorm*e2pnorm - e1pe2p*e1pe2p);		% The denominator
    % Calculate the coords of all points using the two base vectors
    pind = zeros(Np, 2);
    
    for i=1:Np
        c = [xc(i)-xc(i0), yc(i)-yc(i0)];
        A = (sum(c.*e1p)*e2pnorm - sum(c.*e2p)*e1pe2p)/d;
        B = (sum(c.*e2p)*e1pnorm - sum(c.*e1p)*e1pe2p)/d;
        pind(i,:)=[A B];
    end
    
    % Now calculate the two components of dots' 3D coordinates on the mask plane
    pmask = zeros(Np,2);
    for i=1:Np
        pmask(i,:) = floor(e1*pind(i,1) +0.5) + floor(e2*pind(i,2)+0.5) + [i0xind i0yind];
    end
    
    % Check to see if there is any inconsistency
    ncoll = 0;
    icoll = [];
    for i=2:Np
        for j = 1:i-1
            if (pmask(i,1) == pmask(j,1)) & (pmask(i,2) == pmask(j,2))
                ncoll = ncoll+1;
                icoll = [icoll; [i j]];
            end
        end
    end
    if ncoll == 0
        disp('No conflicts found, but please still check particle coordinates.');
    else
        str = sprintf('Some particle coordinates are probably wrong. %d conflicts found: \n', ncoll);
        for  ic = 1:ncoll
            str = strcat(str, sprintf('(%d, %d)\n', pmask(icoll(ic),:)));
        end
        disp(str);
    end
    
    subplot(h3)
    imagesc(Ith);
    hold on;
    plot(xc, yc, 'r+');
    plot(xc(i0), yc(i0), 'bo');
    plot(xc(i1), yc(i1), 'bo');
    plot(xc(i2), yc(i2), 'bo');
    for i=1:Np
        str = strcat('(',num2str(pmask(i,1)),',',num2str(pmask(i,2)),')');
        text(xc(i), yc(i), str, 'Color', 'g');
    end
    hold off
    
    pmask = pmask*gridsize;
    p3D = [pmask axispos(1)*ones(Np,1)];
    
    pimg = [pimg; [xc0 yc0]];
    pos3D = [pos3D; p3D];
    pos2D=pos3D(:,1:2);
    
    % Type of transformation
    ttype='polynomial';
    Tinv=cp2tform(pimg,pos2D,ttype,3);
    T=cp2tform(pos2D,pimg,ttype,3);
    
    % Original image and it's transformation
    im = imread(fname);
    %IT = imtransform(im, Tinv, 'Xdata' , [-130 130], 'Ydata', [-60  60], 'XYScale',0.08);
    [IT,xx,yy ] = imtransform(im, Tinv);
    
    %
    subplot(h1)
    imagesc(im)
    axis image;
    subplot(h3)
    %imagesc(IT)
    imagesc(xx,yy,IT); colormap(gray)
    axis image;
    
    % END calibration
end

