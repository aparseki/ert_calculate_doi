% Oldenburg & Li
clear; close all

% user defined INVERSION parameters
startRes = 140; % geometric mean of apparent resistivities 
numel    = 6583; % number of elements, first val from mesh file
reg_mode = 1;    % regularixation mode, need to use 1 for O&L doi calc
alpha_s  = 1;    % regularization parameter, use >1 for O&L
a_wgt    = 0.02; % calcualted from measured data errors
b_wgt    = 0.04; % calculate from measured data errors
elecNum  = 58;   % number of electrodes in the survey
elecSep  = 1;    % electrode separation in meters

% user defined PLOTTING parameters
nameOut     = 'bb_doitest.jpg';         % desired name for image output
setYlim     = [-15 4];              %set the Y limit of the plot, must start with min
setXlim     = [0 58];                %set the X limit of the plot, must start with min
setClim     = [1.5 3.5];                 %set the log10 resistivty range
setSenLim   = -5;                    %set the sensitivty mask

%% 

% execute the two inversions with .1x and 10x mean(rhoa)
writeR2in(startRes*0.1, numel, reg_mode, alpha_s,a_wgt, b_wgt, elecNum)
system('R2.exe')
movefile('f001_res.dat','low.dat');

writeR2in(startRes*10, numel, reg_mode, alpha_s,a_wgt, b_wgt, elecNum)
system('R2.exe')
movefile('f001_res.dat','hgh.dat');

%% calcualte equation from Oldenburg and Li

m2 = load([pwd '/low.dat']);
m1 = load([pwd '/hgh.dat']);
m2r = log10(startRes*0.1);
m1r = log10(startRes*10);

Ra = abs((m1(:,4) - m2(:,4)));
R= Ra./((m1r-m2r)); %<--- need to figure out a way to automatically get the normalizatin value

idxR = find(m1(:,2)<min(m1(:,2))+(.2*elecNum*elecSep)); % fix for negative vals
nrmlVal = mean(R(idxR));
R= Ra./((m1r-m2r)./nrmlVal);

scatter(m1(:,1),m1(:,2),20,R,'filled')
ylim(setYlim);            
xlim(setXlim);
colormap jet
caxis([0 1])
ylabel('depth, meter')
xlabel('distance, meter')
colorbar

%% do an inversion using mean(rhoa) and normal regularization

writeR2in(startRes, numel,0, alpha_s,a_wgt, b_wgt, elecNum)
system('R2.exe')

%% plot and save result with DOI isocontour

% plotting
ert_tri('f001_res.dat',setClim,[setXlim setYlim],R); hold on
xlim(setXlim); ylim(setYlim)
set(gca,'Layer','top')

% plot DOI line
XX=min(m1(:,1)):1:max(m1(:,1));
YY=min(m1(:,2)):1:max(m1(:,2));
D = griddata(m1(:,1),m2(:,2),R,XX,YY');
cval = contour(XX,YY,D,[.4 2],'-k','linewidth',.25);
cval = contour(XX,YY,D,[.6 2],'--k','linewidth',.25);
%cval = contour(XX,YY,D,[.8 2],':k','linewidth',.25);
% save image
set(findall(gcf,'-property','FontSize'),'FontSize',11 ) 
set(findall(gcf,'-property','FontName'),'FontName','Lucinda Sans' ) 
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 12 6]) 
outname = nameOut;
print(outname,'-djpeg','-r600')
close all

%% Write the inpiut file function below here. No changes needed.

