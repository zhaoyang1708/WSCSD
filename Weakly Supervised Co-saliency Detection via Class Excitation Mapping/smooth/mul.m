clc
im1 = imread('/home/afan/python_code/crf/dss_crf/DRFI/aeroplane/aeroplane_006.jpg');
im2 = imread('/home/afan/python_code/crf/dss_crf/TDM_Smooth_1/aeroplane/aeroplane_006.jpg');
img1 = im2double(im1);
img2 = im2double(im2);
img = img1.*img2;
img = normalize_1(img,0);
figure
imshow(img);