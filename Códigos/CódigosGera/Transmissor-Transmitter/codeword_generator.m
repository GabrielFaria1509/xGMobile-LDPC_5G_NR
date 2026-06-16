%GERA UMA CODEWORD VÁLIDA ALEATORIA
function c = codeword_generator(msg, G)
    c = mod(msg*G,2);