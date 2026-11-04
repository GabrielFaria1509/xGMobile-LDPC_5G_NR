%G = openfig('tempo_codificacao_LDPC_G_prepro.fig');
I = openfig('tempo_codificacao_LDPC_internet_pre_apenas.fig');
P = openfig('tempo_codificacao_LDPC_proposto_pre_apenas.fig');

% Selecionar os eixos
%axG = findobj(G, 'Type', 'axes');
axI = findobj(I, 'Type', 'axes');
axP = findobj(P, 'Type', 'axes');

% Encontrar as curvas
%curvasG = findobj(axG, 'Type', 'line');
curvasI = findobj(axI, 'Type', 'line');
curvasP = findobj(axP, 'Type', 'line');

% Definir cores
%corG = [0 0.4470 0.7410];    % Azul
corI = [0.8500 0.3250 0.0980]; % Vermelho
corP = [0.4660 0.6740 0.1880]; % Verde

% Configurar curva I
set(curvasI, 'Color', corI, 'DisplayName', 'Richardson');

% Copiar e configurar curva G
%novasG = copyobj(curvasG, axI);
%set(novasG, 'Color', corG, 'DisplayName', 'G tradicional');

% Copiar e configurar curva P
novasP = copyobj(curvasP, axI);
set(novasP, 'Color', corP, 'DisplayName', 'Proposto');

% Configurar gráfico
set(axI, 'YScale', 'log');
title(axI, 'Tempo de codificação do pré-processamento');
xlabel(axI, 'Zc');
ylabel(axI, 'Tempo (s)');
grid(axI, 'on');
legend(axI, 'show', 'Location', 'best');

% Salvar
savefig(I, 'grafico_comparativo_pre_apenas.fig');

% Abrir resultado
openfig('grafico_comparativo_pre_apenas.fig');