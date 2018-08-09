clc
clear
addpath(genpath('.'));
addpath('/home/vr715/caffe_zy/matlab');
caffe.set_mode_cpu();
imgDataPath = '/home/vr715/caffe_zy/data/cosal2015/';

fid = fopen('/home/vr715/caffe_zy/data/labels.txt','r');
labelscell = textscan(fid,'%s');
fclose(fid);
categories = labelscell{1,1};

net_weights = ['../models/resnet/ResCoSal512snap_iter_380000.caffemodel'];
net_model = ['../models/resnet/ResCoSal_deploy512_copy.prototxt'];
net = caffe.Net(net_model, net_weights, 'test');

img = imread('../data/cosal2015/baseball/baseball_009.jpg');
class = 6
imgsize = size(img);
if numel(imgsize)<3
    image = zeros(size(img,1),size(img,2),3);
    image(:,:,1) = img;
    image(:,:,2) = img;
    image(:,:,3) = img;
else
    image = img;
end
image = imresize(image, [512 512]);
scores = net.forward({prepare_image(image)});
% get Data from  res5c
res5 = zeros([imgsize(1) imgsize(2)]);
blob_names={'res5a','res5b','res5c'};
prob_diff = zeros(net.blobs('conv50').shape);
prob_diff(:,:,class,:) = 1;
net.blobs('conv50').set_diff(prob_diff);
net.backward_prefilled();
for layer=1:length(blob_names)
    difflayer_name = blob_names{layer};
    res5_data = net.blobs(difflayer_name).get_data();
    data_diff = net.blobs(difflayer_name).get_diff();
    res5_shape = net.blobs(difflayer_name).shape;
    crop_num = res5_shape(4);
    blob_num = res5_shape(3);
    diff_sum = zeros(crop_num,blob_num);
%             data_diff(data_diff<0) = 0;
    for i=1:crop_num
        for j=1:blob_num
            diff_sum(i,j) = sum(sum(data_diff(:,:,j,i)));
            if diff_sum(i,j) < 0
                diff_sum(i,j) = 0;
            end
        end
    end
    diffMap_crops = zeros([res5_shape(1) res5_shape(2) res5_shape(4)]);
    for i=1:crop_num 
        for j=1:blob_num
            diffMap_crops(:,:,i) = diffMap_crops(:,:,i) + res5_data(:,:,j,i) * diff_sum(i,j);
        end
    end
    diffMapLarge_crops = imresize(diffMap_crops,[512 512]);
    diffMap_image = mergeTenCrop(diffMapLarge_crops);
    diffHeapMap = maptojpg(diffMap_image, [], 'jet');
    diffHeapMap = imresize(diffHeapMap, [imgsize(1) imgsize(2)]);
    diffHeapMap = im2double(diffHeapMap);
    res5 = (res5 + diffHeapMap) / 2;
end
imshow(res5)