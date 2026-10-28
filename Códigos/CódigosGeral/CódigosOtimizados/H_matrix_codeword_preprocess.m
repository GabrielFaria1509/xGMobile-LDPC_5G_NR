function dados = H_matrix_codeword_preprocess(H, Zc, BGn, i_ls)

    % Define Kb conforme o Base Graph
    if BGn == 1
        Kb = 22;
    elseif BGn == 2
        Kb = 10;
    else
        error("BGn invalido.");
    end

    % Extrai as matrizes utilizadas na codificacao
    core = H(1:4*Zc, Kb*Zc+1:(Kb+4)*Zc);
    topo = H(1:4*Zc, 1:Kb*Zc);
    BlocoSis = H(4*Zc+1:end, 1:(Kb+4)*Zc);

    [m, n] = size(core);

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

    % Armazena os dados para reutilizacao
    dados.core = core;
    dados.topo = topo;
    dados.BlocoSis = BlocoSis;
    dados.ordem = ordem;
    dados.m = m;
    dados.n = n;

end