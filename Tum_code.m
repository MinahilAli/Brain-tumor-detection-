clc
close all
%% Input
[I,path]=uigetfile('*.jpg','select an input image');
str=strcat(path,I);
s=imread(str);
 
figure;
imshow(s);
title('Choosed Image','FontSize',10);%%Title Choosed Image
%%Filter
num_iter=10;
  delta_t=1/7;
  kappa=15;
  option=2;
  disp('Preprocessing image please wait...');
  inp=anisotropic_code(s,num_iter,delta_t,kappa,option);
  inp=uint8(inp);
inp=imresize(inp,[256,256]);
if size(inp,3)>1
    inp=rgb2gray(inp);
end
figure;
imshow(inp);
title('Filtered Image','FontSize',10);
%%Thresholding
sout=imresize(inp,[256,256]);
t0=60;
threshold=t0+((max(inp(:))+min(inp(:)))./2);
for p=1:1:size(inp,1)
    for q=1:1:size(inp,2)
        if inp(p,q)>threshold
            sout(p,q)=1;
        else
                sout(p,q)=0;
        end
    end
end 
 
%%Morphological Operation
label=bwlabel(sout);
stats=regionprops(logical(sout),'Solidity','Area','BoundingBox');
density=[stats.Solidity];
area=[stats.Area];
h_d_a=density>0.6;
max_area=max(area(h_d_a));
tumor_label=find(area==max_area);
tumor=ismember(label,tumor_label);
 
if max_area>100
    figure;
    imshow(tumor)
    title('Tumor Alone','FontSize',10);
else
    h=msgbox('No Tumor !!','stats');
return;
end
 
%%Bounding Box
box=stats(tumor_label);
wantedBox=box.BoundingBox;
figure
imshow(inp);
title('Bounding Box','FontSize',10);
hold on;
rectangle('Position',wantedBox,'EdgeColor','r');
hold off;
%%Performing Erossion
dilationAmount=5;
rad= floor(dilationAmount);
[r,c]=size(tumor);
filledImage= imfill(tumor,'holes');
 
for p=1:r
    for q=1:c
        a1=p-rad;
        a2=p+rad;
        b1=q-rad;
        b2=q+rad;
        if a1<1
            a1=1;
        end
            if a2>r
                a2=r;
            end
            if b1<1
                b1=1;
            end
            if b2>c
                b2=c;
            end
            erodedImage(p,q) = min(min(filledImage(a1:a2,b1:b2)));
    end
end
figure
imshow(erodedImage);
title('Eroded Image','FontSize',10);
