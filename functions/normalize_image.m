% normalize image 0-1
function NormalizedI = normalize_image(I)
NormalizedI = double(I);
if size(I,3)>1
    MinValue = min(min(min(NormalizedI)));
    MaxValue = max(max(max(NormalizedI)));
elseif size(I,3)==1
    MinValue = min(min(NormalizedI));
    MaxValue = max(max(NormalizedI));
elseif size(I,2)==1
    MinValue = min(NormalizedI);
    MaxValue = max(NormalizedI);
end 
NormalizedI = (NormalizedI-MinValue)/(MaxValue-MinValue);
end