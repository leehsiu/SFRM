load('../time_100_100_600_10.mat');
load('../time_100_5_1_20.mat');
load('../time_100_10_15_2_40.mat');
ne = 5:1:20;
nL = 100:100:600;
nP = 15:2:40;
cm = hsv(3);
figure(1);
plot(nL,time1,'LineWidth',1.5,'color',cm(1,:));
ax = gca;
ylabel('Seconds');
xlabel('Number of Frames');
ax.XAxis.FontSize = 24;
ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontSize = 24;
ax.YAxis.FontWeight = 'bold';
grid on;




p = polyfit(ne',time2,1);

figure(2);
plot(ne',polyval(p,ne'),'LineWidth',1.5,'Color',cm(2,:));

ax = gca;
ylabel('Seconds');
xlabel('Number of E-sampling');
ax.XAxis.FontSize = 24;
ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontSize = 24;
ax.YAxis.FontWeight = 'bold';

grid on;

p = polyfit(nP',time3,1);

figure(3);
plot(nP,polyval(p,nP'),'LineWidth',1.5,'color',cm(3,:));
ax = gca;
ylabel('Seconds');
xlabel('Number of Points');
ax.XAxis.FontSize = 24;
ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontSize = 24;
ax.YAxis.FontWeight = 'bold';
grid on;
