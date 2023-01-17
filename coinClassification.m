function [y,z]=coinClassification(net, imdsTest, cells)
    [YTest, scores] = classify(net, imdsTest);
    numImages = numel(imdsTest.Files);
    total = 0;
    for i=1:numImages        
        sc = max(scores(i,:));
        dec = label2decimal(YTest(i), sc, 0.5);
        cells(i, 6) = num2cell(dec);
        total = total + dec;
    end
    y = cells;
    z = total;
end

function res = label2decimal(label, score, t)
    if (score < t)
        res = 0;
    else
        switch (string(label))
            case '0'
                res = 0.01;
            case '1'
                res = 0.02;
            case '2'
                res = 0.05;
            case '3'
                res = 0.1;
            case '4'
                res = 0.2;
            case '5'
                res = 0.5;
            case '6'
                res = 1;
            case '7'
                res = 2;
        end
    end
end