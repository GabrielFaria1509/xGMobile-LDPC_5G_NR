function organizado = organizador(matriz,Zc,BGn)

    [m, n] = size(matriz);
    nova = zeros(m, n);
    contador = 1;
    
    if BGn == 1
        sequencia = [1, 4, 3, 2];
        %Primeira linha de cada menos do ultimo, que é a segunda
    else
        sequencia = [1, 2, 4, 3];
    end

    if BGn == 2
        for l = 1:Zc
            for bloco = sequencia
                nova(contador, :) = matriz(Zc*(bloco-1)+l, :);
                contador = contador+1;
            end
        end
    else
        for bloco = sequencia
                nova(contador, :) = matriz(Zc*(bloco-1)+1, :);
                contador = contador+1;
        end
        for l = Zc:-1:2
            for bloco = sequencia
                nova(contador, :) = matriz(Zc*(bloco-1)+l, :);
                contador = contador+1;
            end
        end
    end


    organizado = nova;
end