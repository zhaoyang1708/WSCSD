clc
clear
addpath(genpath('.'));

addpath('/home/vr715/caffe_zy/matlab');
caffe.set_mode_cpu();
imgDataPath = '/home/vr715/caffe_zy/CAM-master/icoseg18/';
imgDataDir  = dir(imgDataPath);             % 遍历所有文件
for i = 1:length(imgDataDir)
    if(isequal(imgDataDir(i).name,'.')||... % 去除系统自带的两个隐文件夹
       isequal(imgDataDir(i).name,'..')||...
       ~imgDataDir(i).isdir)                % 去除遍历中不是文件夹的
           continue;
    end
    subdir = ['./CEM_18_icoseg/' imgDataDir(i).name];
    mkdir(subdir);
end

% for i = 1:length(imgDataDir)
%     if(isequal(imgDataDir(i).name,'.')||... % 去除系统自带的两个隐文件夹
%        isequal(imgDataDir(i).name,'..')||...
%        ~imgDataDir(i).isdir)                % 去除遍历中不是文件夹的
%            continue;
%     end
%     subdir = ['./res5/' imgDataDir(i).name];
%     mkdir(subdir);
% end

fid = fopen('/home/vr715/caffe_zy/CAM-master/icoseg_resnet/labels.txt','r');
labelscell = textscan(fid,'%s');
fclose(fid);
categories = labelscell{1,1};
        
net_weights = ['/home/vr715/caffe_zy/CAM-master/icoseg_resnet/icosegResCoSal512_18_snap_iter_100000.caffemodel'];
net_model = ['/home/vr715/caffe_zy/CAM-master/icoseg_resnet/icosegResCoSal_deploy512.prototxt'];
net = caffe.Net(net_model, net_weights, 'test');
weights_LR1 = net.params('conv18',1).get_data();% get the softmax layer of the network
%     weights_LR[1:2048,1:50] = 0;
weights_LR = reshape(weights_LR1,2048,18); 

class = 1;
for k = 1:length(imgDataDir)
    if(isequal(imgDataDir(k).name,'.')||... % 去除系统自带的两个隐文件夹
       isequal(imgDataDir(k).name,'..')||...
       ~imgDataDir(k).isdir)             
           continue;
    end
    class
    imgDir = dir([imgDataPath imgDataDir(k).name '/*.jpg']); 
    for im_dir =1:length(imgDir)                 % 遍历所有图片
        img = imread([imgDataPath imgDataDir(k).name '/' imgDir(im_dir).name]);
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
        scores = net.forward({prepare_image(image)});% extract conv features online

        % get Data from  res5c
        res5 = zeros([imgsize(1) imgsize(2)]);
        blob_names={'res5a','res5b','res5c'};
        prob_diff = zeros(net.blobs('conv18').shape);
        prob_diff(:,:,class,:) = 1;
        net.blobs('conv18').set_diff(prob_diff);
        net.backward_prefilled();
        for layer=1:length(blob_names)
            difflayer_name = blob_names{layer};
            res5_data = net.blobs(difflayer_name).get_data();
            data_diff = net.blobs(difflayer_name).get_diff();
            res5_shape = net.blobs(difflayer_name).shape;
            crop_num = res5_shape(4);
            blob_num = res5_shape(3);
            diff_sum = zeros(crop_num,blob_num);
%             data_diff(data_diff<0) = 0; %abandon
            for i=1:crop_num
                for j=1:blob_num
                    diff_sum(i,j) = sum(sum(data_diff(:,:,j,i)));
                    if diff_sum(i,j) < 0
                        diff_sum(i,j) = 0; %ours
                    end
                end
            end
            diffMap_crops = zeros([res5_shape(1) res5_shape(2) res5_shape(4)]);
            for i=1:crop_num
                diff_min = min(diff_sum(i,:));
                diff_max = max(diff_sum(i,:));
                diff_sum(i,:) = (diff_sum(i,:) - diff_min)/(diff_max - diff_min);
                for j=1:blob_num
                    diffMap_crops(:,:,i) = diffMap_crops(:,:,i) + res5_data(:,:,j,i) * diff_sum(i,j);
                end
            end
            diffMapLarge_crops = imresize(diffMap_crops,[512 512]);
            diffMap_image = mergeTenCrop(diffMapLarge_crops);
            diffHeapMap = maptojpg(diffMap_image, [], 'jet');
            diffHeapMap = imresize(diffHeapMap, [imgsize(1) imgsize(2)]);
            diffHeapMap = im2double(diffHeapMap);
%             heapname = ['./res5/' imgDataDir(k).name '/' difflayer_name '_'  imgDir(im_dir).name];
%             imwrite(diffHeapMap, heapname);
            res5 = (res5 + diffHeapMap) / 2;

        end
        TDMname = ['./CEM_18_icoseg/' imgDataDir(k).name '/CEM_' imgDir(im_dir).name];
        res5 = (res5 - min(min(res5)))/(max(max(res5))-min(min(res5)));
        disp([TDMname])
        imwrite(res5,TDMname);
    end
    class = class + 1;
end