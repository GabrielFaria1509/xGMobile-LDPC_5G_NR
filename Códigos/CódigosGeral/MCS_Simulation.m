%% 5G NR LDPC Encoding Latency Benchmark under Dynamic MCS Adaptation
% Structured according to the reference Monte Carlo pseudocode:
%   - Loops: s (Nseeds) -> ch (scenarios) -> a (algorithms) -> f (Nframes) -> j (TBs)
%   - 4D Tensor: tempo(a, ch, s, f)
%   - Cumulative running average: cumsum(tempo, 4) ./ (1:Nframes)
%   - Cross-seed aggregation with 95% Student-t Confidence Intervals (CI)

clear; clc; close all;

% Automatically add all project subfolders to the MATLAB path
addpath(genpath(pwd));

%% 1. SIMULATION PARAMETERS
Nframes = 20;   % Change to 1000 for the final overnight run
Nseeds  = 2;    % Change to 20 for the final overnight run

cenarios   = {'Pedestre', 'Veicular'};
algoritmos = {'Convencional', 'Richardson', 'Proposto'};

% Formal LaTeX labels for international publication (IEEE style)
alg_labels_latex = { ...
    'Conventional ($\mathbf{G}$ Matrix)', ...
    'Richardson--Urbanke', ...
    'Proposed (Two-Step $\mathbf{H}$)' ...
};

num_algs = numel(algoritmos);
num_ch   = numel(cenarios);

% 4D Timing Tensor (seconds): tempo(a, ch, s, f)
tempo = zeros(num_algs, num_ch, Nseeds, Nframes);

% Auxiliary statistics for the paper summary table
stats_misses = zeros(num_algs, num_ch, Nseeds);
stats_hits   = zeros(num_algs, num_ch, Nseeds);
stats_CBs    = zeros(num_ch, Nseeds);
stats_MCS_sw = zeros(num_ch, Nseeds);
stats_BG_sw  = zeros(num_ch, Nseeds);
stats_Zc_sw  = zeros(num_ch, Nseeds);

% Store Seed 1 trace for panels (a) and (b)
traco_plot = cell(1, num_ch);

%% 2. MONTE CARLO BENCHMARK EXECUTION
fprintf('=== Starting Monte Carlo Benchmark (Nframes=%d, Nseeds=%d) ===\n', Nframes, Nseeds);

for s = 1:Nseeds
    fprintf('\n--- Seed s = %d/%d ---\n', s, Nseeds);
    
    for ch = 1:num_ch
        % Generate trace once per seed/scenario; reuse across all algorithms
        traco = gerar_traco_5gnr(cenarios{ch}, Nframes, s);
        
        if s == 1
            traco_plot{ch} = traco;
        end
        
        % Channel transition statistics for current seed
        mcs_vec = arrayfun(@(x) x.TBs(1).MCS, traco);
        bg_vec  = arrayfun(@(x) x.TBs(1).BGn, traco);
        zc_vec  = arrayfun(@(x) x.TBs(1).Zc,  traco);
        cb_vec  = arrayfun(@(x) sum([x.TBs.C]), traco);
        
        stats_MCS_sw(ch, s) = sum(diff(mcs_vec) ~= 0);
        stats_BG_sw(ch, s)  = sum(diff(bg_vec)  ~= 0);
        stats_Zc_sw(ch, s)  = sum(diff(zc_vec)  ~= 0);
        stats_CBs(ch, s)    = sum(cb_vec);
        
        for a = 1:num_algs
            fprintf('  [%s | %s] Processing %d frames...\n', cenarios{ch}, algoritmos{a}, Nframes);
            cache = criar_cache_vazio();
            
            for f = 1:Nframes
                tQuadro = 0;
                
                for j = 1:numel(traco(f).TBs)
                    tb = traco(f).TBs(j);
                    chave = criar_chave_estrutura(tb);
                    
                    if ~cache_contem(cache, chave)
                        stats_misses(a, ch, s) = stats_misses(a, ch, s) + 1;
                        stats_hits(a, ch, s)   = stats_hits(a, ch, s) + (tb.C - 1);
                        
                        t0 = tic;
                        dados = preparar_estrutura(algoritmos{a}, tb);
                        tPrep = toc(t0);
                        
                        cache = guardar(cache, chave, dados);
                    else
                        stats_hits(a, ch, s) = stats_hits(a, ch, s) + tb.C;
                        
                        tPrep = 0;
                        dados = consultar(cache, chave);
                    end
                    
                    t0 = tic;
                    cw = codificar_blocos_do_TB(algoritmos{a}, tb, dados);
                    tEnc = toc(t0);
                    
                    % Out-of-benchmark syndrome validation (Seed 1, first 5 frames)
                    if s == 1 && f <= 5
                        validar_fora_do_benchmark(cw, tb, algoritmos{a});
                    end
                    
                    tQuadro = tQuadro + tPrep + tEnc;
                end
                
                tempo(a, ch, s, f) = tQuadro;
            end
        end
    end
