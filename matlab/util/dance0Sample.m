images = dir('~/databag/SFRM/girl_dancing/image_0/*.jpg');

for i=1:2:length(images)
    copyfile(fullfile(images(i).folder,images(i).name),fullfile('~/databag/SFRM/dance0/image_0',images(i).name));
end
