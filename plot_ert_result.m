%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT ERT RESULT
%
% This function plots the resistivity tomogram in 2D, based on the output
% of R2 and your mesh. 
%
% Required input files:
%
% 1) f001_res.dat > the resistivity output file directly from R2
% 2) f001_sen.dat > the sensitivity output file directly from R2
% 3) mesh.dat     > the mesh file used as input to the inversion
% 4) ert_tri.m    > the matlab script that does the plotting
%
% All input files should reside in the same directory as this script.
% Review the "user defined parameters" before running the script. It will
% be neccessary to edit the setYlim, setXlim, setClim, and setSenLim for
% your particular survey.
%
% Script attribution:
% B. Flinchum, M. Kotikian, D. Thayer, A.D. Parsekian, 2015-2018
%
% Current version: Sept 25 2018
% Tested on PC r2017a and mac 2016a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear 
close all

% file names
nameIn      = [pwd '/f001_res.dat']; %input filename
nameOut     = 'NcAs_er01502_lgMsh2.jpg';         % desired name for image output

% user defined parameters
setYlim     = [-20 5];              %set the Y limit of the plot, must start with min
setXlim     = [0 112];                %set the X limit of the plot, must start with min
setClim     = [1.5 3.5];                 %set the log10 resistivty range
setSenLim   = -3;                    %set the sensitivty mask

% plotting
ert_tri(nameIn,setClim,[setXlim setYlim],setSenLim); hold on
xlim(setXlim); ylim(setYlim)
set(gca,'Layer','top')
% text annotations
 plot(49,3,'^')
 plot(63,3,'^')
% text(1.02*setXlim(2), 1.4*setYlim(2),'log_1_0(\rho)')

% plot DOI line

m2 = load([pwd '/doi/14ohmm.dat']);
m1 = load([pwd '/doi/f001_res.dat']);
m2r = log10(14);
m1r = log10(1400);

Ra = abs((m1(:,4) - m2(:,4)));
R= Ra./(1.*(m1r-m2r));

XX=min(m1(:,1)):2:max(m1(:,1));
YY=min(m1(:,2)):2:max(m1(:,2));
D = griddata(m1(:,1),m2(:,2),R,XX,YY');
cval = contour(XX,YY,D,[.5 2],'-k','linewidth',.25);
cval = contour(XX,YY,D,[.9 2],'--k','linewidth',.25);

% save image
set(findall(gcf,'-property','FontSize'),'FontSize',11 ) 
set(findall(gcf,'-property','FontName'),'FontName','Avenir' ) 
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 12 12]) 
outname = nameOut;
%set(gcf,'PaperUnits','inches','PaperPosition',[1 1 8 3])
print(outname,'-djpeg','-r600')
close all
