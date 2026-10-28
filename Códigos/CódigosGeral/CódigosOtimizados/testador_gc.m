function testador_gc = testador_gc()

    tabela = readtable('set.csv');
    quantidade = height(tabela);
    repeticoes = 250;

    % Vetores para armazenar os resultados
    Zc_valores = zeros(quantidade, 1);
    tempos = zeros(quantidade, 1);
    tempos_individuais = zeros(quantidade, repeticoes);
    tempos_totais = zeros(quantidade, 1);

    % Cronometro geral
    tempo_inicio = tic;

    for i = 1:quantidade

        tempo_Zc = tic;

        Zc = tabela{i, 1};
        Zc_valores(i) = Zc;

        BGn = 1;
        Kb = 22;

        [BG, i_ls] = baseGraph_generator(BGn, Zc);
        H = H_matrix_generator(BG, Zc);
        dados = ldpc_encode_nr_preprocess(H, Zc);

        fprintf('\n========================================\n');
        fprintf('Processando Zc = %d (%d/%d)\n', ...
            Zc, i, quantidade);
        fprintf('Progresso: %.1f%%\n', 100*(i-1)/quantidade);
        fprintf('========================================\n');

        % Executa cinco vezes
        for j = 1:repeticoes

            message = message_generator(Kb * Zc);

            tic;
            codeword = ldpc_encode_nr_process(message,dados);
            tempos_individuais(i, j) = toc;

            if sum(mod(H * codeword', 2)) ~= 0
                error("Sindrome diferente de zero para Zc = %d, repeticao %d.", ...
                    Zc, j);
            end

        end

        % Calcula a media e o tempo total de codificacao
        tempos(i) = mean(tempos_individuais(i, :));
        tempos_totais(i) = toc(tempo_Zc);

        % Informacoes ao terminar este Zc
        fprintf('\nZc = %d CONCLUIDO\n', Zc);
        fprintf('Tempo medio: %.6f s\n', tempos(i));
        fprintf('Tempo total neste Zc: %.3f s\n', tempos_totais(i));
        fprintf('Tempo total decorrido: %.2f s\n', toc(tempo_inicio));
        fprintf('Progresso: %.1f%% (%d/%d Zc processados)\n', ...
            100*i/quantidade, i, quantidade);

    end

    % Ordena Zc em ordem crescente e mantem os tempos associados
    [Zc_valores, ordem] = sort(Zc_valores);
    tempos = tempos(ordem);
    tempos_individuais = tempos_individuais(ordem, :);
    tempos_totais = tempos_totais(ordem);

    % Grafico de tempo medio por Zc
    figure;
    plot(Zc_valores, tempos, '-o', 'LineWidth', 1.5);
    xlabel('Z_c');
    ylabel('Tempo medio de execucao (s)');
    title('Tempo medio de codificacao LDPC por Z_c');
    grid on;

    % Salva o grafico em formato FIG
    savefig(gcf, 'tempo_codificacao_LDPC_internet_prepro.fig');

    % Retorna os dados
    testador_gc.Zc = Zc_valores;
    testador_gc.tempos = tempos;
    testador_gc.tempos_individuais = tempos_individuais;
    testador_gc.tempos_totais = tempos_totais;
    testador_gc.tempo_total_execucao = toc(tempo_inicio);

    fprintf('\n========================================\n');
    fprintf('TODOS OS TESTES FORAM CONCLUIDOS\n');
    fprintf('Tempo total: %.2f segundos (%.2f minutos)\n', ...
        testador_gc.tempo_total_execucao, ...
        testador_gc.tempo_total_execucao/60);
    fprintf('========================================\n');

end
