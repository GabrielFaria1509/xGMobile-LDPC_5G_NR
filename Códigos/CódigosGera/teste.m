%% ========================================================================
%% SIMULADOR 5G NR - LDPC TRANSCEIVER (Projeto xGMobile - Inatel)
%% ========================================================================
clear; clc; close all;

%% 1. PARÂMETROS GERAIS DO SISTEMA
% Você pode brincar com esses valores depois para testar o limite do canal
A = 1000;          % Tamanho da mensagem original (bits)
R = 1/3;           % Taxa de código (Code Rate)
E = 15000;         % Tamanho total de recursos após Rate Matching (bits)
Q_m = 2;           % Ordem de modulação (2 = QPSK)
SNR_dB = 5;        % Relação Sinal-Ruído no canal (Tente baixar para forçar o HARQ)

fprintf('==========================================================\n');
fprintf(' Iniciando Simulação 5G NR LDPC \n');
fprintf(' Tamanho da Mensagem (A) : %d bits\n', A);
fprintf(' Modulação (Q_m)         : %d\n', Q_m);
fprintf(' SNR                     : %d dB\n', SNR_dB);
fprintf('==========================================================\n');

%% 2. GERAÇÃO DA MENSAGEM ORIGINAL
msg_original = message_generator(A);

%% 3. TRANSMISSOR E CANAL (Pipeline)
fprintf('\n[TX] Processando Transmissor...\n');
% O transmitterteste já faz a codificação, modulação e adição de ruído (via SNR)
[rx_1, rx_2, rx_3, rx_4, C, BG, Zc, B, H] = transmitterteste(msg_original, R, E, Q_m, SNR_dB);

fprintf('[TX] Transmissão concluída. Parâmetros reais extraídos:\n');
fprintf('     -> Blocos (C) : %d\n', C);
fprintf('     -> Base Graph : %d\n', BG);
fprintf('     -> Zc         : %d\n', Zc);

%% 4. RECEPÇÃO, DECODIFICAÇÃO E HARQ
fprintf('\n[RX] Iniciando o processamento do Receptor (HARQ)...\n');
harq_transmissions = {rx_1, rx_2, rx_3, rx_4};

% Define o tipo de CRC de Transporte baseado no tamanho original A
if A > 3824
    tipo_crc = "24A"; 
else
    tipo_crc = "16"; 
end

% Extrai o tamanho de cada bloco (K_perblock) usando a segmentação com o BG correto
[~, ~, K_perblock, ~] = codeBlockSegmentation(zeros(1, B), BG); 
if C > 1
    L = 24; % 24 bits de CRC por bloco
else
    L = 0;  % Sem CRC extra se for apenas 1 bloco
end
K_actual = ceil(B / C) + L;


harq_buffer = -1; 
max_iter = 50;
sucesso_absoluto = false;

%% ================= O LAÇO DO HARQ =================
for attempt = 1 : 4
    fprintf('\n--- INICIANDO TENTATIVA %d/4 (RV %d) ---\n', attempt, attempt);
    
    rx_signal = harq_transmissions{attempt};
    rx_llr = ReceiverEntry(rx_signal, Q_m, SNR_dB);
    
    % Execução Condicional do Buffer (Ativa o nargin < 9 na tentativa 1)
    if attempt == 1
        dematched_blocks = codeBlockRateDematching(rx_llr, C, E, BG, Zc, Q_m, K_actual, attempt);
    else
        dematched_blocks = codeBlockRateDematching(rx_llr, C, E, BG, Zc, Q_m, K_actual, attempt, harq_buffer);
    end
    
    harq_buffer = dematched_blocks; % Armazena os blocos processados para o soft-combining
    
    % Decodificação de Canal LDPC 
    decoded_blocks = codeBlockDecoding(dematched_blocks, C, K_perblock, H, max_iter);
    
    % Dessegmentação e Validação do CRC-24B (Por Bloco)
    [msg_rx_crc, crc_cb_pass] = codeBlockDesegmentation(decoded_blocks, C, B);
    
    % Separação do Payload e Validação do CRC de Transporte (24A ou 16)
    mensagem_recebida = msg_rx_crc(1 : A);
    crc_recebido      = msg_rx_crc(A + 1 : end);
    crc_calculado     = crc_generator(mensagem_recebida, tipo_crc);
    
    % --- CHECAGEM FINAL DE INTEGRIDADE ---
    if isequal(crc_recebido(:).', crc_calculado(:).')
        fprintf('[✅ SUCESSO] CRC de Transporte (%s) Válido na tentativa %d!\n', tipo_crc, attempt);
        
        erros_reais = sum(msg_original(:) ~= mensagem_recebida(:));
        if erros_reais == 0
            fprintf('[🌟 SUCESSO ABSOLUTO] Mensagem recuperada com 0 bits de erro!\n');
            sucesso_absoluto = true;
            break; 
        else
            fprintf('[⚠️ ALERTA] CRC passou, mas a mensagem tem %d bits divergentes (Falso Positivo).\n', erros_reais);
        end
    else
        num_erros = sum(mensagem_recebida(:) ~= msg_original(:));
        fprintf('[❌ FALHA] CRC Inválido. Bits incorretos na tentativa %d: %d bits.\n', attempt, num_erros);
    end
end

if ~sucesso_absoluto
    fprintf('\n[💀 FALHA CRÍTICA] Não foi possível recuperar o pacote após 4 transmissões.\n');
end
fprintf('==========================================================\n');