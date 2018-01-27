% This is the main function to write predicted landmark to challenge format
% Group members
	% Vu Hoang Minh
	% Yeman Brhane Hagos
function write_prediction()
%% init
clc; clear all; close all;
addpath('functions');

%% which case you want to write?
for iCase=5:6
disp('=========================================================');
DirLandmarks = 'training-landmarks';
DirPredict = 'predict';
NameFolder = ['copd', num2str(iCase)]
DirDataset = [DirLandmarks, '\', NameFolder, '\'];
DirLandmark = [DirLandmarks, '\', NameFolder, '\', ];
ListingParameter = dir(DirLandmark);
NumFileParameter = size(ListingParameter,1);
% for each prediction, do write
for iParamter=1:NumFileParameter
    NameParameter = ListingParameter(iParamter).name;
    if strcmp(NameParameter , '.') || ...
            strcmp(NameParameter , '..') || ...
            strcmp(NameParameter , 'desktop.ini') || ...
            strcmp(NameParameter , [NameFolder, '_300_iBH_xyz_r1.txt']) || ...
            strcmp(NameParameter , [NameFolder, '_300_eBH_xyz_r1.txt'])
    else
        DirTextInPredict = [DirDataset, NameParameter];
        CoordinateInPredictRound = ...
            load_landmark_predict_elastix(DirTextInPredict,4);
        DirSave = [DirPredict, '\case', int2str(iCase), '.txt'];
        dlmwrite(DirSave, CoordinateInPredictRound, 'delimiter', '\t');
    end
end
end
end