%% ========================================================================
%% SIMULADOR 5G LDPC - xGMobile (TESTE DO TRANSMISSOR)
%% ========================================================================
clear; close all; clc;

% Adiciona todas as subpastas (Transmissor, Receptor, etc.) ao path do MATLAB
addpath(genpath(pwd));

%%%% 1. PARÂMETROS DO SISTEMA
R = 1/2;           % Taxa de Código Alvo (Code Rate)
E = 15000;         
Q_m = 4;           % Ordem de Modulação (2 = QPSK)
SNR_dB = 5;       % Relação Sinal-Ruído 

fprintf('\n======================================================\n');
fprintf('--- TESTE DE PIPELINE: TRANSMISSOR 5G xGMobile ---\n');
fprintf('======================================================\n');

% DICA DE TESTE: 
% Digite 1000 para ver como ele processa 1 bloco só (C = 1).
% Digite 10000 para forçar a segmentação e ver ele dividir em blocos (C > 1).
A = input("Digite o tamanho da mensagem a ser enviada (em bits): "); 


msg_original = message_generator(A);

fprintf('\n[TX] Processando pipeline (Segmentação, CRC, Filler, LDPC, Rate Matching)...\n');


[rx_1, rx_2, rx_3, rx_4, C, BG, Zc, B, H] = transmitterteste(msg_original, R, E, Q_m, SNR_dB);

%% ========================================================================
%% TRANSMISSOR
%% ========================================================================
fprintf('\n================ RELATÓRIO DO TRANSMISSOR ================\n');
fprintf('Tamanho da carga útil (A)        : %d bits\n', A);
fprintf('Tamanho com CRC de Transporte (B): %d bits\n', B);
fprintf('Grafo Base Selecionado (BG)      : %d\n', BG);
fprintf('Fator de Expansão (Zc)           : %d\n', Zc);
fprintf('----------------------------------------------------------\n');
fprintf('>>> NÚMERO DE BLOCOS (C)         : %d bloco(s)\n', C);
fprintf('----------------------------------------------------------\n');
fprintf('Recursos Físicos Alocados (E)    : %d bits no canal\n', E);
fprintf('Tamanho do sinal transmitido     : %d símbolos (por RV)\n', length(rx_1));

% Validação matemática rápida: O sinal modulado deve ter tamanho igual a E / Q_m
tamanho_esperado = E / Q_m;
if length(rx_1) == floor(tamanho_esperado) || length(rx_1) == ceil(tamanho_esperado)
    fprintf('[✅ SUCESSO] O Rate Matching e a Modulação alinharam perfeitamente com os recursos (E)!\n');
else
    fprintf('[❌ ALERTA] O tamanho gerado (%d) não bate com o esperado (%d).\n', length(rx_1), tamanho_esperado);
    fprintf('==========================================================\n');
end




