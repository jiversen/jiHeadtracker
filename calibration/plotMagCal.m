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
hold on
h2 = jplot3([0 0 0],'ro','markersize',8,'markerfacecolor','r');
title('Raw Magnetometer Data (wave magnetometer around to fill sphere. CTRL-C to exit.')
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
    set(h2,'xdata',mag(1),'ydata',mag(2),'zdata',mag(3))
    axis auto
    axis equal
    drawnow
  end
end

%%
fclose(s)

%%
[U,c] = MgnCalibration(dat)

%% print in format to copy/paste into arduino
% double calibration_matrix[3][3] = 
% {
%   {0.0041884,   -7.2504e-05,   0.00017412},
%   {0,            0.0045851,    -2.885e-05},
%   {0,            0,            0.0037432}  
% };
% 
% double bias[3] = 
% {
%   -17.39,
%   258.8,
%   -307.48
% }; 
Ustr = num2str(U);
cstr = num2str(c);

disp('double calibration_matrix[3][3] = ')
disp('{')
disp(['    {' regexprep(Ustr(1,:),pat,'$1, ') '},'])
disp(['    {' regexprep(Ustr(2,:),pat,'$1, ') '},'])
disp(['    {' regexprep(Ustr(3,:),pat,'$1, ') '}'])
disp('};')
fprintf('\n')
disp('double bias[3] = ')
disp('{')
disp(['   ' cstr(1,:) ','])
disp(['   ' cstr(2,:) ','])
disp(['   ' cstr(3,:)])
disp('};')



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