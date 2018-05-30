function [sframe2] = vidsync(sframe1,filename1,filename2,fps)
%Filename's must be inputted as a string, not a {}  <-- Cell
%d can be plotted to determine if sync was not picked up in video
[d1, fs1] = audioread(filename1);
[d2, fs2] = audioread(filename2);

thresh1 = .90*max(d1);
thresh2 = .90*max(d2);

for i=1:length(d1)
    
    if d1(i) > thresh1
        idxvid1 = i;
        break
    end
    
end

for i=1:length(d2)
    
    if d2(i) > thresh2
        idxvid2 = i;
        break
    end
    
end

%Finding sync frames in both videos.
syncframe1 = (fps/fs2)*idxvid1;
syncframe2 = (fps/fs2)*idxvid2;

%Determining start frame/index for vid2. Sectioning
%fp data for the frame chosen.
viddiff = round(syncframe1 - syncframe2);
sframe2 = sframe1 - viddiff;

end