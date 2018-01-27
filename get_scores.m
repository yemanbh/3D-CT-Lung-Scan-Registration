% This is the main function to compute scores
% Group members
	% Vu Hoang Minh
	% Yeman Brhane Hagos
function Record = get_scores()

%% init
clc; clear all; close all;
addpath('functions');
TablePixelSize = [  0.625  0.625  2.5;...
                    0.645  0.645  2.5;...
                    0.652  0.652  2.5;...
                    0.590  0.590  2.5
                    ];

%% compute score
Record = struct;
% for each case
for iCase=1:4
    disp('=========================================================');
    DirLandmarks = 'training-landmarks';
    NameFolder = ['copd', num2str(iCase)]
    DirDataset = [DirLandmarks, '\', NameFolder, '\'];
    DirTextIn  = [DirDataset, NameFolder, '_300_iBH_xyz_r1.txt'];
    DirTextEx  = [DirDataset, NameFolder, '_300_eBH_xyz_r1.txt'];
    
    % load landmark
    CoordinateIn = load_landmark_original(DirTextIn);
    CoordinateEx = load_landmark_original(DirTextEx);
    
    % compute unregistered score
    PixelSize = TablePixelSize(iCase,:);
    ScoreDefault = compute_score(CoordinateIn, CoordinateEx, PixelSize)
    Record(1).Name = 'no_registered';
    Record(1).Case(iCase) = ScoreDefault;
    Record(1).MeanScore = ...
        mean(Record(1).Case);

    % init folder for each parameter
    DirLandmark = [DirLandmarks, '\', NameFolder, '\', ];
    ListingParameter = dir(DirLandmark);
    NumFileParameter = size(ListingParameter,1);
    NumFileParameterComapare = 1;
    
    % for each prediction
    for iParamter=1:NumFileParameter
        NameParameter = ListingParameter(iParamter).name;
        if strcmp(NameParameter , '.') || ...
                strcmp(NameParameter , '..') || ...
                strcmp(NameParameter , 'desktop.ini') || ...
                strcmp(NameParameter , [NameFolder, '_300_iBH_xyz_r1.txt']) || ...
                strcmp(NameParameter , [NameFolder, '_300_eBH_xyz_r1.txt'])
        else
            
        % compute score
        NameParameter
        NumFileParameterComapare = NumFileParameterComapare + 1;
        Record(NumFileParameterComapare).Name = NameParameter;
        DirTextInPredict = [DirDataset, NameParameter];
        
        % load predicted coordinates and compute score
        CoordinateInPredict = ...
            load_landmark_predict_elastix(DirTextInPredict,5);
        Score = compute_score(CoordinateIn, CoordinateInPredict, PixelSize)

        % load predicted integer coordinates and compute score
        CoordinateInPredictRound = ...
            load_landmark_predict_elastix(DirTextInPredict,4);
        ScoreRound = compute_score(CoordinateIn, CoordinateInPredictRound, PixelSize);

        % save to record 
        Record(NumFileParameterComapare).Case(iCase) = Score;
        Record(NumFileParameterComapare).CaseRound(iCase) = ScoreRound;
        Record(NumFileParameterComapare).MeanScore = ...
            mean(Record(NumFileParameterComapare).Case);
        Record(NumFileParameterComapare).MeanScoreRound = ...
            mean(Record(NumFileParameterComapare).CaseRound);  
        end
    end
end
end