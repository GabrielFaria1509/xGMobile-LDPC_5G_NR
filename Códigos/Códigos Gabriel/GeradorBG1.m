function BG1 = GeradorBG1(nome_arquivo,iLS,Zc)

    % DICIONÁRIO DE VARIÁVEIS (LEGENDA):
    % =========================================================================
    % ENTRADAS DA FUNÇÃO:
    %   nome_arquivo : (String) O nome do arquivo CSV gerado (ex: 'BG1.csv').
    %   iLS          : (Inteiro) Índice do Lifting Set (0 a 7). Definido pela 
    %                  norma 3GPP de acordo com o tamanho do bloco (Zc).
    %   Zc           : (Inteiro) Lifting size. O tamanho da matriz identidade 
    %                  que será expandida depois.
    %
    % VARIÁVEIS INTERNAS:
    %   dados          : (Matriz) Guarda todo o conteúdo bruto lido do CSV.
    %   num_linhas_csv : (Inteiro) Total de conexões válidas extraídas (aprox. 316).
    %   B              : (Matriz 46x68) O "quadro em branco" do Base Graph 1. 
    %                    Inicia com -1 (indicando matriz nula/vazia).
    %   coluna_shift   : (Inteiro) Descobre qual coluna do CSV tem os dados certos.
    %   k              : (Inteiro) Contador do laço (anda linha por linha no CSV).
    %   l              : (Inteiro) Índice da LINHA na matriz do MATLAB.
    %   c              : (Inteiro) Índice da COLUNA na matriz do MATLAB.
    %   shift_bruto    : (Inteiro) O valor original retirado direto da tabela 3GPP.
    %   shift_calculado: (Inteiro) O valor final após a operação de módulo.

    %leitura tabela(Como dados já organziados,tabela vira uma matriz)\
    %passo nome do arquivo que a pessoa deu pro download da tabela de
    %referência(csv)
    dados = readmatrix(nome_arquivo);
    num_linhas_csv = size(dados,1);

    % 2. CRIAÇÃO DA MATRIZ BASE (BG1)
    % A norma define que o Base Graph 1 tem exatamente 46 linhas e 68 colunas

    BG1 = ones(46,68)*-1;

    % No nosso CSV, as colunas 1 e 2 são as coordenadas.
    % Os valores de shift (sets de 0 a 7) começam na coluna 3.

    coluna_shift = 3 + iLS;

    % 4. MAPEAMENTO DOS DADOS (VARRER O CSV)

    for k = 1:num_linhas_csv

        %Extrair coordeandas
        %soma mais 1 pois MATLAB começa no 1

        l = dados(k,1) + 1;
        c = dados(k,2) + 1;

        %Pego valor na coluna do específica do Set index escolhido

        deslocamento_bruto = dados(k,coluna_shift);

        %Aplicação norma/padrão 3GPPP

        deslocamento_calculado = mod(deslocamento_bruto,Zc);

        % Salva o valor final na posição exata da matriz B
        %Essa será a matriz de base para o lifting 
        BG1(l,c) = deslocamento_calculado;

    end
end






    







    
