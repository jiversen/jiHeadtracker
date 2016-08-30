% collect, plot and calibrate magnetometer data
% expects lines in the form m:xxx xxx xxx, where xxx are raw x,y,z
% magnetometer values (integer)
%   circle magnetometer all around trying to fill in complete sphere on
%   plot--needs a lot more than a few figure eights
%
%   calibration is computed using Merayo technique with a non iterative algoritm
% J.Merayo et al. "Scalar calibration of vector magnemoters"
% Meas. Sci. Technol. 11 (2000) 120-132.
% implemented by Alain Barraud, Suzanne Lesecq 2008
%
%   it fits best 3D ellipsoid to data
 
% JRI 12/13/15

close all
delete(instrfind)
figure
h=jplot3([0 0 0],'.');
title('Raw Magnetometer Data')
drawnow

%open serial port
s = serial('/dev/cu.usbmodem809931');
fopen(s);

lines = {};

dat = [];


while(1),
  line = fscanf(s);
  lines{end+1} = line;
  if (line(1)=='m' && line(2)==':'),
    mag = sscanf(line(3:end),'%d');
    dat = [dat; mag'];
    set(h,'xdata',dat(:,1),'ydata',dat(:,2),'zdata',dat(:,3))
    axis auto
    drawnow
  end
end

%%
fclose(s)

%%
[U,c] = MgnCalibration(dat)

%%
[ctr,rad]=fitsphere(dat);

[X,Y,Z] = sphere(20);
X = X*rad + ctr(1);
Y = Y*rad + ctr(2);
Z = Z*rad + ctr(3);
hold on
mesh(X,Y,Z,'facecolor','none')

%%
cc = cov(dat)
[u,s,v] = svd(cc)

corrcoef(dat)

%% original method simply finds mean and span based on min/max
% this is not terribly robust to outliers, so sort and trim
% largest/smallest 1%?
%   This has a large effect on centering and scale.
sdat = sort(dat);
sdat(1:40,:) = [];
sdat(end-39:end,:) = [];

ctr = mean([min(sdat); max(sdat)])
scale = (max(sdat)-mean(sdat))/2

% trimmed
% ctr =
%           -16        256.5       -296.5
% scale =
%        119.38        113.3       127.27
% 
% untrimmed (original method)
% ctr =
%          40.5        257.5         -299
% scale =
%        182.77       121.69       132.35