% fill small holes
function Inew = fill_small_holes(I,P)
original = I;
filled = imfill(original, 'holes');
holes = filled & ~original;
bigholes = bwareaopen(holes, P);
smallholes = holes & ~bigholes;
Inew = original | smallholes;
end

