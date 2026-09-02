clear; clc;

% Adiciona todas as subpastas (Transmissor, Receptor, etc.) ao path do MATLAB
% IMPORTANTE: Certifique-se de que o "Current Folder" do MATLAB é a pasta 'CódigosGera'
%addpath(genpath(pwd));


%%%% 1. PARÂMETROS DO SISTEMA
R = 1/2;           % Taxa de Código Alvo (Code Rate)
Q_m = 2;           % Ordem de Modulação (2 = QPSK)
A = 500;           % Tamanho da mesnsagem
EbN0_dB_vector = 2:0.5:6;     % Relação Sinal-Ruído(Relação Sinal-Ruído)

I_max = 10;      %Iterações máximas do Min-Sum
minErros = 300;       % mínimo de erros desejado
minBlocos = 100;       % mínimo de blocos simulados
maxBlocos = 1000;    % limite máximo de blocos
E = 1000;              % Recursos físicos máximo(Maximal physical resource)


HARQ = 1;           % Limite de chamadas HARQ

R_eff = A/E;

BER_Totais = zeros(1,length(EbN0_dB_vector));
BLER_Totais = zeros(1,length(EbN0_dB_vector));

%gerando matriz G para economizar tempo
message = message_generator(A);
CRC = crc_generator(A);
B = A + length(CRC);
BG_number = Base_Graph_selector(A, R);
Zc = Zc_selector(B,BG_number);
BG = baseGraph_generator(BG_number, Zc);

H = H_matrix_generator(BG, Zc);
G = G_matrix_generator_2(H,Zc);
[B_graph,A_graph] = ldpc_graph_generator(H);

Kb = (BG_number == 1)*22 + (BG_number == 2)*10;
Kcb = Kb*Zc;

K_eff = size(G,1);

       
                            
for k = 1:length(EbN0_dB_vector)
    SNR_dB = EbN0_dB_vector(k);
    errosTotais = 0;
    bitsTotais = 0;
    blocosErradosTotais = 0;
    blocosTotais = 0;

    blocos = 0;
    while ((errosTotais < minErros) || (blocos < minBlocos)) && (blocos < maxBlocos)
        blocos = blocos + 1;

        % gera mensagem
        msg_original = message_generator(A);

        % Passagem geral do transmitter
        A = length(msg_original);
        TB_CRC = crc_generator(msg_original);
        TB_with_CRC = [msg_original, TB_CRC];
        B = A + length(TB_CRC);
        code_block_with_filler = filler_bits(TB_with_CRC, Kcb);
        codeword = codeword_generator(code_block_with_filler, G);

        rate_matched_RV1 = RateMatching(codeword, BG_number, Zc, E, Q_m, 1);
        rate_matched_RV2 = RateMatching(codeword, BG_number, Zc, E, Q_m, 2);
        rate_matched_RV3 = RateMatching(codeword, BG_number, Zc, E, Q_m, 3);
        rate_matched_RV4 = RateMatching(codeword, BG_number, Zc, E, Q_m, 4);

        rx_1 = ModulatorProcess(rate_matched_RV1, Q_m, SNR_dB, R_eff);
        rx_2 = ModulatorProcess(rate_matched_RV2, Q_m, SNR_dB, R_eff);
        rx_3 = ModulatorProcess(rate_matched_RV3, Q_m, SNR_dB, R_eff);
        rx_4 = ModulatorProcess(rate_matched_RV4, Q_m, SNR_dB, R_eff);

        buffer_harq = -1;
        erros = 0;
        
        for attempt = 1 : HARQ
            if attempt == 1
                sinal_recebido = rx_1; % Tenta decodificar o RV=0 primeiro
            elseif attempt == 2
                sinal_recebido = rx_2; % Puxa o RV=2 que estava guardado
            elseif attempt == 3
                sinal_recebido = rx_3; % Puxa o RV=3
            else
                sinal_recebido = rx_4; % Puxa o RV=1
            end

            llrs_canal = ReceiverEntry(sinal_recebido, Q_m, SNR_dB,R_eff);
            buffer_harq = derate_matching(llrs_canal, BG_number, Zc, Q_m, B, attempt, buffer_harq);
            palavra_recuperada_LDPC = ldpc_nmsa_decoder(H,buffer_harq,I_max,B_graph,A_graph);
            mensagem_recuperada = palavra_recuperada_LDPC(1:A);
            erros = sum(msg_original(:) ~= mensagem_recuperada(:));
        
            if erros == 0
                break;
            end
        end

        % conta erros para o BER
        errosTotais = errosTotais + erros;
        bitsTotais = bitsTotais + A;

        % conta erros para o BLER
        if erros > 0
            blocosErradosTotais = blocosErradosTotais + 1;
        end
        blocosTotais = blocosTotais + 1;

        fprintf(['SNR = %.1f dB | Frame = %4d | ' ...
             'Erros = %4d | BER = %.3e | ' ...
             'BlocosErrados = %4d | BLER = %.3e\n'], ...
             SNR_dB, blocos, errosTotais, errosTotais/bitsTotais, ...
             blocosErradosTotais, blocosErradosTotais/blocosTotais);

    end

    
    BER_Totais(k) = errosTotais/bitsTotais;
    BLER_Totais(k) = blocosErradosTotais/blocosTotais;

    fprintf('\n---------------------------------------\n');
    fprintf('SNR %.1f dB finalizada\n',SNR_dB);
    fprintf('Blocos simulados : %d\n',blocos);
    fprintf('BLER             : %.3e\n',BLER_Totais(k));
    fprintf('Bits simulados   : %d\n',bitsTotais);
    fprintf('BER              : %.3e\n',BER_Totais(k));
    fprintf('---------------------------------------\n\n');

