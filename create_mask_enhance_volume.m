% This is the main function to extract mask and write mask + extracted 
% volume to the destination folder training-volumes and training-masks
% Group members
	% Vu Hoang Minh
	% Yeman Brhane Hagos
function create_mask_enhance_volume()
% init
clc; clear all; close all;
FolderParent = pwd;
addpath(genpath(FolderParent));
DirImages = 'dataset\';
Listing = dir(DirImages);
NumFile = size(Listing,1);
NumImage = 0;

% for all folder in the dataset (copd1, copd2 ...), extract mask and write
% mask + extracted volume to destination folder
for iFile = 1:NumFile
    NameFolder = Listing(iFile).name;
    if strcmp(NameFolder , '.') || ...
            strcmp(NameFolder , '..') || ...
            strcmp(NameFolder , 'desktop.ini')
    else
        NumImage = NumImage + 1;
        % inhale
        NameImageInhale = [NameFolder, '_iBHCT.nii.gz'];
        DirVolumeInhale = [DirImages, NameFolder, '\', ...
            NameImageInhale];
        create_and_write_mask(DirVolumeInhale, NameImageInhale, NameFolder);
        % exhale
        NameImageExhale = [NameFolder, '_eBHCT.nii.gz'];
        DirVolumeExhale = [DirImages, NameFolder, '\', ...
            NameImageExhale];
        create_and_write_mask(DirVolumeExhale, NameImageExhale, NameFolder);
    end
end
end


%% find and write mask
function create_and_write_mask(DirVolume, NameImage, NameFolder)
% load data
DataVolume = load_untouch_nii(DirVolume);
Volume = DataVolume.img;

% enhance foreground to find mask
[VolumeNormalized, ~] = enhance_foreground(Volume);
VolumeForeGround = zeros(size(VolumeNormalized));
NumSlice = size(VolumeForeGround,3);
CellMask = struct;

%% find mask slice by slice and stack them up in the end
for iSlice = 1:NumSlice   
    iSlice    
    Mask = extract_foreground(VolumeNormalized, iSlice);
    CellMask(iSlice).mask = Mask; 
    CellMask(iSlice).count = length(find(Mask)); 
end

%% refine mask
IsCopy = true;
while IsCopy
    for iSlice = 1:NumSlice-1   
        iSlice   
        IsCopy = false;
        CountPrev = CellMask(iSlice).count;
        CountNext = CellMask(iSlice+1).count;
        if CountPrev<CountNext && ...
                abs(CountPrev-CountNext)/max(CountPrev,CountNext)>0.2
            CellMask(iSlice).mask = CellMask(iSlice+1).mask;
            CellMask(iSlice).count = CellMask(iSlice+1).count;
            IsCopy = true;
        elseif CountPrev>CountNext && ...
                abs(CountPrev-CountNext)/max(CountPrev,CountNext)>0.2
            CellMask(iSlice+1).mask = CellMask(iSlice).mask;
            CellMask(iSlice+1).count = CellMask(iSlice).count;
            IsCopy = true;
        end        
    end
end

%% enhance the volume ONLY in the mask 
VolumeMask = zeros(size(Volume));
% for each slice, extract ONLY the voxels lying inside the mask and
% enhance on them. Here, we dont enhance on the whole volume (with
% background) because it will worsen the performance
for iSlice = 1:NumSlice   
    iSlice    
    Mask = CellMask(iSlice).mask;
    VolumeMask(:,:,iSlice) = Mask;
    IndexForeGround = find(Mask);
    Image = Volume(:,:,iSlice);
    ImageForeGround = zeros(size(Image));
    ImageForeGround(IndexForeGround) = Image(IndexForeGround);
    VolumeForeGround(:,:,iSlice) = ImageForeGround;
end

show_image_test(VolumeForeGround,-90);

% find gradient of the whole volume
[Gmag,~,~] = imgradient3(Volume);

% extract voxels from gradient volume which lie inside the mask
IndexMask = find(VolumeForeGround);
VolumeTemp = Gmag(IndexMask);
VolumeTemp = normalize_image(VolumeTemp);
VolumeForeGround(IndexMask) = VolumeTemp;
VolumeForeGround = round(65535*normalize_image(VolumeForeGround));

% show the test slice from the volume
show_image_test(VolumeForeGround,-90);
show_image_test(VolumeMask,-90);

% write mask and corresponding volume to 
CleanedName = clean_name(NameImage);
DirMake = ['training-volumes\', NameFolder, '\'];
DirMakeMask = ['training-masks\', NameFolder, '\'];
mkdir (DirMake);
mkdir (DirMakeMask);
DirSave = [DirMake, CleanedName];
DirSaveMask = [DirMakeMask, CleanedName];
niftiwrite(VolumeForeGround, DirSave);
niftiwrite(VolumeMask, DirSaveMask);
end


%% enhance foreground
function [ImageNormalized, ImageNoBackground] = ...
    enhance_foreground(Image3D)
% remove background
ImageNoBackground = Image3D;
ImageNoBackground(ImageNoBackground>0) = 0;
ImageNoBackground = -ImageNoBackground+min(min(min(ImageNoBackground)));
ImageNoBackground = ImageNoBackground+abs(min(min(min(ImageNoBackground))));
ImageNoBackground = double(ImageNoBackground)/1e4;
k = find(ImageNoBackground);
Itemp = ImageNoBackground(k);
Itemp = normalize_image(Itemp);
ImageNormalized = zeros(size(ImageNoBackground));
ImageNormalized(k) = Itemp;
end


%% find mask from one slice
function Mask = extract_foreground(ImageNormalized, SliceNumber)
I = ImageNormalized(:,:,SliceNumber);
Itemp = reshape(I, [], 1);

% cluster to 3 regions
[Label, Center] =  kmeans(Itemp,3);

% return right label
[RightOrder, WrongOrder] = return_right_order(Center, Label, Itemp);
Label = correct_label(Label, RightOrder, WrongOrder);

% take the label = 2, which is the middle one (here we have 3 labels) and
% set the rest to background
Mask = reshape(Label,size(I));
Mask(Mask==1) = 0;
Mask(Mask==3) = 0;

% normalize mask to 0-1
Mask = normalize_image(Mask);

% clean these line made by table lying below the back
se = strel('disk',5);
Mask = imopen(Mask,se);
Mask1 = Mask;

% fill holes
Mask = imfill(Mask,'holes');

% find the true mask
Mask2 = Mask-Mask1;
Mask = Mask2;
end


%% return the right labeling of k-means 
% the brightest cluster get the largest value (3), the second brightest is
% set to 2, and the darkest is set to 1
function [RightOrder, WrongOrder] = return_right_order(C, Label, Itemp)
WrongOrder = [];
RightOrder = [];
MeanArray = zeros(length(C),1);
for i=1:length(C)
    RightOrder = [RightOrder,i];
    MeanArray(i) = mean(mean(Itemp(Label==i)));
end
B = sort(MeanArray);
for i=1:length(C)
    Index = find(MeanArray==B(i));
    WrongOrder = [WrongOrder, Index];
end
end


%% correct label
function RightLabel = correct_label(Label, RightOrder, WrongOrder)
RightLabel = zeros(size(Label));
for i=1:length(RightOrder)
    RightLabel(Label == WrongOrder(i)) = RightOrder(i);
end
end