function drawCam(P,wi,lyp)
Oc = [0 0 0];
Xc = [1 0 0];
Yc = [0 1 0];
Zc = [0 0 1];

Op = P(1:3,1:3)*Oc'+P(1:3,4);
Xp = P(1:3,1:3)*Xc'+P(1:3,4);
Yp = P(1:3,1:3)*Yc'+P(1:3,4);
Zp = P(1:3,1:3)*Zc'+P(1:3,4);

hold on;
plot3(Op(1),Op(2),Op(3),'ro');
plot3([Op(1) Xp(1)],[Op(2) Xp(2)],[Op(3) Xp(3)],'r-','LineWidth',wi,'LineStyle',lyp);
plot3([Op(1) Yp(1)],[Op(2) Yp(2)],[Op(3) Yp(3)],'g-','LineWidth',wi,'LineStyle',lyp);
plot3([Op(1) Zp(1)],[Op(2) Zp(2)],[Op(3) Zp(3)],'b-','LineWidth',wi,'LineStyle',lyp);
end