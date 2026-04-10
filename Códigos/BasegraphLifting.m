%%Código para construir expansão de base graph


%Base Graph
B = [0 2 -1 1;1 -1 2 0];

%Fator de expansão para lifting
Zc = 3;

%Fator de deslocamento
s = 5;

% Expand the base graph using the expansion factor
%%Se elemento é 0 substitui por matriz identidade sem deslocar coluna

%%Se elemento é 1 substitui por matriz identidade deslocado 1 para direita
%%para as colunas

%%Se elemento é 2 substitui por matriz identidade deslocado 2 para direita
%%para as colunas

%%Se elemento é diferente de 1 ou 2 e positivo substitui por matriz identidade deslocado s para direita
%%para as colunas

%%Se elemento é negativo substitui por matriz de 0

[m,n] = size(B);

%%guardo cada matriz 3x3 em uma célula

expandedGraph_cell = cell(m,n);
%%vira uma matriz de m x n com várias células

 for i = 1:m
     for j = 1:n
         if B(i,j) == 0
             %vejo a posição da célula na matriz para poder colcoar uma
             %submarriz
             expandedGraph_cell{i,j} = eye(Zc);
         elseif B(i,j) == 1
             %vejo a posição da célula na matriz para poder colcoar uma
             %submarriz,crio a identidade de dimensão Zc x Zc e desloco 0
             %linhas e 1 coluna para direita 
                expandedGraph_cell{i,j} = circshift(eye(Zc),[0,1]);
         elseif B(i,j) == 2
             expandedGraph_cell{i,j} = circshift(eye(Zc),[0,2]);
         elseif B(i,j) >2
             expandedGraph_cell{i,j} = circshift(eye(Zc),[0,s]);
         else
             expandedGraph_cell{i,j} = zeros(Zc);
         end
     end
 end


expandedGraph = cell2mat(expandedGraph_cell);

disp(expandedGraph);