clearvars;

imds = imageDatastore('images','IncludeSubfolders',true,'LabelSource','foldernames');
imgs = imds.Files;

for i = 1:numel(imgs)
    out = provaPreprocessing(imgs{i});
    imwrite(out,strrep(imgs{i}, "images", "contrasted"));
end
    