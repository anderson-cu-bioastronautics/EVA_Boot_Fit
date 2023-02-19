function processIMUs(s)
configs = struct2cell(load('Subject3/Subject3.mat'));
name = IMUTrial(configs{s});
save('Subject3/S3US.mat', name(0))
end
