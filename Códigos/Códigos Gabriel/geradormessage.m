function msg = geradormessage(Bits)
    % Gera um vetor linha de tamanho 'Bits' contendo 0s e 1s aleatórios
    msg = randi([0 1], 1, Bits);
end