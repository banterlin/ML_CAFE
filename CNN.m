clear all;clc;close all;
%% Constants

LR = 500e-6;             % Learning Rate
Max_epchos = 50;
batch_size = 256;

%% Import Dataset
Imds = imageDatastore('C:\Users\xq633\Desktop\Msc\Research Project\P-only_wia\CNN_for_pWI', ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames','ReadFcn',@one_cha);

[Train,Val,Test] = splitEachLabel(Imds,0.8,0.1);

%% Data Visulisation 
% https://uk.mathworks.com/help/deeplearning/ug/create-and-explore-datastore-for-image-classification.html
numObsPerClass = countEachLabel(Imds); %% Count each label's length
histogram(Imds.Labels)
set(gca,'TickLabelInterpreter','none')

numObsToShow = 9;
numObs = length(Imds.Labels);
idx = randperm(numObs,numObsToShow);
f10 = figure(10); set(f10,'Color','w');
imshow(imtile(Imds.Files(idx),'GridSize',[3 3],'ThumbnailSize',[100 100]));
title('Example of png input for the CNN');
%% CNN 3 stacks of 2D Conv+MaxPooling Layers
layers = [
    imageInputLayer([180 180 1],"Name","imageinput")
    convolution2dLayer([5 5],32,"Name","conv_1")
    maxPooling2dLayer([2 2],"Name","maxpool_1","Padding","same","Stride",[2 2])
    convolution2dLayer([5 5],32,"Name","conv_2")
    maxPooling2dLayer([2 2],"Name","maxpool_2","Padding","same","Stride",[2 2])
    convolution2dLayer([5 5],32,"Name","conv_3")
    maxPooling2dLayer([2 2],"Name","maxpool_3","Padding","same","Stride",[2 2])
    dropoutLayer(0.5,"Name","dropout")
    fullyConnectedLayer(1000,"Name","fc_1")
    fullyConnectedLayer(2,"Name","fc_2")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput")];

%Layers with ReLu

% layers = [
%     imageInputLayer([90 90 1],"Name","imageinput")
%     convolution2dLayer([5 5],32,"Name","conv_1")
%     batchNormalizationLayer('Name','BN_1')
%     reluLayer("Name","relu_1")
%     maxPooling2dLayer([2 2],"Name","maxpool_1","Padding","same","Stride",[2 2])
%     convolution2dLayer([5 5],32,"Name","conv_2")
%     batchNormalizationLayer('Name','BN_2')
%     reluLayer("Name","relu_2")
%     maxPooling2dLayer([2 2],"Name","maxpool_2","Padding","same","Stride",[2 2])
%     dropoutLayer(0.5,"Name","dropout")
%     fullyConnectedLayer(2000,"Name","fc_1")
%     fullyConnectedLayer(2,"Name","fc_2")
%     softmaxLayer("Name","softmax")
%     classificationLayer("Name","classoutput")];


    opts = trainingOptions("adam",...
    "ExecutionEnvironment","gpu",...
    "InitialLearnRate",LR,...
    "MaxEpochs",Max_epchos,...
    "Shuffle","every-epoch",...
    "ValidationFrequency",5,...
    "Plots","training-progress",...
    'MiniBatchSize',batch_size, ...
    "ValidationData",Val);

%%
[net, traininfo] = trainNetwork(Train,layers,opts);
% save('CNN.mat','net');
% save('CNNinfo.mat','traininfo');
%% Results
YPred = classify(net,Test);
YTest = Test.Labels;

TP = sum((YPred == categorical(1)) & (YTest == categorical(1)));
TN = sum((YPred == categorical(0)) & (YTest == categorical(0)));
FP = sum((YPred == categorical(1)) & (YTest == categorical(0)));
FN = sum((YPred == categorical(0)) & (YTest == categorical(1)));

accuracy = sum(YPred == YTest)/numel(YTest);

precision = TP/(TP+FP);
recall = TP/(TP+FN);
F1 = 2*TP/(2*TP+FP+FN);
% deepNetworkDesigner(layers);
% plot(layerGraph(layers));


%% Results Visulisation

figure; set(gcf,'Color','w');
subplot(1,2,1);plot(smoothdata(traininfo.TrainingLoss));
hold on; p1=plot(traininfo.TrainingLoss); 
p1.Color(4)=0.25;
legend('Smoothed loss','Training Loss');
title('Training Loss');
xlabel('Epochs'); ylabel('Loss');

subplot(1,2,2);plot(smoothdata(traininfo.TrainingAccuracy));
hold on; p2=plot(traininfo.TrainingAccuracy); 
p2.Color(4)=0.25;
legend('Smoothed accuracy','Training Accuracy','Location','southeast');
title('Training Accuracy');
xlabel('iterations'); ylabel('Accuracy');








