function rx_signal = ModulatorProcess(f_interleaved,Qm,SNR, R)

%%Modulation process

%%It groups the bits and converts them to decimal.
f_interleaved = bi2de(reshape(f_interleaved,Qm,[]).',"left-msb");

%%Modualting 
modulated_word = qammod(f_interleaved,2^Qm,'UnitAveragePower', true);

%%SNR construction process
E = 1;
SNR_L = 10^(SNR/10);
sigma  = sqrt(E/(2*SNR_L));

%%Channel 
% Add noise to the modulated signal for channel simulation

awgn = sigma*(randn(size(modulated_word)) + 1j*randn(size(modulated_word)));
%%Or usisng : awgn = (modulated_word,SNR)

%%Signal received 
rx_signal = awgn + modulated_word;





