% show slice test image
function show_slice_test(slice,Degree,varargin)
Label2D = double(slice);
Label2D = imrotate(Label2D,Degree);
figure; imshow(Label2D,[]);
if size(varargin) > 0
    title(varargin{1});
end
end

