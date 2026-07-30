function demodulated_signal = ReceiverEntry(rx_signal,Q_m,EbN0_dB,R)

    %% Recovering noise parameters from SNR

    sigma = sqrt(1./(2*R*Q_m*10.^(EbN0_dB/10)));


    %% Noise variance calculation
    % The standard deviation is represented by sigma.
    % Since the signal has real and imaginary components, the variance
    % must consider both axes.

    noise_variance = 2*(sigma^2);


    %% LLR extraction - Soft Decision Demodulation

    demodulated_signal_matrix = qamdemod(rx_signal,2^Q_m,...
        "UnitAveragePower",true,...
        "OutputType","llr",...
        "NoiseVariance",noise_variance);


    %% Flattening the matrix into a row vector

    demodulated_signal = demodulated_signal_matrix(:).';


    % 1. Limit maximum confidence to avoid Inf values and decoder overflow

    LLR_MAX = 50;

    demodulated_signal(demodulated_signal > LLR_MAX) = LLR_MAX;

    demodulated_signal(demodulated_signal < -LLR_MAX) = -LLR_MAX;


    % 2. If the channel generates an absolute division by zero (NaN),
    % set the uncertainty value to zero

    demodulated_signal(isnan(demodulated_signal)) = 0;

end