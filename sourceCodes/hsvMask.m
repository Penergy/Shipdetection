function [mask sateMask] = hsvMask(hueLow,hueHigh,smallestAcceptableArea)
% HSVMASK MASKS the requried color object.
% Varargin CONTAINS [satImage,terImage]. SatImage is a satellite image.
% terImage is a terrain image.
%
% Blue domain test:
% [pixelCounts values] = hist(hImage,500)
% figure:
% bar(values, pixelCounts);
% set(gcf, 'units','normalized','outerposition',[0 0 1 1])
%


curAxis = axis
zoomLevel = getZoomLevel(curAxis)

lon = sum(curAxis(1:2))/2
lat = sum(curAxis(3:4))/2
satParams = struct('latitude',lat,'longitude',lon,'zoom',zoomLevel,'maptype','satellite');
terParams = struct('latitude',lat,'longitude',lon,'zoom',zoomLevel,'maptype','terrain');
satImage = mapsapi(satParams,'tmp1.png');
terImage = mapsapi(terParams,'tmp2.png');

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
end



	



