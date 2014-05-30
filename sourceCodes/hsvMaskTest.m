function mask = hsvMaskTest(satImage,terImage,hueLow,hueHigh,smallestAcceptableArea)
% Testing

% Convert RGB image to HSV
hsvImage = rgb2hsv(terImage);
% Extract out the H, S, and V images individually
hImage = hsvImage(:,:,1);
sImage = hsvImage(:,:,2);
vImage = hsvImage(:,:,3);

hueThresholdLow = hueLow;
hueThresholdHigh = hueHigh;
saturationThresholdLow = graythresh(sImage);
saturationThresholdHigh = 1.0;
valueThresholdLow = graythresh(vImage);
valueThresholdHigh = 1.0;

% Now apply each color band's particular thresholds to the color band
hueMask = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the right parts of the image.
mask = uint8(hueMask & saturationMask & valueMask);

% Keep areas only if they're bigger than this.
% Get rid of small objects.  Note: bwareaopen returns a logical.
mask = uint8(bwareaopen(mask, smallestAcceptableArea));

% Smooth the border using a morphological closing operation, imclose().
%structuringElement = strel('disk', 4);
%mask = imclose(mask, structuringElement);

g = mask;
figure;
imshow(g,[]);
% Maximize the figure window.
% set(gcf, 'Position', get(0, 'ScreenSize'));

% Testing
% Fill in any holes in the regions, since they are most likely red also.
% g = uint8(imfill(mask, 'holes'))

satMask = mask;
maskedImageR = satMask .* satImage(:,:,1);
maskedImageG = satMask .* satImage(:,:,2);
maskedImageB = satMask .* satImage(:,:,3);
sateMask = cat(3, maskedImageR, maskedImageG, maskedImageB);
figure;
imshow(sateMask);
% Add grid over the image.
hold on
setGrid(sateMask)
hold off
end

function gridData = setGrid(img)
% SETGRID SET grids over the image.

M = size(img,1);
N = size(img,2);

step = 128;
for k = 1:step:M
    x = [1 N]; 
    y = [k k];
    plot(x,y,'Color','w','LineStyle','-');
    plot(x,y,'Color','k','LineStyle',':');
end
for k = 1:step:N 
    x = [k k]; 
    y = [1 M];
   plot(x,y,'Color','w','LineStyle','-');
    plot(x,y,'Color','k','LineStyle',':');
end

% TODO
% To develop a grid data with 4 data and one zoomlevel
% gridData=zeros(length(xstep)*length(ystep),4);
% for i = 1:length(xstep)-1
%     for j = 1:length(ystep)-1
%         gridData(i*j,:)=[ystep(j) ystep(j+1) xstep(i) xstep(i+1)];
%     end % j
% end % i
end



