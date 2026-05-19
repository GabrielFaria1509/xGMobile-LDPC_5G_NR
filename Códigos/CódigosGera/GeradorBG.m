function base = GeradorBG(opcao_bg, Zc)
%inputs:
%opcao_bg: qual base graph esolhido (1 ou 2)
%Zc: lifiting size


    %Tabela com os set index de acordo com o Zc
    Tabela = readtable('Tabela_Set.csv');


    set_possiveis = Tabela(Tabela.lifting == Zc, :);
    if isempty(set_possiveis)
        error("Lifting size fora do padrão")
    end
    set_index = set_possiveis{1,2};


    % seleciona o base graph escolhido e cria a matriz do base graph vazia
    % a variavel base é o arquivo csv lido
    if opcao_bg == 1
        base = readtable('BG1.csv');
        BG = ones(46, 68)*-1;
        else
        base = readtable('BG2.csv');
        BG = ones(42, 52) * -1;
    end

    for i = 1:height(base) %roda todas as linhas do csv
        
        %pega as linhas e colunas de acordo com o csv
        l = base{i,1};
        c = base{i,2};
        

        %analiza o valor que está no csv e adiciona no base graph
        valor_bruto = base{i,sprintf('s%d', set_index)};
        valor = mod(valor_bruto, Z);
        BG(l+1,c+1) = valor;
    end