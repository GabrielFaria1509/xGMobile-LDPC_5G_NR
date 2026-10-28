function organizado = organizador(matriz,Zc,BGn, i_ls)

    [m, n] = size(matriz);
    nova = zeros(m, n);
    contador = 1;
    
    spy(matriz)

    if (BGn == 1)
        sequencia = [1, 4, 3, 2];
    elseif (BGn == 2)
        sequencia = [1, 2, 4, 3];
    end


    if (BGn == 1 && Zc == 208)
        l = 0;
        for i = 1:Zc
            for bloco = sequencia
                nova(contador, :) = matriz(Zc*(bloco-1)+l+1, :);
                contador = contador + 1;
            end
            l = mod(l+105,208);
        end
    elseif ((BGn == 2 && i_ls ~= 3 && i_ls ~= 7) || (BGn == 1 && i_ls == 6))
        for l = 1:Zc
            for bloco = sequencia
                nova(contador, :) = matriz(Zc*(bloco-1)+l, :);
                contador = contador+1;
            end
        end
    else 
        for l = 1:Zc
            for bloco = sequencia
                nova(contador, :) = matriz(Zc*bloco-l+1, :);
                contador = contador+1;
            end
        end
    end


    organizado = nova;
    spy(organizado);
end