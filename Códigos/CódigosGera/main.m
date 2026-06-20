%% ========================================================================
%% SIMULADOR 5G LDPC - xGMobile (Integração Completa)
%% ========================================================================
% Este script orquestra a comunicação entre o Transmissor e o Receptor,
% simulando o envio de pacotes, a ação do ruído e as retransmissões HARQ.
clear;close all;

% Adiciona todas as subpastas (Transmissor, Receptor, etc.) ao path do MATLAB
% IMPORTANTE: Certifique-se de que o "Current Folder" do MATLAB é a pasta 'CódigosGera'
addpath(genpath(pwd));

%%%% 1. PARÂMETROS DO SISTEMA
R = 1/2;           % Taxa de Código Alvo (Code Rate)
E = 250;           % Recursos físicos máximo(Maximal physical resource)
Q_m = 2;           % Ordem de Modulação (2 = QPSK)
SNR_dB = -2;       % Relação Sinal-Ruído(Relação Sinal-Ruído)

fprintf('\n======================================================\n');
fprintf('--- INICIANDO SIMULAÇÃO 5G xGMobile ---\n');

A = input("Digite o tamanho da mensagem a ser enviada : "); % Tamanho da mensagem original (bits)
msg_original = message_generator(A);
disp("Mensagem gerada : ")
disp(msg_original);

fprintf('\n[TX] Transmitindo pacotes (Gerando os  RV simultaneamente)...\n');
[rx_1, rx_2, rx_3, rx_4, BG, Zc, B, c, H] = transmitter(msg_original, R, E, Q_m, SNR_dB);

sucesso = false;

buffer_harq = -1;

for attempt = 1 : 4
    fprintf('\n-> Iniciando Recepção - Tentativa %d (HARQ)...\n', attempt);

    if attempt == 1
        sinal_recebido = rx_1; % Tenta decodificar o RV=0 primeiro
    elseif attempt == 2
        sinal_recebido = rx_2; % Puxa o RV=2 que estava guardado
    elseif attempt == 3
        sinal_recebido = rx_3; % Puxa o RV=3
    else
        sinal_recebido = rx_4; % Puxa o RV=1
    end

    fprintf('   [Demodulador] Calculando as probabilidades LLR...\n');
    llrs_canal = ReceiverEntry(sinal_recebido, Q_m, SNR_dB);

    fprintf('   [De-Rate Matching] Reconstruindo Buffer Circular...\n');

    buffer_harq = derate_matching(llrs_canal, BG, Zc, Q_m, B, attempt, buffer_harq);

    fprintf('   [LDPC] Rodando Decodificador Min-Sum...\n');
    I_max = 50;
    palavra_recuperada_LDPC = sum_product_decoding(H,buffer_harq,I_max);

    mensagem_recuperada = palavra_recuperada_LDPC(1:A);

    erros = sum(msg_original(:) ~= mensagem_recuperada(:));

    if erros == 0
        fprintf('\n   [✅ SUCESSO] Mensagem recuperada PERFEITAMENTE na tentativa %d!\n', attempt);
        sucesso = true;
        display(mensagem_recuperada);
        break;
    else
         fprintf('   [❌ FALHA] Foram encontrados %d bits errados.\n', erros);
         if attempt < 4
             fprintf('[!] Acionando retransmissão HARQ automática para a tentativa %d...\n',attempt + 1);
         end
    end
end

if ~sucesso
    fprintf('Pacote PERDIDO mesmo após HARQ. \n--- DICA: O canal está muito ruidoso. Tente aumentar o SNR.\n');
else
    fprintf('Comunicação estabelcida com sucesso')
end



