function f_interleaved = RateMatching(c, BG_number, Zc, E, Q_m, attempt)

    %% =========================================================================
    %% VARIABLE LEGEND (3GPP TS 38.212)
    %% =========================================================================
    % INPUTS
    % c        : LDPC codeword (with -1 representing <NULL>)
    % BG_number: Base Graph (1 or 2)
    % Zc       : Lifting size
    % E        : Rate matching output length
    % Q_m      : Modulation order (bits per symbol)
    % attempt  : HARQ transmission attempt
    %
    % INTERNAL VARIABLES
    % punctured_bits      : Number of punctured bits (2*Zc)
    % d                   : Circular buffer
    % N_cb                : Circular buffer length
    % k0                  : Starting position
    % e_k                 : Selected bits
    % interleaving_matrix : Temporary interleaving matrix
    %
    % OUTPUT
    % f_interleaved       : Rate-matched output sequence
    %% =========================================================================

    rv_sequence = [0,2,3,1];

    % Select the Redundancy Version (RV)
    rv_idx = rv_sequence(attempt);

    %% 1. Standard puncturing (TS 38.212 - Clause 5.4.2.1)

    punctured_bits = 2 * Zc;

    if length(c) < punctured_bits
        error('CRITICAL: The codeword contains %d bits. Expected at least %d bits.', ...
              length(c), punctured_bits);
    end

    c(1:punctured_bits) = [];
    d = c;

    %% 2. Circular buffer length

    N_cb = length(d);

    %% Starting position k0

    if BG_number == 1

        switch rv_idx
            case 0, k0 = 0;
            case 1, k0 = floor((17 * N_cb) / (66 * Zc)) * Zc;
            case 2, k0 = floor((33 * N_cb) / (66 * Zc)) * Zc;
            case 3, k0 = floor((56 * N_cb) / (66 * Zc)) * Zc;
        end

    elseif BG_number == 2

        switch rv_idx
            case 0, k0 = 0;
            case 1, k0 = floor((13 * N_cb) / (50 * Zc)) * Zc;
            case 2, k0 = floor((25 * N_cb) / (50 * Zc)) * Zc;
            case 3, k0 = floor((43 * N_cb) / (50 * Zc)) * Zc;
        end

    else
        error("Invalid Base Graph");
    end

    %% 3. Bit Selection

    e_k = zeros(1,E);

    k = 0;
    j = 0;

    while(k < E)

        circular_index = mod(k0 + j, N_cb) + 1;

        if d(circular_index) ~= -1
            e_k(k + 1) = d(circular_index);
            k = k + 1;
        end

        j = j + 1;

    end

    %% 4. Bit Interleaving (TS 38.212 - Clause 5.4.2.2)

    bits_per_symbol = Q_m;

    if mod(E,bits_per_symbol) ~= 0
        error("E must be a multiple of Q_m.");
    end

    interleaving_matrix = reshape(e_k, bits_per_symbol, E/bits_per_symbol).';

    f_interleaved = interleaving_matrix(:).';

end