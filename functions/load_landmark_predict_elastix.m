% load predicted landmarks
function Coordinates = load_landmark_predict_elastix(FileName, NumType)
FileID = fopen(FileName,'r');
Coordinates = zeros(300,3);
for i=1:300
    Line = fgets(FileID);
    Line = strsplit(Line,';');
    Text = Line{NumType};
    InText = strsplit(Text,' ');
    NumValue = 0;
    for j=1:length(InText)
        Info = InText{j};
        if ~isempty(Info)
            Num = str2num(Info);
            if ~isempty(Num)
                NumValue = NumValue + 1;
                Coordinates(i,NumValue) = Num;
            end
        end
    end
end
fclose('all');
end