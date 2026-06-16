%GERA UMA CODEWORD VÁLIDA ALEATORIA
function c = codeword_generator(msg, G)
    mascara = msg;
    mascara(mascara == -1) = 0;
    c = mod(mascara*G,2);
    n = length(msg);
    c(1:n) = msg;