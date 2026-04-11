function [expandedGraph] = BaseGraphLifting(B, Zc, s)
    [m, n] = size(B);
    
    %guardo o grafo expandido em células de vetores
    expandedGraph_cell = cell(m, n);
    for i = 1:m
        for j = 1:n
            if B(i,j) == 0
                expandedGraph_cell{i,j} = eye(Zc);  %valor zero é matriz identidade
            elseif B(i,j) == 1
                %movimento coluna x posiçào para direita
                expandedGraph_cell{i,j} = circshift(eye(Zc), [0, 1]);
            elseif B(i,j) == 2
                expandedGraph_cell{i,j} = circshift(eye(Zc), [0, 2]);
            elseif B(i,j) > 2
                expandedGraph_cell{i,j} = circshift(eye(Zc), [0, s]);
            else
                expandedGraph_cell{i,j} = zeros(Zc);  %valores negativos matriz nula
            end
        end
    end
    
    %converte as várias células para matriz 
    expandedGraph = cell2mat(expandedGraph_cell);
end
