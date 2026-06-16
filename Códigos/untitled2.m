msg = randi([0 1], 300, 1);
indeice_simbol = bi2de(reshape(msg,3,[]).','left-msb');
qammsg = qammod(indeice_simbol, 8);

n = awgn(qammsg, 0.5);

demodulado = qamdemod(n,8,"gray",OutputType='llr');

y=0;