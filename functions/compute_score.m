function Score = compute_score(In, Out, PixelSize)
TotalDiff = 0;
In = In .* PixelSize;
Out = Out .* PixelSize;
   
for i=1:300
    Diff = In(i,:) - Out(i,:);
    Error = sqrt(Diff*Diff');
    TotalDiff = TotalDiff + Error;
end
Score = TotalDiff/300;
end