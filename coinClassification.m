function dict=coinClassification(net, imdsTest)
    [YTest, scores] = classify(net, imdsTest);
    numImages = numel(imds.Files);
    idx = randperm(numel(imdsTest.Files), numImages);
    for i=1:numImages        
        sc = max(scores(idx(i),:));
        % TODO: Ins Dict
        label2decimal(YTest(idx(i)), sc, 0.5);       
    end
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