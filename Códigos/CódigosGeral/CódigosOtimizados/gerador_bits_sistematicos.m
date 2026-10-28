    function bits_sistematicos = gerador_bits_sistematicos(message, core, topo, Zc, BGn, i_ls)
    
        [m, n] = size(core);
    
        % Calcula os resultados das equacoes
        resultados = mod(message * topo', 2);
        resultados = resultados(:);
    
        % Pre-calcula a ordem das linhas, sem reorganizar a matriz
        i = (1:m)';
        grupo = floor((i - 1) / 4) + 1;
        posicao = mod(i - 1, 4) + 1;
    
        if BGn == 1
            sequencia = [1, 4, 3, 2];
        elseif BGn == 2
            sequencia = [1, 2, 4, 3];
        else
            error("BGn invalido.");
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
    
        % Testa x1 = 1 e depois x1 = 0
        for bit_inicial = [true false]
    
            bits_sistematicos = false(1, n);
            bits_conhecidos = false(1, n);
    
            bits_sistematicos(1) = bit_inicial;
            bits_conhecidos(1) = true;
    
            solucao_encontrada = true;
    
            % Propagacao das equacoes
            for i = 1:m-1
    
                idx = ordem(i);
    
                % Acessa diretamente a matriz original
                linha = core(idx, :) ~= 0;
    
                % Localiza o unico bit desconhecido
                desconhecido = find(linha & ~bits_conhecidos);
    
                if numel(desconhecido) ~= 1
                    error( ...
                        "A equacao %d nao possui exatamente um bit desconhecido.", ...
                        i ...
                    );
                end
    
                % XOR dos bits conhecidos:
                % os bits desconhecidos ainda possuem valor zero
                paridade = mod(nnz(linha & bits_sistematicos), 2);
    
                % Resolve a equacao em GF(2)
                bits_sistematicos(desconhecido) = ...
                    xor(logical(resultados(idx)), logical(paridade));
    
                bits_conhecidos(desconhecido) = true;
    
            end
    
            % Verificacao da ultima equacao
            idx = ordem(m);
            linha = core(idx, :) ~= 0;
    
            resultado_calculado = mod( ...
                nnz(linha & bits_sistematicos), 2);
    
            if resultado_calculado ~= resultados(idx)
                solucao_encontrada = false;
            end
    
            if solucao_encontrada
                return;
            end
    
        end
    
        error("Nenhuma solucao foi encontrada.");
    
    end
