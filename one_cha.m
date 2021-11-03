function data = one_cha(filename)
data=imread(filename);
% data = data(:,:,1);
data=imresize(data(:,:,1),[180,180]);
end
