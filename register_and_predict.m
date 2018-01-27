% This is the main function to register exhale to inhale and transform
% exhale landmarks to predict inhale landmarks
% Group members
	% Vu Hoang Minh
	% Yeman Brhane Hagos
function register_and_predict()
% init
clc; clear all; close all;
FolderParent = pwd;
addpath('functions');
Options.FolderParent        = FolderParent;
Options.NumTest             = 100;
Options.DirParamter         = 'parameters';
Options.DirMask             = 'training-masks';
Options.DirVolume           = 'training-volumes';
Options.DirLandmarks        = 'training-landmarks';
Options.DirTemp             = 'temp';
% register and transform all cases with mask
register_and_transform_all_with_mask(Options, Options.DirVolume, ...
    Options.DirMask);
end


