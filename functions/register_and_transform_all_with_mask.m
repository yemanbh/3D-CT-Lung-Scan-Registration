function TotalRunningTime = register_and_transform_all_with_mask(Options, ...
    DirVolume, DirMask)
%% init
FolderParent = Options.FolderParent;
NumTest = Options.NumTest;
DirTemp = Options.DirTemp;
DirLandmarks  = Options.DirLandmarks;
DirParameter = Options.DirParamter;
ListingParamter = dir(DirParameter);
NumFileParamter = size(ListingParamter,1);
Listing = dir(DirVolume);
NumFile = size(Listing,1);
NumImage = 0;
DirBatReg = [FolderParent, '\regmask.bat'];
TotalRunningTime = 0;
DirBatTran = [FolderParent, '\trans.bat'];
%% for each case (copd1, copd2, ...) register and transform
for iFile = 1:NumFile
    NameFolder = Listing(iFile).name;
    if strcmp(NameFolder , '.') || ...
            strcmp(NameFolder , '..') || ...
            strcmp(NameFolder , 'desktop.ini')
    else
        NumImage = NumImage + 1;
        if NumImage <= NumTest
            % inhale
            NameImageInhale = [NameFolder, '_iBHCT.nii'];
            DirImageInhale = [DirVolume, '\', ...
                NameFolder, '\', NameImageInhale];
            NameLandmarkInhale = [NameFolder, '_300_iBH_xyz_r1.txt'];
            DirLandmarkInhale = [DirLandmarks, '\', ...
                NameFolder, '\', NameLandmarkInhale];
            NameMaskInhale = [NameFolder, '_iBHCT.nii'];
            DirMaskInhale = [DirMask, '\', ...
                NameFolder, '\', NameMaskInhale];
            % exhale
            NameImageExhale = [NameFolder, '_eBHCT.nii'];
            DirImageExhale = [DirVolume, '\', ...
                NameFolder, '\', NameImageExhale];
            NameLandmarkExhale = [NameFolder, '_300_eBH_xyz_r1.txt'];
            DirLandmarkExhale = [DirLandmarks, '\', ...
                NameFolder, '\', NameLandmarkExhale]; 
            NameMaskExhale = [NameFolder, '_eBHCT.nii'];
            DirMaskExhale = [DirMask, '\', ...
                NameFolder, '\', NameMaskExhale];
            % set fixed and moving volume
            NameImageFixed = NameImageExhale;
            NameImageMoving = NameImageInhale;
            
            % for each parameter file in the 'paramters' folder, register 
            % and transform
            for iParamter=1:NumFileParamter
                NameParameter = ListingParamter(iParamter).name
                if strcmp(NameParameter , '.') || ...
                        strcmp(NameParameter , '..') || ...
                        strcmp(NameParameter , 'desktop.ini')
                else
                    % empty temp folder
                    empty_temp(DirTemp)
                    
                    % copy mask and extracted volume to temp folder
                    DirImageTempInhale = [DirTemp, '\', NameImageInhale];
                    DirImageTempExhale = [DirTemp, '\', NameImageExhale];
                    DirMaskTempInhale = [DirTemp, '\mask_', NameImageInhale];
                    DirMaskTempExhale = [DirTemp, '\mask_', NameImageExhale];
                    copyfile(DirImageInhale, DirImageTempInhale, 'f');
                    copyfile(DirImageExhale, DirImageTempExhale, 'f');
                    copyfile(DirMaskInhale, DirMaskTempInhale, 'f');
                    copyfile(DirMaskExhale, DirMaskTempExhale, 'f');
                    
                    % set fixed and moving masks
                    NameMaskFixed = ['mask_', NameImageExhale];
                    NameMaskMoving = ['mask_', NameImageInhale];
                    
                    % reset regmask.bat and trans.bat
                    copyfile('functions\regmask.bat', 'regmask.bat', 'f');
                    copyfile('functions\trans.bat', 'trans.bat', 'f');

                    % write name to bat
                    write_name_to_bat(DirBatReg, ...
                        NameImageFixed, NameImageMoving, NameParameter, ...
                        NameMaskFixed, NameMaskMoving);
                    
                    % run batch
                    tic;
                    system('regmask.bat');
                    RunningTime = toc;
                    TotalRunningTime = TotalRunningTime + RunningTime;
                    
                    % do transformix
                    file=java.io.File('temp\TransformParameters.0.txt');
                    if file.exists()
                        % landmark
                        DirLandmarkTempInhale = [DirTemp, '\', NameLandmarkInhale];
                        DirLandmarkTempExhale = [DirTemp, '\', NameLandmarkExhale];
                        copyfile(DirLandmarkInhale, DirLandmarkTempInhale, 'f');
                        copyfile(DirLandmarkExhale, DirLandmarkTempExhale, 'f');

                        % do transformix
                        write_landmark_to_bat(DirBatTran, DirTemp, NameLandmarkExhale);
                        system('trans.bat');
                        
                        % copy predicted text file from temp to destination
                        % folder
                        DirLandmarkTempInhalePredict = [DirTemp, '\outputpoints.txt'];
                        DirLandmarkInhalePredict = [DirLandmarks, '\', ...
                            NameFolder, '\', clean_name(NameLandmarkInhale), ...
                            '_', NameParameter];
                        copyfile(DirLandmarkTempInhalePredict, ...
                            DirLandmarkInhalePredict, 'f');
                    end
                end
            end
        end
    end
end
end

%% write name to bat file
function write_name_to_bat(DirBat, ...
    NameImageFixed, NameImageMoving, NameParameter, ...
    NameMaskFixed, NameMaskMoving)
find_and_replace(DirBat, 'ImageFixed', NameImageFixed);
find_and_replace(DirBat, 'ImageMoving', NameImageMoving);
find_and_replace(DirBat, 'NameParameter', NameParameter);
find_and_replace(DirBat, 'FixedMask', NameMaskFixed);
find_and_replace(DirBat, 'MovingMask', NameMaskMoving);
end

%% write exhale landmark text file to bat file
function write_landmark_to_bat(DirBat, DirLabels, NameLabel)
find_and_replace(DirBat, 'DirLabel', DirLabels);
find_and_replace(DirBat, 'NameLabel', NameLabel);
end

%% empty folder
function empty_temp(myFolder)
% Specify the folder where the files live.
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
  baseFileName = theFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now deleting %s\n', fullFileName);
  delete(fullFileName);
end
end