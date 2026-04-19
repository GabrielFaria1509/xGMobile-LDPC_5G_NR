function [expandedGraph] = BaseGraphLifting(BG, Zc)
    [m, n] = size(BG);
    
    %guardo o grafo expandido em células de vetores
    expandedGraph_cell = cell(m, n);
    for i = 1:m
        for j = 1:n
            if BG(i,j) == 0
                expandedGraph_cell{i,j} = speye(Zc);  %valor zero é matriz identidade
            elseif BG(i,j) > 0
                %movimento coluna x posiçào para direita
                %função speye já gera ela esparsa(economia der ram)
                expandedGraph_cell{i,j} = circshift(speye(Zc), [0,BG(i,j)]);
            else
                expandedGraph_cell{i,j} = sparse(Zc,Zc);  %valores negativos matriz nula
                %função sparse já gera ela esparsa e nula(economia der ram)
            end
        end
    end
    
    %converte as várias células para matriz 
    expandedGraph = cell2mat(expandedGraph_cell);
end
