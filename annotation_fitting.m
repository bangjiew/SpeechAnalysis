%% Data Analysis
lowLang1_count = 1;
highLang1_count =1;
lowLang2_count = 1;
highLang2_count = 1;
for i = 1:size(transformedSequences,1)-1 
    if (transformedSequences.text(i) == 1) || (transformedSequences.text(i) == 4)
        % low rhythm texts
        if transformedSequences.language(i) == 1
            % English
            %if transformedSequences.seqNum(i) < transformedSequences.seqNum(i+1)
                lowLang1(lowLang1_count) =  transformedSequences.vowelInterval(i);
                %lowLang1(lowLang1_count) =  transformedSequences.vowelNum(i);
                lowLang1_count = lowLang1_count + 1;
            %end
        elseif transformedSequences.language(i) == 2
            % Mandarin
           % if transformedSequences.seqNum(i) < transformedSequences.seqNum(i+1)
                lowLang2(lowLang2_count) =  transformedSequences.vowelInterval(i);
                lowLang2_count = lowLang2_count + 1;
            %end
        end
    elseif (transformedSequences.text(i) == 5) ||(transformedSequences.text(i) == 6)
        % high rhythm texts
        if transformedSequences.language(i) == 1
            % English
           % if transformedSequences.seqNum(i) < transformedSequences.seqNum(i+1)
                highLang1(highLang1_count) =  transformedSequences.vowelInterval(i);
                highLang1_count = highLang1_count + 1;
          %  end
        elseif transformedSequences.language(i) == 2
            % Mandarin
            %if transformedSequences.seqNum(i) > transformedSequences.seqNum(i+1)
                highLang2(highLang2_count) =  transformedSequences.vowelInterval(i);
                highLang2_count = highLang2_count + 1;
           % end
        end
    end
    disp(i);
end
highLang1 = highLang1';
highLang2 = highLang2';
lowLang2 = lowLang2';
lowLang1 = lowLang1';

%% Breathing Analysis
tableBreathing = [highLang1(1:160),highLang2(1:160);lowLang1(1:160),lowLang2(1:160)]';
% take only 1-16th value of highLang1
%        Lang1 Lang2
% high   
% low
[~,~,statsBreathing] = anova2(tableBreathing,160);
% statsBreathing shows that sig. for language, high/low, and interaction

[~,pBreathingLang1,~,statsBreathingLang1] = ttest(highLang1(1:160),lowLang1);
% sig. for high/low in lang1
[~,pBreathingLang2,~,statsBreathingLang2] = ttest(highLang2,lowLang2(1:253));
% sig. for high/low in lang2

%% Data Extraction
clear all
load('SampleData.mat')

lang = transformedSequences.language;
speaker = transformedSequences.speaker;
txt = transformedSequences.text;
readspon = transformedSequences.readSpont;
vowel_intervel = transformedSequences.vowelsIntervals;
seqNum = transformedSequences.seqNum;
stressed_interval = transformedSequences.stressedVowelsIntervals;
joint_solo = transformedSequences.jointSolo;
% Get all non-spontanous or count trials
count = 1;
for i = 1:size(txt,1)
    %   (joint_solo(i) == 2)&&
    if  (lang(i) == 2)&& (txt(i) ~= 7)  && (readspon(i) == 1)&&...
             mean(~isnan(vowel_intervel{i})) &&...
            (size(vowel_intervel{i},2) > 0)
        seqData{count,1} = vowel_intervel{i};
        seqData{count,2} = stressed_interval{i};
        seqData{count,3} = length(stressed_interval{i})/length(vowel_intervel{i});
        seqIndices(count) = seqNum(i);
        seqLang(count) = lang(i);
        seqJointSolo(count) = joint_solo(i);
        seqTxt(count) = txt(i);
        seqReadSpon(count) = readspon(i);
        count = count + 1;
    end
end

% Get XTrain and YTrain
count = 1;
temp_count = 1;
for i = 1:length(seqData)
    XTrain{i} = seqData{i,1};
    if (seqTxt(i) == 1) || (seqTxt(i) == 4)
        YTrain{i} = 'low';
    else
        YTrain{i} = 'high';
    end
end
XTrain = XTrain';
YTrain = categorical(YTrain)';

% 90% Training, 10% Testing data
trainCount = 1;
testCount =1;
for i = 1:size(XTrain,1)
    if floor(i/9) == i/9
        X_Test{testCount} = XTrain{i};
        Y_Test(testCount) = YTrain(i);
        testCount = testCount + 1;
    else
        X_Train{trainCount} = XTrain{i};
        Y_Train(trainCount) = YTrain(i);
        trainCount = trainCount + 1;
    end
end
X_Train = X_Train';
X_Test = X_Test';
Y_Train = Y_Train';
Y_Test = Y_Test';

% sort
numOb = numel(X_Train);
for i = 1:numOb
    seq = X_Train{i};
    seqLen(i) = size(seq,2);
end
[seqLen,idx] = sort(seqLen);
X_Train = X_Train(idx);
Y_Train = Y_Train(idx);

clear idx seqLen;
numOb1 = numel(X_Test);
for i = 1:numOb1
    seq = X_Test{i};
    seqLen(i) = size(seq,2);
end
[seqLen,idx] = sort(seqLen);
X_Test = X_Test(idx);
Y_Test = Y_Test(idx);
clearvars -except X_Train X_Test Y_Train Y_Test

% Training
numFeatures = 1;
numHiddenUnits = 200;
numClasses = 2;
miniBatchSize = length(X_Train{end});

layers = [...
    sequenceInputLayer(numFeatures)
    bilstmLayer(numHiddenUnits, 'OutputMode', 'last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    'MaxEpochs', 100, ...
    'GradientThreshold',1, ...
    'SequenceLength', 'longest', ...
    'Shuffle', 'never', ...
    'Verbose', 0, ...
    'MiniBatchSize', miniBatchSize, ...
    'ExecutionEnvironment', 'gpu', ...
    'Plots', 'training-progress');

net = trainNetwork(X_Train,Y_Train,layers,options);

% Evalution
YPred = classify(net, X_Test, ...
    'MiniBatchSize', miniBatchSize, ...
    'SequenceLength', 'Longest');
acc = sum(YPred == Y_Test)./numel(Y_Test);
