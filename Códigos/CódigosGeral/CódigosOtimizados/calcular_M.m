clc;
clear;
close all;

%% ABRIR FIGURAS

fig_Tpre = openfig('grafico_comparativo_pre_apenas.fig', 'invisible');
fig_t = openfig('grafico_comparativo_prepro.fig', 'invisible');

ax_Tpre = findobj(fig_Tpre, 'Type', 'axes');
ax_t = findobj(fig_t, 'Type', 'axes');

%% EXTRAIR DADOS PELO NOME DA LEGENDA

curvas_Tpre = findobj(ax_Tpre, 'Type', 'line');
curvas_t = findobj(ax_t, 'Type', 'line');

nomes_Tpre = get(curvas_Tpre, 'DisplayName');
nomes_t = get(curvas_t, 'DisplayName');

disp('Curvas do gráfico Tpre:');
disp(nomes_Tpre);

disp('Curvas do gráfico t:');
disp(nomes_t);

%% EXTRAIR VETORES

% Pré-processamento
idx_A = find(strcmp(nomes_Tpre, 'Richardson'));
idx_B = find(strcmp(nomes_Tpre, 'Proposto'));

assert(numel(idx_A) == 1 && numel(idx_B) == 1, ...
    'Não foi possível identificar as curvas de Tpre.');

Tpre_A = curvas_Tpre(idx_A).YData(:);
Tpre_B = curvas_Tpre(idx_B).YData(:);

Zc = curvas_Tpre(idx_A).XData(:);

% Tempo de execução
idx_A = find(strcmp(nomes_t, 'Richardson'));
idx_B = find(strcmp(nomes_t, 'Proposto'));

assert(numel(idx_A) == 1 && numel(idx_B) == 1, ...
    'Não foi possível identificar as curvas de t.');

t_A = curvas_t(idx_A).YData(:);
t_B = curvas_t(idx_B).YData(:);

%% VERIFICAR DIMENSÕES

assert(isequal(Zc, curvas_Tpre(idx_B).XData(:)), ...
    'Os valores de Zc do pré-processamento são diferentes.');

assert(isequal(Zc, curvas_t(idx_A).XData(:)), ...
    'Os valores de Zc dos gráficos são diferentes.');

assert(isequal(Zc, curvas_t(idx_B).XData(:)), ...
    'Os valores de Zc dos gráficos são diferentes.');

assert(numel(Zc) == numel(Tpre_A) && ...
       numel(Zc) == numel(Tpre_B) && ...
       numel(Zc) == numel(t_A) && ...
       numel(Zc) == numel(t_B), ...
       'Os vetores possuem tamanhos diferentes.');

%% CALCULAR PONTO DE EQUILÍBRIO

delta_Tpre = Tpre_B - Tpre_A;
delta_t = t_A - t_B;

N_eq = nan(size(Zc));

validos = (delta_Tpre .* delta_t > 0) & (delta_t ~= 0);

N_eq(validos) = delta_Tpre(validos) ./ delta_t(validos);

% Primeira execução inteira em que Richardson supera o Proposto
N_vantagem = nan(size(Zc));

N_vantagem(validos) = floor(N_eq(validos)) + 1;

%% RESULTADOS

Resultados = table( ...
    Zc, Tpre_A, Tpre_B, t_A, t_B, N_eq, N_vantagem, ...
    'VariableNames', ...
    {'Zc', 'Tpre_Richardson', 'Tpre_Proposto', ...
    't_Richardson', 't_Proposto', ...
    'N_equilibrio', 'N_vantagem_Richardson'});

disp(Resultados);

%% SALVAR RESULTADOS

writetable(Resultados, 'comparacao_algoritmos.xlsx');

%% GERAR GRÁFICO

fig = figure;

plot(Zc, N_vantagem, '-o', ...
    'LineWidth', 1.8, ...
    'MarkerSize', 6, ...
    'Color', [0 0.35 0.75], ...
    'MarkerFaceColor', [0 0.35 0.75]);

ax = gca;

% Fundo branco
set(fig, 'Color', 'w');
set(ax, 'Color', 'w');

% Eixos pretos
set(ax, 'XColor', 'k');
set(ax, 'YColor', 'k');

% Grid cinza escuro
grid on;
set(ax, 'GridColor', [0.3 0.3 0.3]);
set(ax, 'MinorGridColor', [0.5 0.5 0.5]);

% Título e rótulos
title('Número de execuções para equilíbrio', 'Color', 'k');
xlabel('Z_c', 'Color', 'k');
ylabel('Número de execuções', 'Color', 'k');

% Legenda
lgd = legend('Ponto de equilíbrio', ...
    'Location', 'northwest');

set(lgd, ...
    'Color', 'w', ...
    'TextColor', 'k', ...
    'Location', 'northwest', ...
    'EdgeColor', [0.3 0.3 0.3]);

% Escalas lineares
set(ax, 'XScale', 'linear');
set(ax, 'YScale', 'linear');

% Limites dos eixos
xlim(ax, [0 max(Zc)]);
ylim(ax, [0 inf]);

% Área quadrada
axis(ax, 'square');

% Tamanho da figura
set(fig, 'Position', [100 100 600 600]);

%% SALVAR FIGURA

savefig(fig, 'grafico_equilibrio.fig');

exportgraphics(fig, 'grafico_equilibrio.png', ...
    'Resolution', 300, ...
    'BackgroundColor', 'white');

%% FECHAR FIGURAS ORIGINAIS

close(fig_Tpre);
close(fig_t);