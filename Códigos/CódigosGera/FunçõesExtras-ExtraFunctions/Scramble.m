function scramble_message = Scramble(f_interleaved,n_RNTI,n_ID)


%% VARIABLE LEGEND | 3GPP TS 38.212

% Qm: Modulation order
% f_interleaved: Codeword after the rate matching process
% n_RNTI: Radio Network Temporary Identifier
% n_ID: Physical layer cell identity
% q: Codeword index
% E: Maximum physical resource or final codeword length



%% Scrambling Process

% Initialization value generation

q = 0;


% Using q = 0 for now, since we are sending/working with one codeword at a time

c_init = (n_RNTI * (2^15) + q*(2^14) + n_ID);


E = length(f_interleaved);



%% Gold Sequence Generator Configuration (3GPP Standard)

% The "Index" 1600 is a strict requirement of the 5G standard (Nc = 1600).
% It discards the first 1600 generated bits to ensure sequence randomness.


gold_gen = comm.GoldSequence( ...

    'FirstPolynomial', [31 3 0], ...

    'SecondPolynomial', [31 3 2 1 0], ...

    'FirstInitialConditions', [zeros(1,30) 1], ...

    'SecondInitialConditions', de2bi(c_init, 31, 'right-msb'), ...

    'Index', 1600, ...

    'SamplesPerFrame', E);



c_sequence = gold_gen().';



% XOR operation between codeword and scrambling sequence

scramble_message = bitxor(f_interleaved,c_sequence);


end