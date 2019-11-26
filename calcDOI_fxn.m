function calcDOI_fxn(startRes,numel,reg_mode,alpha_s,a_wgt,b_wgt,elecNum,elecSep,nameOut,setYlim,setXlim,setClim,setSenLim)

% Oldenburg & Li
%clear; close all

% % user defined INVERSION parameters
% startRes = 140; % geometric mean of apparent resistivities 
% numel    = 12014; % number of elements, first val from mesh file
% reg_mode = 1;    % regularixation mode, need to use 1 for O&L doi calc
% alpha_s  = 1;    % regularization parameter, use >1 for O&L
% a_wgt    = 0.02; % calcualted from measured data errors
% b_wgt    = 0.04; % calculate from measured data errors
% elecNum  = 112;   % number of electrodes in the survey
% elecSep  = 1;    % electrode separation in meters
% 
% % user defined PLOTTING parameters
% nameOut     = 'ngb_doitest.jpg';         % desired name for image output
% setYlim     = [-15 4];              %set the Y limit of the plot, must start with min
% setXlim     = [0 112];                %set the X limit of the plot, must start with min
% setClim     = [1.5 3.5];                 %set the log10 resistivty range
% setSenLim   = -5;                    %set the sensitivty mask

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
ert_tri('f001_res.dat',setClim,[setXlim setYlim],setSenLim); hold on
xlim(setXlim); ylim(setYlim)
set(gca,'Layer','top')

% plot DOI line
XX=min(m1(:,1)):1:max(m1(:,1));
YY=min(m1(:,2)):1:max(m1(:,2));
D = griddata(m1(:,1),m2(:,2),R,XX,YY');
cval = contour(XX,YY,D,[.4 2],'-k','linewidth',.25);
%cval = contour(XX,YY,D,[.6 2],'--k','linewidth',.25);
cval = contour(XX,YY,D,[.2 2],'--k','linewidth',.25);
ylabel(['elevation [meter]'])
% save image
set(findall(gcf,'-property','FontSize'),'FontSize',11 ) 
set(findall(gcf,'-property','FontName'),'FontName','Lucinda Sans' ) 
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 16 6]) 
outname = nameOut;
print(outname,'-djpeg','-r600')
