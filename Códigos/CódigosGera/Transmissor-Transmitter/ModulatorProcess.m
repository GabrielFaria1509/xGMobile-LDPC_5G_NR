function rx_signal = ModulatorProcess(f_interleaved,Q_m,SNR)

%% Modulation process

%% Group bits and convert them to decimal symbols
f_interleaved = bi2de(reshape(f_interleaved,Q_m,[]).',"left-msb");

%% QAM modulation
modulated_word = qammod(f_interleaved,2^Q_m,'UnitAveragePower', true);

%% SNR calculation process
%E = 1;
%SNR_linear = 10^(SNR/10);
%sigma = sqrt(E/(2*SNR_linear));

noise_std = sqrt(1./(2*Q_m*10.^(SNR/10)));

%% AWGN Channel
% Add noise to the modulated signal to simulate the communication channel

awgn_noise = noise_std*(randn(size(modulated_word)) + 1j*randn(size(modulated_word)));

%% Alternative implementation:
% awgn_noise = awgn(modulated_word,SNR)

%% Received signal
rx_signal = awgn_noise + modulated_word;

rx_signal = rx_signal.';