end

%% 3. POST-PROCESSING: CUMULATIVE MEAN & 95% CONFIDENCE INTERVALS
% Convert seconds to milliseconds (ms)
tempo_ms = 1000 * tempo;

% Cumulative average per realization along dimension 4: cumsum(..., 4) ./ (1:Nframes)
divisor_N    = reshape(1:Nframes, 1, 1, 1, Nframes);
media_acum_s = cumsum(tempo_ms, 4) ./ divisor_N; % Dimensions: (a, ch, s, f)

% Aggregate across seeds (dimension 3) and compute 95% Student-t CI for each N
media_agregada = reshape(mean(media_acum_s, 3), [num_algs, num_ch, Nframes]);
if Nseeds > 1
    std_agregado = reshape(std(media_acum_s, 0, 3), [num_algs, num_ch, Nframes]);
    t_critico    = tinv(0.975, Nseeds - 1);
    ic_95        = t_critico * (std_agregado / sqrt(Nseeds));
else
    ic_95 = zeros(num_algs, num_ch, Nframes);
end

%% 4. SUMMARY TABLE OUTPUT FOR THE MANUSCRIPT
fprintf('\n=== AGGREGATED SUMMARY FOR PAPER TABLE (%d Seeds x %d Frames) ===\n', Nseeds, Nframes);
for ch = 1:num_ch
    total_cbs_med = mean(stats_CBs(ch, :));
    misses_med    = mean(stats_misses(1, ch, :));
    hits_med      = mean(stats_hits(1, ch, :));
    hit_rate_med  = 100 * hits_med / total_cbs_med;
    
    fprintf('Scenario: %s\n', cenarios{ch});
    fprintf('  - Total Code Blocks/seed: %.1f (Mean: %.2f CB/Frame)\n', ...
        total_cbs_med, total_cbs_med / Nframes);
    fprintf('  - Mean Transitions: I_MCS = %.1f | BG = %.1f | Z_c = %.1f\n', ...
        mean(stats_MCS_sw(ch, :)), mean(stats_BG_sw(ch, :)), mean(stats_Zc_sw(ch, :)));
    fprintf('  - Mean Cache Misses (BG, Z_c): %.1f | Cache Hit Rate (per CB): %.1f%%\n', ...
        misses_med, hit_rate_med);
    
    for a = 1:num_algs
        m_final  = media_agregada(a, ch, end);
        ic_final = ic_95(a, ch, end);
        fprintf('  - %-12s -> Final Mean Latency: %8.3f +- %6.3f ms/frame\n', ...
            algoritmos{a}, m_final, ic_final);
    end
    fprintf('\n');
end

%% 5. IEEE PUBLICATION-GRADE FIGURE GENERATION (LATEX FORMATTING)
fig6 = figure('Name', 'Figure 6 - Dynamic MCS Adaptation Benchmark', ...
              'Units', 'pixels', 'Position', [100, 80, 960, 640], ...
              'Color', 'w', 'InvertHardcopy', 'off');

