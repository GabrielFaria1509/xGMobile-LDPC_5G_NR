sps = 4;
msg = randi([0 1],1000,1);
oqpskMod = comm.OQPSKModulator( ...
    SamplesPerSymbol=sps, ...
    BitInput=true);
oqpskSig = oqpskMod(msg);

impairedSig = awgn(oqpskSig,15);

impairedQPSK = complex( ...
    real(impairedSig(1+sps/2:end-sps/2)), ...
    imag(impairedSig(sps+1:end)));

halfSinePulse = sin(0:pi/sps:(sps)*pi/sps);
matchedFilter = dsp.FIRDecimator(sps,halfSinePulse, ...
    DecimationOffset=sps/2);
filteredQPSK = matchedFilter(impairedQPSK);

oqpskModSymbolMapping = [1 3 0 2];
demodulated = qamdemod(filteredQPSK,4,oqpskModSymbolMapping, ...
    OutputType='llr');