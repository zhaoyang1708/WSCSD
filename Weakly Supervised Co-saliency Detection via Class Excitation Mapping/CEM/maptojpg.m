function [img] = map2jpg(imgmap, range, colorMap)
imgmap = double(imgmap);
if(~exist('range', 'var') || isempty(range)), range = [min(imgmap(:)) max(imgmap(:))]; end

heatmap_gray = mat2gray(imgmap, range);
heatmap_x = gray2ind(heatmap_gray, 256);
heatmap_x(isnan(imgmap)) = 0;
% CAMmapname = ['/home/zy/Downloads/caffe-1/examples/CAMmap' num2str(j) '.jpg'];
% imwrite(heatmap_gray,CAMmapname);
img = heatmap_x;


