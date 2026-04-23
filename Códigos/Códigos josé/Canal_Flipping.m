function y = Canal_Flipping(Probabilidade, c)
%Recebe uma probabilidade e uma codeword
%inverte bits aleatórios de acordo com a probabilidade
    y = c;
    n = length(c);
    for i = 1:n
        if rand <= Probabilidade
            y(i) = ~y(i);
        end
    end