tlo = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

quadros_zoom = 1:min(100, Nframes);
eixo_q       = 1:Nframes;

% Colorblind-safe academic palette & distinct line styles for B&W print
cores = [0.00, 0.45, 0.74;   % Deep Blue   - Conventional (G)
         0.85, 0.33, 0.10;   % Burnt Orange - Richardson-Urbanke
         0.13, 0.55, 0.13];  % Forest Green - Proposed (Two-Step H)
estilos_linha = {'--', '-.', '-'};

% --- Panel (a): Pedestrian MCS Sequence ---
ax1 = nexttile(tlo, 1);
mcs_ped = arrayfun(@(x) x.TBs(1).MCS, traco_plot{1}(quadros_zoom));
stairs(ax1, quadros_zoom, mcs_ped, 'LineWidth', 1.6, 'Color', cores(1, :));
formatar_eixo_academico(ax1);
ylim(ax1, [0 28]); xlim(ax1, [1 max(quadros_zoom)]);
title(ax1, '\textbf{(a) Pedestrian Scenario: $I_{\mathrm{MCS}}$ Trajectory}', 'Interpreter', 'latex', 'FontSize', 11);
xlabel(ax1, 'NR Frame Index, $n$', 'Interpreter', 'latex', 'FontSize', 10.5);
ylabel(ax1, 'MCS Index, $I_{\mathrm{MCS}}$', 'Interpreter', 'latex', 'FontSize', 10.5);

% --- Panel (b): Vehicular MCS Sequence ---
ax2 = nexttile(tlo, 2);
mcs_vei = arrayfun(@(x) x.TBs(1).MCS, traco_plot{2}(quadros_zoom));
stairs(ax2, quadros_zoom, mcs_vei, 'LineWidth', 1.6, 'Color', cores(1, :));
formatar_eixo_academico(ax2);
ylim(ax2, [0 28]); xlim(ax2, [1 max(quadros_zoom)]);
title(ax2, '\textbf{(b) Vehicular Scenario: $I_{\mathrm{MCS}}$ Trajectory}', 'Interpreter', 'latex', 'FontSize', 11);
xlabel(ax2, 'NR Frame Index, $n$', 'Interpreter', 'latex', 'FontSize', 10.5);
ylabel(ax2, 'MCS Index, $I_{\mathrm{MCS}}$', 'Interpreter', 'latex', 'FontSize', 10.5);

% Y-axis limits for cumulative latency panels
ymin_val = max(1e-2, min(media_agregada(:)) * 0.45);
ymax_val = max(media_agregada(:) + ic_95(:)) * 1.8;

titulos_cd = { ...
    '\textbf{(c) Pedestrian: Cumulative Mean Encoding Latency}', ...
    '\textbf{(d) Vehicular: Cumulative Mean Encoding Latency}' ...
};

