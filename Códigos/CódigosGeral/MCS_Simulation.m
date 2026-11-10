%% Simulação de Tempo de Codificação LDPC 5G NR sob Adaptação Dinâmica de MCS
% Comparação: Método Convencional (Matriz G) vs. Método Proposto (Two-Step H)
% Cenários: Pedestre (Baixa Mobilidade) vs. Veicular (Alta Mobilidade)
% Cadeia 3GPP TS 38.212 Completa Integrada:
%   1. Base_Graph_selector.m
%   2. crc_generator.m (CRC-16 / CRC-24A de TB e CRC-24B de CB)
%   3. codeBlockSegmentation.m
%   4. codeblockcrcimplementation.m
%   5. Zc_selector.m
%   6. codeBlockFiller.m (+ filler_bits.m)
%   7. baseGraph_generator.m / H_matrix_generator.m / G_matrix_generator_2.m
%   8. codeBlockEncoding.m (codeword_generator.m) vs. H_matrix_codeword_generator.m

clear; clc; close all;

% Adiciona automaticamente todas as subpastas do projeto ao Path do MATLAB
addpath(genpath(pwd));

%% 1. PARÂMETROS E TABELA MCS 3GPP (TS 38.214 - Tabela 5.1.3.1-1)
num_quadros = 20;
cenarios = {'Pedestre', 'Veicular'};
algoritmos = {'Convencional (Matriz G)', 'Proposto (Two-Step H)'};

% Tabela 5.1.3.1-1 (Índices 0 a 28): [Indice_MCS, Qm, R_nominal_x1024]
tabela_MCS = [
     0, 2, 120;   1, 2, 157;   2, 2, 193;   3, 2, 251;   4, 2, 308;
     5, 2, 379;   6, 2, 449;   7, 2, 526;   8, 2, 602;   9, 2, 679;
    10, 4, 340;  11, 4, 378;  12, 4, 434;  13, 4, 490;  14, 4, 553;
    15, 4, 616;  16, 4, 658;  17, 6, 438;  18, 6, 466;  19, 6, 517;
    20, 6, 567;  21, 6, 616;  22, 6, 666;  23, 6, 719;  24, 6, 772;
    25, 6, 822;  26, 6, 873;  27, 6, 910;  28, 6, 948
];

% Recursos de Rádio de referência (51 PRBs, 12 subportadoras, 12 símbolos úteis/slot)
N_RE_slot = 51 * 12 * 12;

%% 2. FASE 2: VALIDAÇÃO DA CADEIA COMPLETA COM SEGMENTAÇÃO (MCS 5, 15 e 25)
fprintf('=== FASE 2: Validando cadeia completa 3GPP (com codeBlockEncoding) ===\n');
rng(10);

for mcs_teste = [5, 15, 25]
    Qm = tabela_MCS(mcs_teste + 1, 2);
    R  = tabela_MCS(mcs_teste + 1, 3) / 1024;
    
    % Cálculo do Tamanho do Bloco de Transporte (A) permitindo C >= 1
    N_info = N_RE_slot * Qm * R * 0.35;
    A = max(256, 8 * round(N_info / 8));
    tb_bits = randi([0 1], 1, A);
    
    % 1. Seleção do Base Graph
    BGn = Base_Graph_selector(A, R);
    
    % 2. CRC do Transport Block
    tb_crc = crc_generator(tb_bits);
    TB_with_CRC = [tb_bits, tb_crc];
    
    % 3. Segmentação em Code Blocks e aplicação do CRC-24B quando C > 1
    [cbs_raw, C, K_prime, ~] = codeBlockSegmentation(TB_with_CRC, BGn);
    cbs_crc = codeblockcrcimplementation(cbs_raw, C);
    
    % 4. Seleção de Zc e Kb a partir de K_prime
    [Zc, Kb] = Zc_selector(K_prime, BGn);
    
    % 5. Preenchimento de Filler Bits (-1) até K_total = Kb_max * Zc
    Kb_max = 22; if BGn == 2; Kb_max = 10; end
    K_total = Kb_max * Zc;
    cbs_filler = codeBlockFiller(cbs_crc, C, K_total);
    
    % 6. Matrizes estruturais para o par (BGn, Zc)
    [BG_mat, i_ls] = baseGraph_generator(BGn, Zc);
    H_mat = H_matrix_generator(BG_mat, Zc);
    G_mat = G_matrix_generator_2(H_mat, Zc);
    
    % 7. Codificação Convencional via codeBlockEncoding.m
    encoded_conv = codeBlockEncoding(cbs_filler, C, G_mat);
    
    % 8. Codificação Proposta e verificação em todos os C Code Blocks
    for i = 1:C
        cb_gf2 = cbs_filler{i};
        cb_gf2(cb_gf2 == -1) = 0; % Mesma conversão temporária da codeBlockEncoding.m
        
        cw_prop = H_matrix_codeword_generator(cb_gf2, H_mat, Zc, BGn, i_ls);
        cw_conv = encoded_conv{i};
        
        diff_bits = any(cw_conv(:) ~= cw_prop(:));
        sindrome  = any(mod(H_mat * double(cw_prop(:)), 2) ~= 0);
        
        if diff_bits || sindrome
            error('Falha na validação para MCS %d no Code Block %d/%d!', mcs_teste, i, C);
        end
    end
    fprintf('  [OK] MCS %2d -> A=%5d, BG%d, C=%d CB(s), K''=%4d, Kb=%2d, Zc=%3d | Síndrome e Igualdade OK!\n', ...
        mcs_teste, A, BGn, C, K_prime, Kb, Zc);
