function c = H_matrix_codeword_generator(message, H, Zc, BGn, i_ls)

    % Define Kb conforme o Base Graph
    if BGn == 1
        Kb = 22;
    elseif BGn == 2
        Kb = 10;
    else
        error("BGn invalido.");
    end

    % Particionamento da matriz H
    core = H(1:4*Zc, Kb*Zc+1:(Kb+4)*Zc);
    topo = H(1:4*Zc, 1:Kb*Zc);

    [m, n] = size(core);

    % Calcula os resultados das equacoes
    resultados = mod(message * topo', 2);
    resultados = resultados(:);

    % Calcula a ordem das linhas
    i = (1:m)';
    grupo = floor((i - 1) / 4) + 1;
    posicao = mod(i - 1, 4) + 1;

    if BGn == 1
        sequencia = [1, 4, 3, 2];
    else
        sequencia = [1, 2, 4, 3];
    end

    bloco = reshape(sequencia(posicao), [], 1);

    if BGn == 1 && Zc == 208

        deslocamento = mod((grupo - 1) * 105, 208);
        ordem = Zc * (bloco - 1) + deslocamento + 1;

    elseif (BGn == 2 && i_ls ~= 3 && i_ls ~= 7) || ...
           (BGn == 1 && i_ls == 6)

        ordem = Zc * (bloco - 1) + grupo;

    else

        ordem = Zc * bloco - grupo + 1;

    end

    % Resolve o sistema testando x1 = 1 e depois x1 = 0
    solucao_encontrada = false;

    for bit_inicial = [true false]

        bits_sistematicos = false(1, n);
        bits_conhecidos = false(1, n);

        bits_sistematicos(1) = bit_inicial;
        bits_conhecidos(1) = true;

        % Propagacao das equacoes
        for i = 1:m-1

            idx = ordem(i);
            linha = core(idx, :) ~= 0;

            % Localiza o unico bit desconhecido
            desconhecido = find(linha & ~bits_conhecidos);

            if numel(desconhecido) ~= 1
                error( ...
                    "A equacao %d nao possui exatamente um bit desconhecido.", ...
                    i ...
                );
            end

            % Calcula a paridade dos bits conhecidos
            paridade = mod(nnz(linha & bits_sistematicos), 2);

            % Resolve a equacao em GF(2)
            bits_sistematicos(desconhecido) = ...
                xor(logical(resultados(idx)), logical(paridade));

            bits_conhecidos(desconhecido) = true;

        end

        % Verifica a ultima equacao
        idx = ordem(m);
        linha = core(idx, :) ~= 0;

        resultado_calculado = mod( ...
            nnz(linha & bits_sistematicos), 2);

        if resultado_calculado == resultados(idx)
            solucao_encontrada = true;
            break;
        end

    end

    if ~solucao_encontrada
        error("Nenhuma solucao foi encontrada.");
    end

    % Monta a palavra sistematica
    csis = [message, bits_sistematicos];

    % Calcula os bits restantes da palavra-codigo
    BlocoSis = H(4*Zc+1:end, 1:(Kb+4)*Zc);

    c = [csis, mod(csis * BlocoSis', 2)];

end