% --- Panels (c) and (d): Cumulative Mean Latency + 95% CI Bands ---
for ch = 1:2
    ax = nexttile(tlo, 2 + ch);
    hold(ax, 'on');
    h_lines = zeros(1, num_algs);
    
    for a = 1:num_algs
        curva_m  = reshape(media_agregada(a, ch, :), 1, Nframes);
        curva_ic = reshape(ic_95(a, ch, :), 1, Nframes);
        
        % 95% CI shaded band (clamped for logarithmic scale)
        lim_inf = max(ymin_val * 0.1, curva_m - curva_ic);
        lim_sup = curva_m + curva_ic;
        
        if Nseeds > 1
            fill(ax, [eixo_q, fliplr(eixo_q)], [lim_inf, fliplr(lim_sup)], cores(a, :), ...
                 'FaceAlpha', 0.18, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        end
        
        h_lines(a) = plot(ax, eixo_q, curva_m, 'LineStyle', estilos_linha{a}, ...
                          'LineWidth', 1.9, 'Color', cores(a, :));
    end
    
    set(ax, 'YScale', 'log');
    formatar_eixo_academico(ax);
    ylim(ax, [ymin_val ymax_val]);
    xlim(ax, [1 Nframes]);
    
    title(ax, titulos_cd{ch}, 'Interpreter', 'latex', 'FontSize', 11);
    xlabel(ax, 'Number of Processed Frames, $n$', 'Interpreter', 'latex', 'FontSize', 10.5);
    ylabel(ax, 'Cumulative Mean Latency, $\bar{T}(n)$ [ms]', 'Interpreter', 'latex', 'FontSize', 10.5);
    
    leg = legend(ax, h_lines, alg_labels_latex, 'Location', 'northeast', ...
                 'Interpreter', 'latex', 'FontSize', 9.2);
    set(leg, 'Color', 'w', 'EdgeColor', [0.2 0.2 0.2], 'TextColor', 'k', 'Box', 'on');
end

% Save editable MATLAB figure, Vector PDF (for LaTeX/Overleaf), and 600 DPI PNG
savefig(fig6, 'Figure6_LDPC_Dynamic_MCS.fig');
exportgraphics(fig6, 'Figure6_LDPC_Dynamic_MCS.pdf', 'ContentType', 'vector', 'BackgroundColor', 'white');
exportgraphics(fig6, 'Figure6_LDPC_Dynamic_MCS.png', 'Resolution', 600, 'BackgroundColor', 'white');
fprintf('Figures exported: "Figure6_LDPC_Dynamic_MCS.pdf" (Vector) and ".png" (600 DPI).\n');

%% ========================================================================
%  MODULAR HELPER FUNCTIONS
%  ========================================================================

function formatar_eixo_academico(ax)
    % Enforces IEEE academic style regardless of MATLAB Dark/Light theme
    grid(ax, 'on');
    box(ax, 'on');
    set(ax, 'Color', 'w', ...
            'XColor', 'k', 'YColor', 'k', ...
            'TickLabelInterpreter', 'latex', ...
            'FontSize', 10, ...
            'LineWidth', 0.85, ...
            'TickDir', 'in', ...
            'GridAlpha', 0.25, ...
            'MinorGridAlpha', 0.12, ...
            'GridColor', [0.15 0.15 0.15], ...
            'MinorGridColor', [0.25 0.25 0.25]);
end

function traco = gerar_traco_5gnr(cenario, Nframes, semente)
    if strcmpi(cenario, 'Pedestre')
        rng(1000 + semente);
    else
        rng(5000 + semente);
    end
    
    % 3GPP TS 38.214 - Table 5.1.3.1-1: [MCS, Qm, R_x1024]
    tabela_MCS = [
         0, 2, 120;   1, 2, 157;   2, 2, 193;   3, 2, 251;   4, 2, 308;
         5, 2, 379;   6, 2, 449;   7, 2, 526;   8, 2, 602;   9, 2, 679;
        10, 4, 340;  11, 4, 378;  12, 4, 434;  13, 4, 490;  14, 4, 553;
        15, 4, 616;  16, 4, 658;  17, 6, 438;  18, 6, 466;  19, 6, 517;
        20, 6, 567;  21, 6, 616;  22, 6, 666;  23, 6, 719;  24, 6, 772;
        25, 6, 822;  26, 6, 873;  27, 6, 910;  28, 6, 948
    ];
    
    N_RE_slot = 51 * 12 * 12;
    mcs_atual = 14;
    
    traco = repmat(struct('TBs', []), 1, Nframes);
    
    for f = 1:Nframes
        if strcmpi(cenario, 'Pedestre')
            if mod(f, 25) == 1
                passo = randi([-1, 1]);
                mcs_atual = min(max(mcs_atual + passo, 12), 16);
            end
        else
            mcs_atual = randi([1, 27]);
        end
        
        Qm = tabela_MCS(mcs_atual + 1, 2);
        R  = tabela_MCS(mcs_atual + 1, 3) / 1024;
        
        fator_carga = 0.25 + 0.05 * mod(mcs_atual, 5);
        A = max(120, 8 * round((N_RE_slot * Qm * R * fator_carga) / 8));
        
        % 3GPP TS 38.212 pre-encoding chain
        BGn         = Base_Graph_selector(A, R);
        tb_bits     = randi([0 1], 1, A);
        tb_crc      = crc_generator(tb_bits);
        TB_with_CRC = [tb_bits, tb_crc];
        
        [cbs_raw, C, K_prime, ~] = codeBlockSegmentation(TB_with_CRC, BGn);
        cbs_crc                  = codeblockcrcimplementation(cbs_raw, C);
        [Zc, Kb]                 = Zc_selector(K_prime, BGn);
        
        Kb_max  = 22; if BGn == 2; Kb_max = 10; end
        K_total = Kb_max * Zc;
        cbs_f   = codeBlockFiller(cbs_crc, C, K_total);
        
        tb_struct = struct( ...
            'MCS', mcs_atual, ...
            'Qm',  Qm, ...
            'R',   R, ...
            'A',   A, ...
            'BGn', BGn, ...
            'C',   C, ...
            'Zc',  Zc, ...
            'Kb',  Kb, ...
            'cbs', {cbs_f} ...
        );
        
        traco(f).TBs = tb_struct;
    end
end

function cache = criar_cache_vazio()
    cache = containers.Map('KeyType', 'char', 'ValueType', 'any');
end

function chave = criar_chave_estrutura(tb)
    chave = sprintf('BG%d_Zc%d', tb.BGn, tb.Zc);
end

function flag = cache_contem(cache, chave)
    flag = isKey(cache, chave);
end

function cache = guardar(cache, chave, dados)
    cache(chave) = dados;
end

function dados = consultar(cache, chave)
    dados = cache(chave);
end

function dados = preparar_estrutura(algoritmo, tb)
    [BG_mat, i_ls] = baseGraph_generator(tb.BGn, tb.Zc);
    H_mat          = H_matrix_generator(BG_mat, tb.Zc);
    
    switch algoritmo
        case 'Convencional'
            dados = G_matrix_generator_2(H_mat, tb.Zc);
            
        case 'Richardson'
            dados = ldpc_encode_nr_preprocess(H_mat, tb.Zc);
            
        case 'Proposto'
            dados = H_matrix_codeword_preprocess(H_mat, tb.Zc, tb.BGn, i_ls);
            
        otherwise
            error('Unknown algorithm: %s', algoritmo);
    end
end

function cw = codificar_blocos_do_TB(algoritmo, tb, dados)
    C     = tb.C;
    cbs_f = tb.cbs;
    
    switch algoritmo
        case 'Convencional'
            cw = codeBlockEncoding(cbs_f, C, dados);
            
        case 'Richardson'
            cw = cell(1, C);
            for i = 1:C
                code_block_GF2 = cbs_f{i};
                code_block_GF2(code_block_GF2 == -1) = 0;
                cw{i} = ldpc_encode_nr_process(code_block_GF2, dados);
            end
            
        case 'Proposto'
            cw = cell(1, C);
            for i = 1:C
                code_block_GF2 = cbs_f{i};
                code_block_GF2(code_block_GF2 == -1) = 0;
                cw{i} = H_matrix_codeword_generator_process(code_block_GF2, dados);
            end
    end
end

function validar_fora_do_benchmark(cw, tb, algoritmo)
    if strcmp(algoritmo, 'Richardson')
        return;
    end
    [BG_mat, ~] = baseGraph_generator(tb.BGn, tb.Zc);
    H_mat       = H_matrix_generator(BG_mat, tb.Zc);
    for i = 1:tb.C
        c_vec = double(cw{i}(:));
        if any(mod(H_mat * c_vec, 2) ~= 0)
            error('Syndrome check failed in %s (BG%d, Zc=%d)!', ...
                algoritmo, tb.BGn, tb.Zc);
        end
    end
end