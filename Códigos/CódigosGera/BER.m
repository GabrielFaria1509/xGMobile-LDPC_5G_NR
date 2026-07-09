clear;close all;

% Adiciona todas as subpastas (Transmissor, Receptor, etc.) ao path do MATLAB
% IMPORTANTE: Certifique-se de que o "Current Folder" do MATLAB é a pasta 'CódigosGera'
addpath(genpath(pwd));


%%%% 1. PARÂMETROS DO SISTEMA
R = 1/2;           % Taxa de Código Alvo (Code Rate)
E = 250;           % Recursos físicos máximo(Maximal physical resource)
Q_m = 2;           % Ordem de Modulação (2 = QPSK)
A = 200;           % Tamanho da mesnsagem
SNR_dB_vector = 0:0.5:7;     % Relação Sinal-Ruído(Relação Sinal-Ruído)

I_max = 20;
BER_Totais = zeros(1,length(SNR_dB_vector));

%gerando matriz G para economixar tempo
message = message_generator(A);
CRC = crc_generator(A);
msg_crc = [message, CRC];
B = A + length(CRC);
BG_number = Base_Graph_selector(A, R);
Zc = Zc_selector(B,BG_number);
BG = baseGraph_generator(BG_number, Zc);
H = H_matrix_generator(BG, Zc);
G = G_matrix_generator_2(H,Zc);
        
for k = 1:length(SNR_dB_vector)
    SNR_dB = SNR_dB_vector(k);
    errosTotais = 0;
    bitsTotais = 0;

    while bitsTotais<600
        % gera mensagem
        msg_original = message_generator(A);

        [rx_1, rx_2, rx_3, rx_4, BG, Zc, B, c, H] = transmitter_BER(msg_original, E, Q_m, SNR_dB, BG_number, Zc, H, G);

        sucesso = false;
        
        buffer_harq = -1;

        erros = 0;
        
        for attempt = 1 : 4
            if attempt == 1
                sinal_recebido = rx_1; % Tenta decodificar o RV=0 primeiro
            elseif attempt == 2
                sinal_recebido = rx_2; % Puxa o RV=2 que estava guardado
            elseif attempt == 3
                sinal_recebido = rx_3; % Puxa o RV=3
            else
                sinal_recebido = rx_4; % Puxa o RV=1
            end

            llrs_canal = ReceiverEntry(sinal_recebido, Q_m, SNR_dB);
            buffer_harq = derate_matching(llrs_canal, BG, Zc, Q_m, B, attempt, buffer_harq);
            palavra_recuperada_LDPC = sum_product_decoding(H,buffer_harq,I_max);
            mensagem_recuperada = palavra_recuperada_LDPC(1:A);
            erros = sum(msg_original(:) ~= mensagem_recuperada(:));
        
            if erros == 0
                sucesso = true;
                break;
            end
        end

        % conta erros
        errosTotais = errosTotais + erros;
        bitsTotais = bitsTotais + A

    end

    BER_Totais(k)=errosTotais/bitsTotais;

end
BER_Totais(BER_Totais == 0) = 1e-1;   % ou 1e-10

BER_Totais

figure
semilogy(SNR_dB_vector, BER_Totais, '-o', ...
    'LineWidth', 2, ...
    'MarkerSize', 8);

grid on
grid minor

xlabel('SNR (dB)', 'FontSize', 12)
ylabel('BER', 'FontSize', 12)
title('Curva BER x SNR', 'FontSize', 14)

set(gca, 'FontSize', 11)
xlim([min(SNR_dB_vector) max(SNR_dB_vector)])

% Ajuste o eixo Y conforme seus dados
ylim([1e-1 1])