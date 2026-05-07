function msg = geradormessage(G)
    % Gera um vetor linha de tamanho 'Bits' contendo 0s e 1s aleatórios
    % 1. Extrai a quantidade de linhas da matriz G (que equivale a 'k' bits de informação)
    % Usamos o '~' para ignorar o número de colunas, pois não precisamos dele aqui
    [k, ~] = size(G);
    
    % 2. Gera um vetor linha de tamanho 'k' contendo 0s e 1s aleatórios
    msg = randi([0 1], 1, k);
    
end


