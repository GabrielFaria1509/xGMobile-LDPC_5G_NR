function Zc = Zc_selector(B, Kb)
    %Tabela com os set index de acordo com o Zc
    table = readtable('set.csv');

     possible_Zc = table(table.lifting*Kb >= B,:);
     Zc = min(possible_Zc);
     Zc = Zc{1,1};