end

%% 3. FASE 3: GERAÇÃO DOS TRAÇOS DE TRANSMISSÃO (Fora do Cronômetro)
fprintf('\n=== FASE 3: Gerando traços de transmissão (Pedestre vs. Veicular) ===\n');
rng(42); % Semente fixa para reprodutibilidade científica

tracos = struct();
for ch = 1:2
    MCS_seq = zeros(1, num_quadros);
    A_seq   = zeros(1, num_quadros);
    BG_seq  = zeros(1, num_quadros);
    C_seq   = zeros(1, num_quadros);
    Zc_seq  = zeros(1, num_quadros);
    Kb_seq  = zeros(1, num_quadros);
    cbs_cel = cell(1, num_quadros); % Guarda os C Code Blocks com filler (-1)
    
    mcs_atual = 14;
    
    for f = 1:num_quadros
        if ch == 1
            % PEDESTRE (3 km/h): Canal lento, pequenas transições a cada 25 quadros
            if mod(f, 25) == 1
                passo = randi([-1, 1]);
                mcs_atual = min(max(mcs_atual + passo, 12), 16);
            end
        else
            % VEICULAR (120 km/h): Canal rápido, variação ampla de MCS a cada quadro
            mcs_atual = randi([1, 27]);
        end
        
        Qm = tabela_MCS(mcs_atual + 1, 2);
        R  = tabela_MCS(mcs_atual + 1, 3) / 1024;
        
        % Calcula tamanho A (TBS) escalonado pela eficiência espectral (permitindo C >= 1)
        fator_carga = 0.25 + 0.05 * mod(mcs_atual, 5);
        A = max(120, 8 * round((N_RE_slot * Qm * R * fator_carga) / 8));
        
        % Executa a cadeia 3GPP pré-LDPC (Fora da medição de tempo LDPC)
        BGn = Base_Graph_selector(A, R);
        
        tb_bits     = randi([0 1], 1, A);
        tb_crc      = crc_generator(tb_bits);
        TB_with_CRC = [tb_bits, tb_crc];
        
        [cbs_raw, C, K_prime, ~] = codeBlockSegmentation(TB_with_CRC, BGn);
        cbs_crc = codeblockcrcimplementation(cbs_raw, C);
        
        [Zc, Kb] = Zc_selector(K_prime, BGn);
        
        Kb_max  = 22; if BGn == 2; Kb_max = 10; end
        K_total = Kb_max * Zc;
        cbs_filler = codeBlockFiller(cbs_crc, C, K_total);
        
        MCS_seq(f) = mcs_atual;
        A_seq(f)   = A;
        BG_seq(f)  = BGn;
        C_seq(f)   = C;
        Zc_seq(f)  = Zc;
        Kb_seq(f)  = Kb;
        cbs_cel{f} = cbs_filler;
    end
    
    tracos(ch).MCS = MCS_seq;
    tracos(ch).A   = A_seq;
    tracos(ch).BGn = BG_seq;
    tracos(ch).C   = C_seq;
    tracos(ch).Zc  = Zc_seq;
    tracos(ch).Kb  = Kb_seq;
    tracos(ch).cbs = cbs_cel;
end

%% 4. FASE 4: BENCHMARK PAREADO COM CACHE FRIO
fprintf('\n=== FASE 4: Executando Benchmark Pareado com Cache Frio ===\n');

