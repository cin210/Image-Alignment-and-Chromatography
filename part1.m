% Chris Neale - cin210
% 
% convert an existing 3-part Prokudin-Gorskii image into a color 

% name of the input file, naively
imname = 'part1_3.jpg';

% name of the output file is just "post_"+ whatever the file was called
filename = ['post_' imname];

% read in the image
fullim = imread(imname);

% convert to double matrix (might want to do this later on to same memory)
fullim = im2double(fullim); 
% compute the height of each part (just 1/3 of total)
height = floor(size(fullim,1)/3);
% separate color channels
B = fullim(1:height,:);
G = fullim(height+1:height*2,:);
R = fullim(height*2+1:height*3,:);

% how to use this program:
% crop a feature out of the first image G (like the corner of a door)
% crop the same feature at the same size for the second image R
% crop a larger area containing the previous features selected from the third
% image B

% the G and R images should be a feature easily distinguishable
% ***make sure the first two crops for G and R are small compared to the
%    crop for blue (which could large enough to contain both features
%    chosen for G and R even if they are different) 
% example: if x is the feature you want, and [     x  ] is a picture, || is where
% you could crop
%   for green: [     |x | ]
%   for red    [    | x|  ]  
%   for blue   [  |   x | ]

[sub_G,template_G] = imcrop(G);
[sub_R,template_R] = imcrop(R); %  sub_G and sub_R should be in the same area
[sub_B,template_B] = imcrop(B); % should contain  sub_G and sub_R   

% calculate the normalized 2D cross correlations 
% C between G and B and D between R and B
C = normxcorr2(sub_G, sub_B); 
D = normxcorr2(sub_R, sub_B);  
% do the following for the green offset and then the red one:

% this is kinda ugly and not too elegant, but it basically does the same
% thing twice in a row for the two images, then concatenates them to the 
% original blue image

% 1. calculate the offset of the images by finding the max correlation for
% C  
[max_c, imax] = max(abs(C(:)));

% 2. see how much the Green image needs to be shifted when at max
% correlation based on the offset minus the dimensions of the cropped version of G
[ypeak, xpeak] = ind2sub(size(C),imax(1));
corr_offset = [(xpeak-size(sub_G,2)),(ypeak-size(sub_G,1))];

% the offset between the coorinates of the cropped image of green and the cropped image of
% blue
rect_offset = [(template_B(1)-template_G(1)),(template_B(2)-template_G(2))];

% total offset is how far you need to shift Green relative to Blue in the X
% and Y directions, including the distance between where you began the crop
% dimensions (aka the rect_offset)
offset = corr_offset + rect_offset;
xoffset = offset(1);
yoffset = offset(2);  
% create a translation for the x and y offset
T = [1 0 0; 0 1 0; xoffset yoffset 1];
tform = maketform('affine', T);
% do a transformation on the original G image based on the dimenstions set
% by T

% green will be the new position of the image G, which should be centered
% on B based on correlation C
green = imtransform(G,tform,'XData',[1 size(G,2)],'YData',[1 size(G,1)]); 
%calculate the offset of the images 
 % offset found by correlation
 
 % do the above again, but for red
[max_d, imax] = max(abs(D(:)));
[ypeak, xpeak] = ind2sub(size(D),imax(1));
corr_offset = [(xpeak-size(sub_R,2)) 
               (ypeak-size(sub_R,1))];  
rect_offset = [(template_B(1)-template_R(1)) 
               (template_B(2)-template_R(2))];  
offset = corr_offset + rect_offset;
xoffset = offset(1);
yoffset = offset(2);  
T = [1 0 0; 0 1 0; xoffset yoffset 1];
tform = maketform('affine', T);
red = imtransform(R,tform,'XData',[1 size(R,2)],'YData',[1 size(R,1)]);

% now you have red and green which are aligned to B
% concatenate all three images to create the colored version
out = cat(3, red, green, B); 
%look at the image!
figure, imshow(out);  
%save the image too
imwrite(out, filename); 

 
 
%% figure(1);

% create a color image (3D array)
% ... use the "cat" command
% show the resulting image
% ... use the "imshow" command
% save result image
%% imwrite(colorim,['result-' imname]);
