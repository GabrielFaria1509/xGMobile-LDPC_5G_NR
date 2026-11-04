% Obter figura e eixos atuais
fig = gcf;
ax = gca;

% Fundo branco
set(fig, 'Color', 'w');
set(ax, 'Color', 'w');

% Eixos pretos
set(ax, 'XColor', 'k');
set(ax, 'YColor', 'k');

% Grid cinza escuro
set(ax, 'GridColor', [0.3 0.3 0.3]);
set(ax, 'MinorGridColor', [0.5 0.5 0.5]);

% Título preto
set(ax.Title, 'Color', 'k');

% Legenda
lgd = legend;
set(lgd, ...
    'Color', 'w', ...
    'TextColor', 'k', ...
    'Location', 'northwest', ...
    'EdgeColor', [0.3 0.3 0.3]);

% Dimensões da figura
set(fig, 'Position', [100 100 600 600]);

% Garantir escalas corretas
set(ax, 'XScale', 'linear');
set(ax, 'YScale', 'log');

% Identificar curvas
linhas = findobj(ax, 'Type', 'line');

% Encontrar limites dos dados
xMax = -inf;
yMin = inf;
yMax = -inf;

for k = 1:length(linhas)
    x = linhas(k).XData;
    y = linhas(k).YData;

    xMax = max(xMax, max(x));

    yValidos = y(y > 0 & isfinite(y));

    if ~isempty(yValidos)
        yMin = min(yMin, min(yValidos));
        yMax = max(yMax, max(yValidos));
    end
end

% Eixo X: zero até o último valor
xlim(ax, [0 xMax]);

% Proporção quadrada
axis(ax, 'square');
drawnow;

% Calcular limite superior de Y considerando escala log
p = ax.Position;

xRange = diff(ax.XLim);
yRange = xRange * p(3) / p(4);

yMaxQuadrado = yMin * 10^yRange;

% Aplicar limites
ylim(ax, [yMin yMaxQuadrado]);

% Exportar PNG
exportgraphics(fig, 'grafico.png', ...
    'Resolution', 300, ...
    'BackgroundColor', 'white');