t_prep_hist  = zeros(2, 2, num_quadros);
t_enc_hist   = zeros(2, 2, num_quadros);
t_tot_hist   = zeros(2, 2, num_quadros);
cache_hits   = zeros(2, 2); % Contabilizado por Code Block
cache_misses = zeros(2, 2); % Contabilizado por Code Block

for ch = 1:2
    fprintf('  Simulando cenário %s (%d quadros)...\n', cenarios{ch}, num_quadros);
    
    % Inicializa Caches Frios vazios para o cenário atual
    cache_Conv = containers.Map('KeyType', 'char', 'ValueType', 'any');
    cache_Prop = containers.Map('KeyType', 'char', 'ValueType', 'any');
    
    for f = 1:num_quadros
        Zc    = tracos(ch).Zc(f);
        BGn   = tracos(ch).BGn(f);
        C     = tracos(ch).C(f);
        cbs_f = tracos(ch).cbs{f};
        
        % Chave estrutural do cache: K = (BG, Zc)
        chave = sprintf('BG%d_Zc%d', BGn, Zc);
        
        % -----------------------------------------------------------------
        % ALGORITMO 1: CONVENCIONAL (MATRIZ G + codeBlockEncoding.m)
        % -----------------------------------------------------------------
        if ~isKey(cache_Conv, chave) % CACHE MISS no 1º CB; os demais (C-1) CBs são HIT
            cache_misses(ch, 1) = cache_misses(ch, 1) + 1;
            cache_hits(ch, 1)   = cache_hits(ch, 1) + (C - 1);
            t0 = tic;
            [BG_mat, ~] = baseGraph_generator(BGn, Zc);
            H_temp = H_matrix_generator(BG_mat, Zc);
            G_mat  = G_matrix_generator_2(H_temp, Zc);
            tPrep_C = toc(t0);
            cache_Conv(chave) = G_mat;
        else % CACHE HIT em todos os C Code Blocks do quadro
            cache_hits(ch, 1) = cache_hits(ch, 1) + C;
            tPrep_C = 0;
            G_mat = cache_Conv(chave);
        end
        
        % Chama diretamente a função codeBlockEncoding.m da equipe
        t0 = tic;
        encoded_c = codeBlockEncoding(cbs_f, C, G_mat); %#ok<NASGU>
        tEnc_C = toc(t0);
        
        t_prep_hist(ch, 1, f) = tPrep_C;
        t_enc_hist(ch, 1, f)  = tEnc_C;
        t_tot_hist(ch, 1, f)  = tPrep_C + tEnc_C;
        
        % -----------------------------------------------------------------
        % ALGORITMO 2: PROPOSTO (TWO-STEP / H ESPARSA)
        % -----------------------------------------------------------------
        if ~isKey(cache_Prop, chave) % CACHE MISS no 1º CB; os demais (C-1) CBs são HIT
            cache_misses(ch, 2) = cache_misses(ch, 2) + 1;
            cache_hits(ch, 2)   = cache_hits(ch, 2) + (C - 1);
            t0 = tic;
            [BG_mat, i_ls] = baseGraph_generator(BGn, Zc);
            H_esp = H_matrix_generator(BG_mat, Zc);
            dados_prop = struct('H', H_esp, 'i_ls', i_ls);
            tPrep_P = toc(t0);
            cache_Prop(chave) = dados_prop;
        else % CACHE HIT em todos os C Code Blocks do quadro
            cache_hits(ch, 2) = cache_hits(ch, 2) + C;
            tPrep_P = 0;
            dados_prop = cache_Prop(chave);
        end
        
        % Estrutura espelhada à codeBlockEncoding.m para os C Code Blocks
        t0 = tic;
        encoded_p = cell(1, C);
        for i = 1:C
            code_block_GF2 = cbs_f{i};
            code_block_GF2(code_block_GF2 == -1) = 0;
            encoded_p{i} = H_matrix_codeword_generator(code_block_GF2, dados_prop.H, Zc, BGn, dados_prop.i_ls);
        end
        tEnc_P = toc(t0);
        
        t_prep_hist(ch, 2, f) = tPrep_P;
        t_enc_hist(ch, 2, f)  = tEnc_P;
        t_tot_hist(ch, 2, f)  = tPrep_P + tEnc_P;
        
        if mod(f, 200) == 0
            fprintf('    Quadro %d/%d concluído.\n', f, num_quadros);
        end
    end
end

