%GERA UMA CODEWORD VÁLIDA ALEATORIA USANDO BIT FLIPPING
function c = Rand_c(H, I_maximo)
    Bits = length(H);
    c = randi([0 1], 1, Bits);
    c = c * -1;
    for i = 1:I_maximo
        if mod(i, 10) == 0
            fprintf('codeword: %d\n', i);
        end
        for o = 1:100
            c(randi([1 Bits])) = 1;
            c(randi([1 Bits])) = -1;
        end
        c = Erasure_Decoding(H, c, 5);
        c = Bit_Flipping_Decoding(H, c, 50);
        if all(mod(H*c', 2) == 0)
            break
        end
    end
    if any(mod(H*c', 2) == 1) %dedecta sindrome
        error('Codeword nao encontrada');
    end

    