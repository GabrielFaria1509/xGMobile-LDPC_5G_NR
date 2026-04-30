function H = Gerador_BG(BG, Z)
    Tabela = readtable('Tabela_Set.csv')
    
    l = Tabela(Tabela.lifting == Z, :);
    set_index = l{1,2}
    
    %Base para a matriz final
    if BG == 1
        BG = readtable('BG1.csv');
        H = ones(46, 68)*-1;
        else
        BG = readtable('BG2.csv');
        H = ones(42, 52) * -1;
    end
    
    for i = 1:height(BG) %roda todas as linhas de H
        
        l = BG{i,1};
        c = BG{i,2};
        
        valor_bruto = BG{i,sprintf('s%d', set_index)};
        valor = mod(valor_bruto, Z);
        H(l+1,c+1) = valor;
    end