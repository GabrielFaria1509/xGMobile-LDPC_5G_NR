%GERA UMA CODEWORD VÁLIDA ALEATORIA USANDO BIT FLIPPING
function c = Rand_c(H, I_maximo)
    Bits = length(H);
    c = randi([0 1], 1, Bits);
    c = Bit_Flipping_Decoding(H, c, I_maximo);
    if any(mod(H*c', 2) == 1) %dedecta sindrome
        error('Codeword nao encontrada');
    end

    