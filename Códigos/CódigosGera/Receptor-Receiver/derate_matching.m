function llr_signal = derate_matching(demodulated_signal, BG, Zc, Q_m, TBS, attempt, buffer_in)

    % The 'buffer_in' parameter avoids argument mismatch errors and allows
    % HARQ soft combining between retransmissions

    arguments

        demodulated_signal
        BG
        Zc
        Q_m
        TBS
        attempt
        buffer_in = -1 % Default value for the first transmission attempt

    end


    %% DE-RATE MATCHING PROCESS (3GPP TS 38.212)


    %% 1. DE-INTERLEAVING

    E = length(demodulated_signal);

    num_rows = Q_m;

    num_cols = E / Q_m;


    reshaped = reshape(demodulated_signal, num_cols, num_rows);

    transposed_matrix = reshaped.';


    llr_signal = transposed_matrix(:).'; % Flatten matrix back into 1D vector



    %% 2. HARQ REDUNDANCY VERSION (RV) SELECTION

    rv_sequence = [0, 2, 3, 1];

    rv_index = rv_sequence(attempt);



    %% 3. BUFFER INITIALIZATION AND STARTING POSITION (k0)


    if BG == 1

        N_cb = Zc * 66;

        filler_bits = 22 * Zc - TBS;


        switch rv_index

            case 0

                k0 = 0;

            case 1

                k0 = floor((17 * N_cb) / (66 * Zc)) * Zc;

            case 2

                k0 = floor((33 * N_cb) / (66 * Zc)) * Zc;

            case 3

                k0 = floor((56 * N_cb) / (66 * Zc)) * Zc;

        end


    elseif BG == 2


        N_cb = Zc * 50;

        filler_bits = 10 * Zc - TBS;


        switch rv_index

            case 0

                k0 = 0;

            case 1

                k0 = floor((13 * N_cb) / (50 * Zc)) * Zc;

            case 2

                k0 = floor((25 * N_cb) / (50 * Zc)) * Zc;

            case 3

                k0 = floor((43 * N_cb) / (50 * Zc)) * Zc;

        end

    end



    % HARQ BUFFER MANAGEMENT:
    % Initialize a new buffer or recover the previous soft-combined buffer

    if isscalar(buffer_in) && buffer_in == -1

        buffer = zeros(1, N_cb);

    else

        % Remove punctured bits from the previous round before combining

        buffer = buffer_in((2 * Zc) + 1 : end);

    end



    %% 4. FILLER BITS POSITION CALCULATION


    filler_low = -1;

    filler_high = -1;


    if filler_bits ~= 0

        filler_low = (TBS + 1) - 2 * Zc;

        filler_high = (TBS + filler_bits) - 2 * Zc;

    end



    %% 5. CIRCULAR BUFFER WRITING (HARQ SOFT COMBINING)


    i = 1;

    j = 0;


    while(i <= E)

        index = mod(k0 + j, N_cb) + 1;


        if (index >= filler_low) && (index <= filler_high)

            buffer(index) = 100; % Infinite confidence for NULL bits

            j = j + 1;

            continue;

        end


        % Soft combining: Accumulate new channel LLR values in the buffer

        buffer(index) = buffer(index) + llr_signal(i);


        i = i + 1;

        j = j + 1;

    end


    llr_signal_out = buffer;



    %% 6. PREPENDING PUNCTURED BITS


    llr_signal = [zeros(1, 2 * Zc), llr_signal_out];

end