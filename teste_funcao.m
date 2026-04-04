H = [ 1 0 1 0 0 ; 1 1 0 0 0];

tg = tanner_graph(H);

plot(tg);
title('Tanner Graph Representation');
xlabel('Variable Nodes');
ylabel('Check Nodes');



