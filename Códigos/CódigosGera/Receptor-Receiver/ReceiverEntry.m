function demodulated_signal = ReceiverEntry(rx_signal,Qm,SNR)


%%Recovering the SNR 
E = 1;
SNR_L = 10^(SNR/10);
sigma  = sqrt(E/(2*SNR_L));


%%Variancy is the sqaure of the standard deviation
%%The standard deviation is called sigma,we must multiply by 2 since we
%%have the real axis and the imaginiry axis
variancy_noise = 2*(sigma^2);

%%extracting llr - soft decision

demodulated_signal_matrix = qamdemod(rx_signal,2^Qm,...
    "UnitAveragePower",true,...
    "OutputType","llr",...
    "NoiseVariance",variancy_noise);

%%Flattening the matrix into a row vector
demodulated_signal = demodulated_signal_matrix(:).';



