function y = Canal_Erasure(Probabilidade, c)
%Recebe uma probabilidade e uma codeword
%apaga bits aleatórios de acordo com a probabilidade
    y = c;
    n = length(c);
    for i = 1:n
        if rand <= Probabilidade
            y(i) = -1;
        end
    end