%% 5. FASE 5: TABELA AUXILIAR E GERAÇÃO DA FIGURA 6 (4 PAINÉIS)
fprintf('\n=== RESUMO PARA A TABELA AUXILIAR DO ARTIGO ===\n');
for ch = 1:2
    trocas_MCS = sum(diff(tracos(ch).MCS) ~= 0);
    trocas_BG  = sum(diff(tracos(ch).BGn) ~= 0);
    trocas_Zc  = sum(diff(tracos(ch).Zc) ~= 0);
    total_CBs  = sum(tracos(ch).C);
    hit_rate   = 100 * cache_hits(ch, 1) / total_CBs;
    
    fprintf('Cenário %s:\n', cenarios{ch});
    fprintf('  - Total de Quadros: %d | Total de Code Blocks processados: %d (Média: %.2f CB/TB)\n', ...
        num_quadros, total_CBs, total_CBs / num_quadros);
    fprintf('  - Alterações de MCS: %d | Alterações de BG: %d | Alterações de Zc: %d\n', ...
        trocas_MCS, trocas_BG, trocas_Zc);
    fprintf('  - Configurações (BG, Zc) inéditas (Cache Misses): %d | Cache Hit Rate (por CB): %.1f%%\n', ...
        cache_misses(ch, 1), hit_rate);
    fprintf('  - Tempo Médio Final Convencional: %.3f ms/quadro\n', 1000 * mean(t_tot_hist(ch, 1, :)));
    fprintf('  - Tempo Médio Final Proposto:     %.3f ms/quadro\n\n', 1000 * mean(t_tot_hist(ch, 2, :)));
end

% Cálculo da média acumulada em milissegundos (ms)
media_acum_ms = zeros(2, 2, num_quadros);
eixo_q = 1:num_quadros;
for ch = 1:2
    for alg = 1:2
        tempos_ms = 1000 * squeeze(t_tot_hist(ch, alg, :))';
        media_acum_ms(ch, alg, :) = cumsum(tempos_ms) ./ eixo_q;
    end
end

% Plotagem da Figura 6 (4 painéis)
fig6 = figure('Name', 'Figura 6 - Adaptação Dinâmica de MCS', 'Position', [100, 100, 1050, 650]);
quadros_zoom = 1:min(100, num_quadros);

% Painel (a): Sequência de MCS Pedestre
subplot(2, 2, 1);
stairs(quadros_zoom, tracos(1).MCS(quadros_zoom), 'LineWidth', 1.8, 'Color', [0.12 0.47 0.71]);
grid on;
title('(a) Pedestre: sequência de MCS');
xlabel('Quadro NR'); ylabel('Índice MCS');
ylim([0 28]);

% Painel (b): Sequência de MCS Veicular
subplot(2, 2, 2);
stairs(quadros_zoom, tracos(2).MCS(quadros_zoom), 'LineWidth', 1.8, 'Color', [0.12 0.47 0.71]);
grid on;
title('(b) Veicular: sequência de MCS');
xlabel('Quadro NR'); ylabel('Índice MCS');
ylim([0 28]);

ymin_val = min(media_acum_ms(:)) * 0.8;
ymax_val = max(media_acum_ms(:)) * 1.2;

% Painel (c): Média Acumulada Pedestre
subplot(2, 2, 3);
plot(eixo_q, squeeze(media_acum_ms(1, 1, :)), 'LineWidth', 2, 'Color', [0.12 0.47 0.71]); hold on;
plot(eixo_q, squeeze(media_acum_ms(1, 2, :)), 'LineWidth', 2, 'Color', [0.17 0.63 0.17]);
set(gca, 'YScale', 'log'); grid on;
title('(c) Pedestre: média acumulada');
xlabel('Número de quadros processados'); ylabel('Tempo médio (ms)');
ylim([ymin_val ymax_val]);
legend(algoritmos, 'Location', 'northeast');

% Painel (d): Média Acumulada Veicular
subplot(2, 2, 4);
plot(eixo_q, squeeze(media_acum_ms(2, 1, :)), 'LineWidth', 2, 'Color', [0.12 0.47 0.71]); hold on;
plot(eixo_q, squeeze(media_acum_ms(2, 2, :)), 'LineWidth', 2, 'Color', [0.17 0.63 0.17]);
set(gca, 'YScale', 'log'); grid on;
title('(d) Veicular: média acumulada');
xlabel('Número de quadros processados'); ylabel('Tempo médio (ms)');
ylim([ymin_val ymax_val]);
legend(algoritmos, 'Location', 'northeast');

savefig(fig6, 'Figura6_LDPC_MCS_Dinamico.fig');
fprintf('Gráfico salvo com sucesso como "Figura6_LDPC_MCS_Dinamico.fig"!\n');