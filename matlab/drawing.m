r1 = load('ratio1.mat');
r2 = load('ratio2.mat');
r3 = load('ratio3.mat');
r4 = load('ratio4.mat');
nkps = 44;

xe = 0:0.2:2;
xe = xe(1:10);

recErr = (r1.recErr+r2.recErr+r3.recErr+r4.recErr)/4;
validNum = (r1.validNum+r2.validNum+r3.validNum+r4.validNum)/4;
yyaxis right;
xlabel('Pixel uncertainty');

gp1 = polyfit(xe',validNum./300,6);
gp2 = polyfit(xe,mean(recErr')/nkps,6);


plot(xe,polyval(gp2,xe),'-o','LineWidth',3);
ylabel('Reconstruction Error');

hold on;
yyaxis left;




plot(xe,polyval(gp1,xe),'-^','LineWidth',3);
ylabel('Reconstruction Ratio');
grid on;
lgd = legend('Reconstruction Ratio','Reconstruction Error');
lgd.FontSize = 12;
lgd.FontWeight = 'bold';
ax = gca;
ax.XAxis.FontSize = 12;
ax.XAxis.FontWeight = 'bold';
ax.YAxis(1).FontSize = 12;
ax.YAxis(1).FontWeight = 'bold';
ax.YAxis(2).FontSize = 12;
ax.YAxis(2).FontWeight = 'bold';
