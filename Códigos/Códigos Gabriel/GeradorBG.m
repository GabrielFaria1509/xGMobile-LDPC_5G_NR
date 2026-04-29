function BG = GeradorBG(nome_arquivo, iLS, Zc, opcao_bg)
    % DICIONÁRIO DE VARIÁVEIS (LEGENDA):
    % =========================================================================
    % ENTRADAS DA FUNÇÃO:
    %   nome_arquivo : (String) O nome do arquivo CSV gerado (ex: 'BG1.csv').
    %   iLS          : (Inteiro) Índice do Lifting Set (0 a 7). Definido pela 
    %                  norma 3GPP de acordo com o tamanho do bloco (Zc).
    %   Zc           : (Inteiro) Lifting size. O tamanho da matriz identidade 
    %                  que será expandida depois.
    %   opcao_bg     : (Inteiro) 1 para Base Graph 1, ou 2 para Base Graph 2.
    %
    % VARIÁVEIS INTERNAS:
    %   dados          : (Matriz) Guarda todo o conteúdo bruto lido do CSV.
    %   num_linhas_csv : (Inteiro) Total de conexões válidas extraídas.
    %   BG             : (Matriz) O "quadro em branco" do Base Graph escolhido. 
    %                    Inicia com -1 (indicando matriz nula/vazia).
    %   coluna_shift   : (Inteiro) Descobre qual coluna do CSV tem os dados certos.
    %   k              : (Inteiro) Contador do laço (anda linha por linha no CSV).
    %   l              : (Inteiro) Índice da LINHA na matriz do MATLAB.
    %   c              : (Inteiro) Índice da COLUNA na matriz do MATLAB.
    %   deslocamento_bruto    : (Inteiro) O valor original retirado direto da tabela.
    %   deslocamento_calculado: (Inteiro) O valor final após a operação de módulo.
    % =========================================================================
    
    % Leitura da tabela (Como os dados já estão organizados, vira matriz)
    % Passa o nome do arquivo que a pessoa deu para a tabela de referência (csv)
    dados = readmatrix(nome_arquivo);
    num_linhas_csv = size(dados, 1);
    
    % Usuário insere 1 para BG1 ou 2 para BG2 via parâmetro de entrada
    if opcao_bg == 1
        % CRIAÇÃO DA MATRIZ BASE (BG1)
        % A norma define que o Base Graph 1 tem exatamente 46 linhas e 68 colunas
        BG = ones(46, 68) * -1;
    else
        % CRIAÇÃO DA MATRIZ BASE (BG2)
        % A norma define que o Base Graph 2 tem exatamente 42 linhas e 52 colunas
        BG = ones(42, 52) * -1;
    end
    
    % No nosso CSV, as colunas 1 e 2 são as coordenadas.
    % Os valores de shift (sets de 0 a 7) começam na coluna 3.
    coluna_shift = 3 + iLS;
    
    % MAPEAMENTO DOS DADOS (VARRER O CSV)
    for k = 1:num_linhas_csv
        % Extrair coordenadas
        % Soma mais 1 pois o MATLAB começa no 1
        l = dados(k, 1) + 1;
        c = dados(k, 2) + 1;
        
        % Pega valor na coluna específica do Set index escolhido
        deslocamento_bruto = dados(k, coluna_shift);
        
        % Aplicação norma/padrão 3GPP
        deslocamento_calculado = mod(deslocamento_bruto, Zc);
        
        % Salva o valor final na posição exata da matriz BG
        % Essa será a matriz de base para o lifting 
        BG(l, c) = deslocamento_calculado;
    end
end