close all;

%%inizializzo un pool di risorse per il calcolo parallelo
%pool = parpool;

%%Inizializzo un data store e creo la partizione di test
imds = imageDatastore('contrasted','IncludeSubfolders',true,'LabelSource','foldernames');
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.7,'randomized');

%Inizializzo alexnet
net = alexnet;

%%Ridimensiono le immagini in modo che siano compatibili con l'input di
%%densenet e faccio una dataset augmentation
inputSize = net.Layers(1).InputSize;
imageAugmenter = imageDataAugmenter('RandRotation',[-20,20], ...
                                    'RandXTranslation',[-3 3], ...
                                    'RandYTranslation',[-3 3], ...
                                    'RandScale', [1 3], ...
                                    'RandXReflection', true, ...
                                    'RandYReflection', true, ...
                                    'RandXShear', [-3 3], ...
                                    'RandYShear', [-3 3]);
                                
augimds = augmentedImageDatastore(inputSize(1:2),imdsTrain,'DataAugmentation',imageAugmenter);
augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);

%%Faccio il fitting di alexnet rimuovendo gli ultimi 3 layer e portando da
%%1000 a 13 le classi da riconocere
layersTransfer = net.Layers(1:end-4);
numClasses = numel(categories(imdsTrain.Labels));

layers = [
    layersTransfer
    dropoutLayer(0.6);
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',15,'BiasLearnRateFactor',10)
    softmaxLayer
    classificationLayer];

%Imposto le varie opzioni di training

options = trainingOptions('sgdm', ...
    'MaxEpochs',10, ...
    'MiniBatchSize',32, ...
    'InitialLearnRate',1e-4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',3, ...
    'Verbose',false, ...
    'Plots','training-progress');

%Faccio il training della rete
netTransfer = trainNetwork(augimds,layers,options);

%Elimino il pool di risorse
%delete(gcp('nocreate'));