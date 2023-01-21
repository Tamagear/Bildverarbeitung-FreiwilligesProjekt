Harris = false;

IOrig = imread("muenzenVerdeckung.jpg");
IGrey = rgb2gray(IOrig);

I1c   = rgb2gray(imread("Münzen\1ct.jpg"));
I2c   = rgb2gray(imread("Münzen\2ct.jpg"));
I5c   = rgb2gray(imread("Münzen\5ct.jpg"));
I10c = rgb2gray(imread("Münzen\10ct.jpg"));
I20c = rgb2gray(imread("Münzen\20ct.jpg"));
I50c = rgb2gray(imread("Münzen\50ct.jpg"));
I1e    = rgb2gray(imread("Münzen\1e.jpg"));
I2e    = rgb2gray(imread("Münzen\2e.jpg"));

if Harris == false
    points   = detectSURFFeatures(IGrey);
    points1c   = detectSURFFeatures(I1c);
    points2c   = detectSURFFeatures(I2c);
    points5c   = detectSURFFeatures(I5c);
    points10c = detectSURFFeatures(I10c);
    points20c = detectSURFFeatures(I20c);
    points50c = detectSURFFeatures(I50c);
    points1e   = detectSURFFeatures(I1e);
    points2e   = detectSURFFeatures(I2e);
else
    points   = detectHarrisFeatures(IGrey);
    points1c   = detectHarrisFeatures(I1c);
    points2c   = detectHarrisFeatures(I2c);
    points5c   = detectHarrisFeatures(I5c);
    points10c = detectHarrisFeatures(I10c);
    points20c = detectHarrisFeatures(I20c);
    points50c = detectHarrisFeatures(I50c);
    points1e   = detectHarrisFeatures(I1e);
    points2e   = detectHarrisFeatures(I2e);
end

[fImg, vptsImg] = extractFeatures(IGrey,   points);
[f1c,  vpts1c]  = extractFeatures(I1c,   points1c);
[f2c,  vpts2c]  = extractFeatures(I2c,   points2c);
[f5c,  vpts5c]  = extractFeatures(I5c,   points5c);
[f10c, vpts10c] = extractFeatures(I10c, points10c);
[f20c, vpts20c] = extractFeatures(I20c, points20c);
[f50c, vpts50c] = extractFeatures(I50c, points50c);
[f1e,  vpts1e]  = extractFeatures(I1e,   points1e);
[f2e,  vpts2e]  = extractFeatures(I2e,   points2e);

points1 = detectSURFFeatures(IGrey);
points2 = detectSURFFeatures(I1e);

[f1, vpts1] = extractFeatures(IGrey, points1);
[f2 , vpts2 ] = extractFeatures(I1e, points2 );

indexPairs = matchFeatures(f1, f2 );
matchedPoints1 = vpts1(indexPairs(:,1));
matchedPoints2 = vpts2(indexPairs(:,2));

figure; showMatchedFeatures(IGrey,I1e,matchedPoints1,matchedPoints2);
legend("matched points 1","matched points 2");