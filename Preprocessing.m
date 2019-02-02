function final = Preprocessing(imgPath)
    %lettura immagine  
    imgRGB = im2double(imread(imgPath));

    %riscala immagine
    imgRGB = imresize(imgRGB, [300 300]);
    
    %smoothing gaussiano
    gaussImg = imgaussfilt(imgRGB,5);

    %calcolo edge
    edgeR = edge(gaussImg(:,:,1),'canny');
    edgeG = edge(gaussImg(:,:,2),'canny');
    edgeB = edge(gaussImg(:,:,3),'canny');
    edgeImg = edgeR | edgeG | edgeB ;
    
    %close and fill edges
    dilatedEdges = imdilate(edgeImg, strel('disk',8));
    filledEdges = imfill(dilatedEdges, 'holes');

    %eliminazione bordi spuri
    mask = imopen(filledEdges,strel('disk',20));
    
    final = imgRGB .* mask;
    
end