% load original landmarks (with point and 300 at the top for transformix)
function Coordinates = load_landmark_original(FileName)
FileID = fopen(FileName,'r');
% remove first 2 lines
fgets(FileID);
fgets(FileID);
Coordinates = zeros(300,3);
for i=1:300
    Line = fgets(FileID);
    Number = str2num(Line);
    Coordinates(i,1) = Number(1);
    Coordinates(i,2) = Number(2);
    Coordinates(i,3) = Number(3);
end
fclose('all');
end

