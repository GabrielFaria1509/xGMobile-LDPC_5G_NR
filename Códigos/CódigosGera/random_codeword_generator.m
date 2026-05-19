%GERA UMA CODEWORD VÁLIDA ALEATORIA
function c = Gerador_c_aleatorio(G)
    Bits = height(G);
    m = randi([0 1], 1, Bits);
    c = mod(m*G,2);