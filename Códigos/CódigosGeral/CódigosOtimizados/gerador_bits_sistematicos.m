function bits_sistematicos = gerador_bits_sistematicos(message, core, topo, Zc, BGn)

    resultados = mod(message * topo', 2);

    [m, n] = size(core);

    % Matriz aumentada
    A = [core resultados'];

    % Organiza as equações
    A_org = organizador(A, Zc,BGn);

    solucao_encontrada = false;

    if BGn == 1
        start = 2;
    else
        start = 1;
    end
    % Testa x1 = 1 e depois x1 = 0
    for bit_inicial = [true false]

        % Vetor de valores
        bits_sistematicos = false(1, n);

        % Máscara indicando quais bits já conhecemos
        bits_conhecidos = false(1, n);

        % Condição inicial
        bits_sistematicos(start) = bit_inicial;
        bits_conhecidos(start) = true;

        % =====================================================
        % PROPAGAÇÃO
        % =====================================================

        for i = 1:m-1

            % Coeficientes da equação
            linha = logical(A_org(i, 1:n));

            % Resultado da equação
            resultado = logical(A_org(i, n+1));

            % Bits desconhecidos presentes nesta equação
            posicao_desconhecido = ...
                linha & ~bits_conhecidos;

            % Verificação importante durante desenvolvimento
            if nnz(posicao_desconhecido) ~= 1
                error( ...
                    "A equação %d não possui exatamente um bit desconhecido.", ...
                    i ...
                );
            end

            % Bits conhecidos que participam da equação
            conhecidos = linha & bits_conhecidos;

            % XOR dos conhecidos
            xor_conhecidos = ...
                mod(sum(bits_sistematicos(conhecidos)), 2);

            % x_desconhecido XOR xor_conhecidos = resultado
            %
            % portanto:
            %
            % x_desconhecido = resultado XOR xor_conhecidos

            valor_deseconhecido = ...
                xor(resultado, logical(xor_conhecidos));

            % Salva novo bit
            bits_sistematicos(posicao_desconhecido) = ...
                valor_deseconhecido;

            % Marca como conhecido
            bits_conhecidos(posicao_desconhecido) = true;

        end

        % =====================================================
        % VERIFICAÇÃO FINAL
        % =====================================================

        linha = logical(A_org(m, 1:n));
        resultado = logical(A_org(m, n+1));

        resultado_calculado = ...
            mod(sum(bits_sistematicos(linha)), 2);

        if resultado_calculado == resultado

            solucao_encontrada = true;
            break;

        end

    end

    if ~solucao_encontrada
        error("Nenhuma solução foi encontrada.");

    end

end