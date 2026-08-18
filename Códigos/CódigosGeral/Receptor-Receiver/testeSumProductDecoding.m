% =========================================================================
% Script de Teste Min-Sum Decoding Decoding (Baseado no Exemplo 2.5 da Apostila)
% =========================================================================
clc; clear;
% Limite de iterações definido na apostila
max_iter = 60;

disp('======================================================');
disp(' TESTE - Sum-Product Decoding');
disp('======================================================');

%%demodulando a palavra 
sinal_demodulado = ReceiverEntry(rx_signal,Qm,SNR);

%%Desfaz o rate matching
r = derate_matching(sinal_demodulado,Bg_number,Zc,Q_m,B,attempt,buffer);

I_max  = 60;

decodifie_word = sum_product_decoding(H,r,I_max);



