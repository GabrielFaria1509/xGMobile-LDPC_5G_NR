%% =========================================================
% Simulação completa LDPC 5G NR
% Uma transmissão sem HARQ
% MATLAB 5G Toolbox
%
% Transport Block -> LDPC -> Rate Matching -> QPSK
% Canal AWGN -> Decoder LDPC
%
%% =========================================================

clear;
clc;
close all;


%% ============================
% Parâmetros
% =============================

A = 512;            % tamanho da mensagem
R = 1/2;            % taxa desejada
modulation = "QPSK";

Qm = 2;             % bits por símbolo QPSK

EbN0_dB = 3;

maxIter = 25;


%% ============================
% Geração da mensagem
% =============================

txBits = randi([0 1],A,1);


fprintf("\nMensagem original:\n")
disp(txBits(1:20).')


%% ============================
% CRC Transport Block
% =============================

tbCRC = nrCRCEncode(txBits,'24A');


Acrc = length(tbCRC);



%% ============================
% Informações LDPC
% =============================

info = nrDLSCHInfo(Acrc,R);


disp(info)



%% ============================
% Code Block Segmentation
% =============================

cbs = nrCodeBlockSegmentLDPC(tbCRC,...
                             info.BGN);



%% ============================
% LDPC Encoder
% =============================

coded = nrLDPCEncode(cbs,...
                     info.BGN);



% tamanho antes do rate matching

N_ldpc = numel(coded);


fprintf("\nBits LDPC: %d\n",N_ldpc)



%% ============================
% Rate Matching NR
% =============================

E = ceil(A/R);       % bits transmitidos


rv = 0;              % primeira transmissão

mod = 2;             % QPSK
nlayers = 1;


rmBits = nrRateMatchLDPC(coded,...
                         E,...
                         rv,...
                         mod,...
                         nlayers);


fprintf("Bits após Rate Matching: %d\n",length(rmBits))



%% ============================
% Modulação QPSK
% =============================

rmBits = double(rmBits(:));


symbols = nrSymbolModulate(rmBits,...
                           modulation);



%% ============================
% Canal AWGN
% =============================


EbN0 = 10^(EbN0_dB/10);


sigma = sqrt(1/(2*R*Qm*EbN0));


noise = sigma/sqrt(2) * ...
        (randn(size(symbols))+...
        1i*randn(size(symbols)));


rxSymbols = symbols + noise;



%% ============================
% Demodulação Soft
% =============================


rxLLR = nrSymbolDemodulate(rxSymbols,...
                           modulation,...
                           sigma^2);



%% ============================
% Rate Recovery
% =============================

rxRecovered = nrRateRecoverLDPC(rxLLR,...
                                Acrc,...
                                R,...
                                rv,...
                                mod,...
                                nlayers,...
                                info.BGN);


%% ============================
% Decoder LDPC
% =============================


rxRecovered = reshape(rxRecovered,...
                      size(coded));


decoded = nrLDPCDecode(rxRecovered,...
                       info.BGN,...
                       maxIter);



%% ============================
% Code Block Desegmentação
% =============================


rxTB = nrCodeBlockDesegmentLDPC(decoded,...
                                info.BGN,...
                                Acrc);



%% ============================
% Remoção CRC
% =============================


[rxBits,crcError] = nrCRCDecode(rxTB,...
                                '24A');



%% ============================
% BER
% =============================

BER = sum(rxBits ~= txBits)/A;



fprintf("\n=====================\n")
fprintf("RESULTADO\n")
fprintf("=====================\n")

fprintf("Eb/N0 = %.2f dB\n",EbN0_dB)

fprintf("BER = %.5e\n",BER)


if crcError == 0
    fprintf("CRC OK\n")
else
    fprintf("CRC FALHOU\n")
end



%% ============================
% Visualização
% =============================


figure

subplot(2,1,1)

stem(txBits(1:50),'filled')
ylim([-0.2 1.2])
grid on
title("Bits transmitidos")


subplot(2,1,2)

stem(rxBits(1:50),'filled')
ylim([-0.2 1.2])
grid on
title("Bits recuperados")

