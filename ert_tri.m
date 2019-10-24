function  ert_tri(nameIn,CMinMax,XYMinMax,SenLev)

%rho_truelog: vector of values to plot
RhoIn=importipresult(nameIn);
rho_truelog = RhoIn(:,4);

%temperature correction
%alphaT = 0.025; %emperically derived coeficient [Keller and Frischknecht, 1966]
%for i =1:length(RhoIn)
%    t_C = -0.0182*(-RhoIn(i,2))^2+3.5169*(-RhoIn(i,2))+12.19; % calculate temp at inverted depth, site-specific equation needed
%    rho_truelog(i,1) = log10(RhoIn(i,3)*(1+alphaT*(t_C-18))); %correct temp to rho@18C [Keller and Frischknecht, 1966]
%end

%CMinMax: [color axis min; color axis max] in space you want to use log/lin
cmin = CMinMax(1); %Color axis minimum in ohm-m (code converts this to a log10 value)
cmax = CMinMax(2); %Color axis maximum in ohm-m (code converts this to a log10 value)
xmin = XYMinMax(1); %Minimum x-location
xmax = XYMinMax(2); %Maximum x-location
ymin = XYMinMax(3); %Minimum z-location
ymax = XYMinMax(4); %Maximum z-location

%mesh = load('mesh.mat'); %new mesh
%sens = load('newmesh_sen.mat'); %already comes up as variable A
LLmesh = importmesh('mesh.dat');
S = importipresult('f001_sen.dat');
A = S(:,4);
%clear mesh sens

mshl = LLmesh(1,1);
elementArray = LLmesh(2:mshl+1,1:6) ;
nodalArray = LLmesh(mshl+2:end,1:3) ;

%cmap = parula(64); %cmap = flipud(cmap);
cmap = jet(64);
colorVal = linspace((cmin),(cmax),64);

h = figure;
cnt = 1;
for i = 1:size(elementArray)
    line1 = elementArray(i,2);
    line2 = elementArray(i,3);
    line3 = elementArray(i,4);
    
    [index1,value1] = find(nodalArray(:,1)==line1); %index1 = x value of 1st vertex
    [index2,value2] = find(nodalArray(:,1)==line2);
    [index3,value3] = find(nodalArray(:,1)==line3);
    [valueC,indexC] = min(((colorVal-rho_truelog(i,1)).^2));
    
    plotX = [nodalArray(index1,2),nodalArray(index2,2),nodalArray(index3,2),nodalArray(index1,2)];
    plotY = [nodalArray(index1,3),nodalArray(index2,3),nodalArray(index3,3),nodalArray(index1,3)];
    plotC = cmap(indexC,:);
    
    if A(i,1) < SenLev %
        patch(plotX,plotY,[1 1 1],'edgecolor', 'none')%mask sensitive
    else
        patch(plotX,plotY,plotC,'edgecolor','none');
        export(cnt,:) = [S(i,1:2) rho_truelog(i,1)];
        cnt = cnt+1;
    end
end

axis([xmin xmax ymin ymax])

hold on


%% add a countour line
% XX=min(export(:,1)):.3:max(export(:,1));
% YY=min(export(:,2)):.3:max(export(:,2));
% D = griddata(export(:,1),export(:,2),export(:,3),XX,YY');
% cval = contour(XX,YY,real(D),[1 2 3],'-w','linewidth',.25);


%% finish
xlabel('distance [m]')
ylabel('depth [m]')
caxis ([cmin cmax])
%colormap parula
colormap jet
colorbar('eastoutside');
grid off
%axis equal
set(findall(gcf,'-property','FontName'),'FontName','Avenir' ) 
%save('result.txt','export','-ASCII')


%import R2 output nested function
    function f001 = importipresult(filename, startRow, endRow)
        delimiter = ' ';
        if nargin<=2
            startRow = 1;
            endRow = inf;
        end
        formatSpec = '%f%f%f%f%f%f%f%[^\n\r]';
        fileID = fopen(filename,'r');
        dataArray = textscan(fileID, '%f%f%f%f%f%f%f%[^\n\r]', endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'EmptyValue', 999.0, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
        for block=2:length(startRow)
            frewind(fileID);
            dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', 999.0, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
            for col=1:length(dataArray)
                dataArray{col} = [dataArray{col};dataArrayBlock{col}];
            end
        end
        fclose(fileID);
        f001 = [dataArray{1:end-1}];
    end

%import mesh nested function
    function mesh1 = importmesh(filename, startRow, endRow)
        delimiter = ' ';
        if nargin<=2
            startRow = 1;
            endRow = inf;
        end
        formatSpec = '%f%f%f%f%f%f%[^\n\r]';
        fileID = fopen(filename,'r');
        textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
        dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'EmptyValue', NaN, 'ReturnOnError', false, 'EndOfLine', '\r\n');
        for block=2:length(startRow)
            frewind(fileID);
            textscan(fileID, '%[^\n\r]', startRow(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
            dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', NaN, 'ReturnOnError', false, 'EndOfLine', '\r\n');
            for col=1:length(dataArray)
                dataArray{col} = [dataArray{col};dataArrayBlock{col}];
            end
        end
        fclose(fileID);
        mesh1 = [dataArray{1:end-1}];
    end

end
