%GERA UMA CODEWORD VÁLIDA ALEATORIA
function c = Rand_c(G)
    Bits = height(G);
    m = rand([0 1], 1, Bits);
    c = mod(m*G,2);