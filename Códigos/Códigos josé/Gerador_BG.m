function H = Gerador_BG(BG, set_index, Z)
    %Le o BG básico 
    BG = readtable(BG);
    
    %Base para a matriz final
    H = ones(42, 52)*-1;
    
    [m,n] = size(H);
    
    for l = 1:m%roda todas as linhas de H
    
        %seleciona uma linha do BG
        linha = BG(BG.row_i == l-1, ["col_j" sprintf('set_%d', set_index)]);
    
        contador = 1; %contador conta em qual indice da table está
        for c = 1:n %c conta qual coluna de H está
            if contador <= height(linha) %analiza se já lemos a table inteira
    
                j = linha.col_j(contador);
    
                if j == c-1 %verifica se o valor existe na table
    
                    %atualiza o valor
                    valor = mod(linha.(sprintf('set_%d', set_index))(contador), Z);
                    H(l, c) = valor;
                    contador = contador+1;
                end
            else
                break
            end
        end
    end