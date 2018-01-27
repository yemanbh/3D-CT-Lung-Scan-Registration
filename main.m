% This is the main function 
% Group members
	% Vu Hoang Minh
	% Yeman Brhane Hagos
clc; clear all; close all;


% extract mask and enhance volume
create_mask_enhance_volume();

% register exhale to inhale and transform the landmark
register_and_predict();

% compute score of each parameter prediction
get_scores();

% write prediction to challenge format
write_prediction();
