function [Zc,Kb] = Zc_selector(B, BG_number)
    %Tabela com os set index de acordo com o Zc
    table = readtable('set.csv');

    if BG_number == 1
        Kb = 22;
    elseif BG_number==2
        if B > 640
            Kb = 10;
        elseif B > 560
            Kb = 9;
        elseif B > 192
            Kb = 8;
        else
            Kb = 6;
        end
    end
    
    possible_Zc = table(table.lifting*Kb >= B,:);
    Zc = min(possible_Zc);
    Zc = Zc{1,1};