end
BER_Totais(BER_Totais<1/(maxBlocos*A)) = 1/(maxBlocos*A)
BLER_Totais(BLER_Totais<1/(maxBlocos)) = 1/(maxBlocos)

% Gerando a curva BER
figure
semilogy(EbN0_dB_vector, BER_Totais, '-o', ...
    'LineWidth', 2, ...
    'MarkerSize', 8);

grid on
grid minor

xlabel('SNR (dB)', 'FontSize', 12)
ylabel('BER', 'FontSize', 12)
title('Curva BER x SNR', 'FontSize', 14)

set(gca, 'FontSize', 11)
xlim([0 max(EbN0_dB_vector)+1])

% Ajuste o eixo Y conforme seus dados
ymin = min(BER_Totais);

ylim([ymin 1]);

% Salvando a curva BER
pasta = 'C:\Users\zepte\Documents\xGMobile\GitHub\XGMoblie\Resultados';
if ~exist(pasta, 'dir')
    mkdir(pasta);
end

nome = sprintf('BER_R(%.2f)_E(%d)_Qm(%d)_A(%d)_IMax(%d)_Erros(%d)_HARQ(%d).fig', ...
    R, E, Q_m, A, I_max, minErros, HARQ);

arquivo = fullfile(pasta, nome);
savefig(gcf, arquivo);




%Gerando a curva BLER
figure
semilogy(EbN0_dB_vector, BLER_Totais, '-o', ...
    'LineWidth', 2, ...
    'MarkerSize', 8);

grid on
grid minor

xlabel('SNR (dB)', 'FontSize', 12)
ylabel('BLER', 'FontSize', 12)
title('Curva BLER x SNR', 'FontSize', 14)

set(gca, 'FontSize', 11)
xlim([0 max(EbN0_dB_vector)+1])

% Ajuste o eixo Y conforme seus dados
ymin = min(BLER_Totais);

ylim([ymin 1e-1]);

% Salvando a curva BLER
pasta = 'C:\Users\zepte\Documents\xGMobile\GitHub\XGMoblie\Resultados\BLER';
if ~exist(pasta, 'dir')
    mkdir(pasta);
end

nome = sprintf('BLER_R(%.2f)_E(%d)_Qm(%d)_A(%d)_IMax(%d)_Erros(%d)_HARQ(%d).fig', ...
    R, E, Q_m, A, I_max, minErros, HARQ);

arquivo = fullfile(pasta, nome);
savefig(gcf, arquivo);