function writeR2in(startRes, numel, reg_mode, alpha_s,a_wgt, b_wgt, elecNum)
%% Step 13: set R2.in user inputs
% inversion settings
job_type = 1; %0 = forward, 1 = inverse
mesh_type = 3; % 3 = triangular, 4 = quadrilateral, 5 = generalised quad
flux_type = 3.0; % 2.0 = 2D, 3.0 = 3D
singular_type = 0; %singularity removal: 0 = no (only for flat surface), 1 = yes
res_matrix = 1; % 0 = none, 1= sensitivity matrix, 2 = resolution matrix
update = 0; % new for v3.1, how far the model is allowed to update
%startRes = 800; %starting background
scale = 1; %leave at 1
num_regions = 1; %number of regions for starting model
inverse_type = 1; % 0, 1, or 2, mathematical method. 1=default, use for now
% Line 21: data type and regularization mode
data_type = 1; %0 = normal data, 1 = log-transform data
% e.g. provide normal data, R2 log-transforms the data for calculation
%reg_mode = 1; 
%   0 = normal regularization, 
%   1 = regularize relative to starting resistivity (startRes)
%       requires next line: regularization parameter alpha_s
%   2 = time-lapse mode: requires extra column in protocol.dat and 
%       starting model = inverse model of reference dataset
%
% Regularization to the starting model:
%alpha_s = 1; 
%   set alpha_s high (e.g. 10) to highly penalize a departure from the starting model
%   if alpha_s is too high, R2 may not converge
%   printed as "Alpha" in R2.out
%
% don't change these for now:
tol = 1; % RMS tolerance for terminating iterations
maxiter = 10; % maximum number of iterations
errormod = 2; % 2 recommended for updating data weights
alphaaniso = 1; % anisotropy of the smoothing factor
%   alphaaniso > 1 for smoother horizontal models
%   alphaaniso = 1 for isotropic smoothing
%   alphaaniso < 1 for smoother vertical models
%
% Line 23: data weights and resistivity filter bounds
%   error variance model parameters:
%   here, can put real data weights and change both to 0.0
%a_wgt = 0.01; % 
%b_wgt = 0.02; %
%
% res filters for data (set huge cause we filtered already)
rho_min = 0; % set this to Zero
rho_max =  100000;
% Line 24: parameter symbol
% Line 25: Define coordinates of polyline bounding output volume
num_xy_poly = 0; % 0 = no bounding in the x-y plane
%   first and last coordinates must be identical
%   can be either clockwise or anticlockwise
%elecNum = max(max(d(:,2:5)));
elecs = linspace(1,elecNum,elecNum)';
elecs = [elecs elecs]; % electrode, node


%% Step 14: assemble R2.in 
header = sprintf(['Inverse model']);
line2 = sprintf('%1.0f %1.0f %1.1f %1.0f %1.0f',job_type,mesh_type,flux_type,singular_type,res_matrix);
line3 = scale;

%if length(dir('results')) == 2;
line4 = num_regions;
line5 = [1 numel startRes];
%else
%    line4 = 0;
%    line5 = 'brmod.dat';
%end

line18 = [inverse_type update];
line21 = [data_type reg_mode];
if reg_mode == 1
    line22 = [tol maxiter errormod alphaaniso alpha_s]; %use if regmode = 1
else
    line22 = [tol maxiter errormod alphaaniso]; %use if regmode = 0 or 2
end
line9 = [a_wgt b_wgt rho_min rho_max];
line25 = num_xy_poly;
line27 = elecNum;
line28 = elecs;


%% Step 15: write R2.in
%mkdir('r2_files',fname)
newfile = [pwd '\R2.in'];
dlmwrite(newfile,header,'')
dlmwrite(newfile,line2,'-append','delimiter','')
dlmwrite(newfile,line3,'-append','delimiter',' ')
dlmwrite(newfile,line4,'-append','delimiter',' ')

%if length(dir('results')) == 2;
dlmwrite(newfile,line5,'-append','delimiter',' ')
%else
%    dlmwrite(newfile,line5,'-append','delimiter','')
%end

dlmwrite(newfile,line18,'-append','delimiter',' ')
dlmwrite(newfile,line21,'-append','delimiter',' ')
dlmwrite(newfile,line22,'-append','delimiter',' ')
dlmwrite(newfile,line9,'-append','delimiter',' ')
dlmwrite(newfile,line25,'-append','delimiter',' ')
dlmwrite(newfile,line27,'-append','delimiter',' ')
dlmwrite(newfile,line28,'-append','delimiter',' ')
clear newfile;

fprintf('R2.in written\n')
end
