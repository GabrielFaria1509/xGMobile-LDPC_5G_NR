function d = ModulatorScramble(Qm,f_interleaved,n_RNTI,n_ID)

 %% DICIONÁRIO DE VARIÁVEIS | VARIABLE LEGEND (3GPP TS 38.212)
 
 %Qm:Ordem de modulação|Modulation order
 %f_interleaved:codeword após processo de rate matching|codeword after
 %rate matching process
 % n_RNTI:Radio Network Temporary Identifier (ID do usuário)
 % n_ID:Physical layer cell identity (ID da antena)
 %%q:índice da palavra-código|codeword index
 %%E:Recurso físico máximo ou extensão final codeword|Maximal physical
 %%resource or final codeword lenght


%Scrambling process
%Getting the seed
q = 0;
%Usando q = 0 por enquanto,pois estamos enviando/trabalhando com uma
%codeword por vez|Using q = 0 for now, since we are sending/working with one codeword at a time.

c_init = (n_RNTI * (2^15) + q*(2^14) + n_ID);

E = length(f_interleaved);


% 2. Configuração do Gerador de Sequência de Gold (Padrão 3GPP)|Gold Sequence Generator Configuration (3GPP Standard)
    % O "Index" 1600 é uma exigência estrita da norma 5G (Nc = 1600)|The "Index" 1600 is a strict requirement of the 5G standard.
    % Ele descarta os primeiros 1600 bits gerados para garantir a aleatoriedade|It discards the first 1600 bits generated to ensure randomness.

gold_gen = comm.GoldSequence( ...
    'FirstPolynomial', [31 3 0], ...
     'SecondPolynomial', [31 3 2 1 0], ...
     'FirstInitialConditions', [zeros(1,30) 1], ...
     'SecondInitialConditions', de2bi(c_init, 31, 'right-msb'), ...
     'Index', 1600, ...
     'SamplesPerFrame', E);

% 3. Geração do ruído pseudoaleatório c(n)|Genrating the pseudorandom noise

c_sequence = gold_gen().';

scramble_bits = bitxor(f_interleaved,c_sequence);

%%QAM modulation
sym_idx = bi2de(reshape(scramble_bits, Qm, []).', 'left-msb');
d = qammod(sym_idx, 2^Qm, 'UnitAveragePower', true);
    
end


