% plot magnetometer data

close all
delete(instrfind)
figure
dat = [0 0 0];
%h=jplot3([0 0 0],'.');
hy = plot(0,0,'r.-');
hold on
hp = plot(0,0,'k.-');
hr = plot(0,0,'b.-');
title('Raw Magnetometer Data')
drawnow

%open serial port
s = serial('/dev/cu.usbmodem809931');
fopen(s);

lines = {};

while(1),
    line = fscanf(s);
    lines{end+1} = line;
    if length(line)<3, continue;end
    if (strcmp(line(1:3),'Yaw')),
        colonidx = findstr(line,':');
        disp(line)
        
        ypr = sscanf(line(colonidx+1:end),'%f');
        dat = [dat; ypr'];
        ndat = size(dat,1);
        set(hy,'xdata',1:ndat,'ydata',dat(:,1));
        set(hp,'xdata',1:ndat,'ydata',dat(:,2));
        set(hr,'xdata',1:ndat,'ydata',dat(:,3));
        axis auto
        drawnow
    end
end

%%
fclose(s)
