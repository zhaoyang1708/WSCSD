clc
clear
addpath(genpath('./'));
dirpath = '../CEM_apple_banana_res/CEM_plus/';
outpath = '../CEM_apple_banana_res/apple_banana_plus_CEM_DRFI_Smooth_tanh/';
origin_path = '../CEM_apple_banana_res/apple_banana/';
drfi_path = '../CEM_apple_banana_res/drfi/';
mkdir(outpath);
fileList= dir(dirpath);
n=length(fileList);
for listnum = 1:n
    if strcmp(fileList(listnum).name,'.')==1||strcmp(fileList(listnum).name,'..')==1
        continue;
    else
        imgDir = [ dirpath fileList(listnum).name '/'];
        outDir = [ outpath fileList(listnum).name '/'];
        orgDir = [origin_path fileList(listnum).name '/'];
        drfiDir = [drfi_path fileList(listnum).name '/'];
        mkdir(outDir);
        imgList = dir(imgDir);
        orgList = dir(orgDir);
        drfiList = dir(drfiDir);
        img_totalnum = length(drfiList);
        for img_num = 1:img_totalnum
            if strcmp(drfiList(img_num).name,'.')==1||strcmp(drfiList(img_num).name,'..')==1
                continue;
            else
                %imgname = [imgDir 'CEM_' drfiList(img_num).name];
                imgname = [imgDir drfiList(img_num).name];
                img_len = length(imgname);
                imgname(img_len-3:img_len) = []
                imgname = [imgname '.jpg']
                drfiList(img_num).name
                orgname = [orgDir drfiList(img_num).name];
                outname = [outDir drfiList(img_num).name];
                drfiname = [drfiDir drfiList(img_num).name];
                tdm = imread(imgname);                
                tdm = im2double(tdm);
                
%                 threadshould = 2 * std(tdm(:),0) + 2 *mean(tdm(:));
%                 tdm(tdm<threadshould) = 0;
%                 tdm = tancosal  = tanh(3*cosal);
                
                org = imread(orgname);
                org = im2double(org);
                if length(size(org))<3
                    org_img = zeros([size(org) 3]);
                    org_img(:,:,1) = org;
                    org_img(:,:,2) = org;
                    org_img(:,:,3) = org;
                    org = zeros([size(org_img)]);
                    org = org_img;
                end
%                 tdm = Get_SaliencyMap(org,tdm);
%                 tdm = im2double(tdm);
%                 tdm = normalize_1(tdm,0);
                
                drfi_img = imread(drfiname);
                drfi_img = im2double(drfi_img);
                tdm = tdm .* drfi_img;
                tdm = normalize_1(tdm,0);
                
                tdm = Get_SaliencyMap(org,tdm);
                tdm = im2double(tdm);
                tdm = normalize_1(tdm,0);
                
                %res_sal = histeq(res_sal);
                res_sal = tanh(tdm);
                res_sal = normalize_1(res_sal,0);
                end_len = length(outname);
                outname(end_len-3:end_len) = []
                imwrite(res_sal,[outname '.png']);
                
%                 end_len = length(outname);
%                 outname(end_len-3:end_len) = []
%                 imwrite(X1, map1, [outname '.png']);
%                 nonzeros = sum(sum(res_sal>0.1));
%                 sumLabel = sum(sum(res_sal)) / nonzeros;
                %sumLabel =  mean(res_sal(:));
%                 if ( sumLabel > 1 )
%                     sumLabel = 1;
%                 end
%                 Label3 = zeros(size(res_sal));
%                 Label3(Label3==0)=0;
%                 Label3( res_sal>=sumLabel ) = 255;
%-------------ten label--------begin
%                 Label3( res_sal>=0.02 ) = 7;
%                 Label3( res_sal>=0.04 ) = 14;
%                 Label3( res_sal>=0.06 ) = 21;
%                 Label3( res_sal>=0.08 ) = 28;
%                 Label3( res_sal>=0.1 ) = 35;
%                 Label3( res_sal>=0.12 ) = 41;
%                 Label3( res_sal>=0.14 ) = 47;
%                 Label3( res_sal>=0.16 ) = 53;
%                 Label3( res_sal>=0.18 ) = 59;
%                 Label3( res_sal>=0.2 ) = 65;
%                 Label3( res_sal>=0.3 ) = 95;
%                 Label3( res_sal>=0.4 ) = 135;
%                 Label3( res_sal>=0.5 ) = 155;
%                 Label3( res_sal>=0.6 ) = 185;
%                 Label3( res_sal>=0.7 ) = 215;
%                 Label3( res_sal>=0.8 ) = 235;
%                 Label3( res_sal>=0.9 ) = 255;
%====================================
%                 Label3( res_sal>=0.05 ) = 5;
%                 Label3( res_sal>=0.1 ) = 15;
%                 Label3( res_sal>=0.15 ) = 25;
%                 Label3( res_sal>=0.2 ) = 45;
%                 Label3( res_sal>=0.25 ) = 65;
%                 Label3( res_sal>=0.3 ) = 90;
%                 Label3( res_sal>=0.4 ) = 125;
%                 Label3( res_sal>=0.5 ) = 155;
%                 Label3( res_sal>=0.6 ) = 185;
%                 Label3( res_sal>=0.7 ) = 215;
%                 Label3( res_sal>=0.8 ) = 235;
%                 Label3( res_sal>=0.9 ) = 255;
%-------------ten label--------end

%-------------20 labels--------begin
%                 Label3( res_sal>=0.05 ) = 12.75;
%                 Label3( res_sal>=0.1 ) = 12.75*2;
%                 Label3( res_sal>=0.15 ) = 12.75*3;
%                 Label3( res_sal>=0.2 ) = 12.75*4;
%                 Label3( res_sal>=0.25 ) = 12.75*5;
%                 Label3( res_sal>=0.3 ) = 12.75*6;
%                 Label3( res_sal>=0.35 ) = 12.75*7;
%                 Label3( res_sal>=0.4 ) = 12.75*8;
%                 Label3( res_sal>=0.45 ) = 12.75*9;
%                 Label3( res_sal>=0.5 ) = 12.75*10;
%                 Label3( res_sal>=0.55 ) = 12.75*11;
%                 Label3( res_sal>=0.6 ) = 12.75*12;
%                 Label3( res_sal>=0.65 ) = 12.75*13;
%                 Label3( res_sal>=0.7 ) = 12.75*14;
%                 Label3( res_sal>=0.75 ) = 12.75*15;
%                 Label3( res_sal>=0.8 ) = 12.75*16;
%                 Label3( res_sal>=0.85 ) = 12.75*17;
%                 Label3( res_sal>=0.9 ) = 12.75*18;
%                 Label3( res_sal>=0.95 ) = 12.75*19;
%-------------20 labels--------begin
%                 res = zeros(size(org));
%                 
%                 res(:,:,1) = Label3;
%                 res(:,:,2) = 255;
%                 res(:,:,3) = 0;
%                 res = uint8(res);
% 
%                 [X1,map1]=rgb2ind(res,18);
%                 end_len = length(outname);
%                 outname(end_len-3:end_len) = []
%                 imwrite(X1, map1, [outname '.png']);
            end
        end
    end
end