%% Reciprocal Comparison

for Q = 1
    inst = dlmread('protocol.dat','\t', 1, 1);
    %inst(:,5) = 10.^inst(:,5);
    
    for i = 1:length(inst)
        tx = sort(inst(i,1:2));
        rx = sort(inst(i,3:4));
        
        for j = 1:length(inst)
            Tx = sort(inst(j,1:2));
            Rx = sort(inst(j,3:4));
            
            if rx == Tx & tx == Rx
                reciprocal(i,:) = [tx rx Tx Rx inst(i,5) inst(j,5)];
                
            end
        end
    end
    
    for i = 1:length(reciprocal)
        holder = reciprocal(i,:);
        reciprocal(i,:) = [0 0 0 0 0 0 0 0 0 0];
        for j = 1:length(reciprocal)
            if reciprocal(j,1:8) == [holder(5:8) holder(1:4)]
                reciprocal(j,:) = [0 0 0 0 0 0 0 0 0 0];
            end
        end
        reciprocal(i,:) = holder;
    end
    reciprocal = reciprocal(find(reciprocal(:,1)),:);
    reciprocal = [reciprocal(:,1:4) reciprocal(:,9:10)];
    reciprocal(:,7) = abs(reciprocal(:,5) - reciprocal(:,6));  %adds column 7 whihch is the abs.diff between FWD/RECIP
    
    
    
    for i = 1:length(reciprocal)
        if max(reciprocal(i,1:2))>max(reciprocal(i,3:4))
            reciprocal(i,1:4) = [sort(reciprocal(i,3:4),2) sort(reciprocal(i,1:2),2)];
        else
            reciprocal(i,1:4) = [sort(reciprocal(i,1:2),2) sort(reciprocal(i,3:4),2)];
        end
        %reciprocal(i,sz(2)+1) = mean([mean(data(i,1:2)) mean(data(i,3:4))]);
        %data(i,sz(2)+2) = abs((max(data(i,1:2))-min(data(i,3:4))))+abs(data(i,1)-data(i,2));
    end
    
    for R = 1:length(reciprocal)
    Xr(R) = mean([mean(reciprocal(R,1:2)) mean(reciprocal(R,3:4))]);
    Zr(R) = abs((max(reciprocal(R,1:2))-min(reciprocal(R,3:4))))+abs(reciprocal(R,1)-reciprocal(R,2));
    end
    
RECIPS = [reciprocal Xr' Zr'];

end
%%
subplot(2,2,1)
scatter(RECIPS(:,8),RECIPS(:,9),20,RECIPS(:,7),'filled'); set(gca,'ydir','reverse')
subplot(2,2,2)
plot(RECIPS(:,5),RECIPS(:,6),'ok')
subplot(2,2,3)
plot(log10(RECIPS(:,5)),log10(RECIPS(:,7)),'ok'); hold on
B = polyfit(log10(RECIPS(:,5)),log10(RECIPS(:,7)),1);
x_s = -.5:.5:3;
plot(x_s,B(1).*x_s+B(2),'--r')
