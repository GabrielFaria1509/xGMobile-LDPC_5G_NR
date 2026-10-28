function c = H_matrix_codeword_generator_process(message, dados)

    core = dados.core;
    topo = dados.topo;
    BlocoSis = dados.BlocoSis;
    ordem = dados.ordem;

    m = dados.m;
    n = dados.n;

    % Calcula os resultados das equacoes para a mensagem atual
    resultados = mod(message * topo', 2);
    resultados = resultados(:);

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
    c = [csis, mod(csis * BlocoSis', 2)];

end