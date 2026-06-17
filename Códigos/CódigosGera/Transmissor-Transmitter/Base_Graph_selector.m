function [BG_number, Kb] = Base_Graph_selector(A, R)
    %Recebe o valor B (Numero de bits da mensagem útil + CRC)
    %Recebe R (Valor do code rate esperado)
    %Devolve o número do BaseGraph

    if A <= 292
        BG_number = 2;
    elseif A <= 3824 && R <= 0.67  % 0.67 é a aproximação de 2/3
        BG_number = 2;
    elseif R <= 0.25
        BG_number = 2;
    else
        BG_number = 1;
        Kb = 22;
    end

    

    
    