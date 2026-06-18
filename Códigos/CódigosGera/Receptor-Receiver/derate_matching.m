function llr_signal = derate_matching(demodulated_signal, BG, Zc, Q_m, TBS, attempt, buffer_in)
    % Adicionamos o 'buffer_in' para não dar erro de argumentos com a função original do MATLAB
    arguments
        demodulated_signal
        BG
        Zc
        Q_m
        TBS
        attempt
        buffer_in = -1 % Valor padrão para a primeira tentativa
    end

    %% DE-RATE MATCHING PROCESS (3GPP TS 38.212)
    
    %% 1. DE-INTERLEAVING / DESENTRELAÇAMENTO
    E = length(demodulated_signal);
    num_rows = Q_m;
    num_cols = E / Q_m;
    
    reshaped = reshape(demodulated_signal, num_cols, num_rows);
    transposed_matrix = reshaped.';
    llr_signal = transposed_matrix(:).'; % Flatten back to 1D
    
    %% 2. HARQ REDUNDANCY VERSION (RV)
    rv_sequency = [0, 2, 3, 1];
    rv_idx = rv_sequency(attempt);
    
    %% 3. BUFFER INITIALIZATION & STARTING POINT (k0)
    if BG == 1
        N_cb = Zc * 66;
        filler_bits = 22 * Zc - TBS; 
        switch rv_idx
            case 0, k0 = 0;
            case 1, k0 = floor((17 * N_cb) / (66 * Zc)) * Zc;
            case 2, k0 = floor((33 * N_cb) / (66 * Zc)) * Zc;
            case 3, k0 = floor((56 * N_cb) / (66 * Zc)) * Zc;
        end
    elseif BG == 2
        N_cb = Zc * 50;
        filler_bits = 10 * Zc - TBS;
        switch rv_idx
            case 0, k0 = 0;
            case 1, k0 = floor((13 * N_cb) / (50 * Zc)) * Zc;
            case 2, k0 = floor((25 * N_cb) / (50 * Zc)) * Zc;
            case 3, k0 = floor((43 * N_cb) / (50 * Zc)) * Zc;
        end
    end
    
    % MÁGICA DO HARQ: Inicializa buffer zerado ou recupera o antigo!
    if isscalar(buffer_in) && buffer_in == -1
        buffer = zeros(1, N_cb);
    else
        % Remove os zeros do puncturing da rodada anterior para somar certo
        buffer = buffer_in((2 * Zc) + 1 : end);
    end
    
    %% 4. FILLER BITS POSITIONS
    filler_low = -1; 
    filler_high = -1;
    
    if filler_bits ~= 0
        filler_low = (TBS + 1) - 2 * Zc;
        filler_high = (TBS + filler_bits) - 2 * Zc;
    end
    
    %% 5. CIRCULAR BUFFER WRITING (SOFT COMBINING)
    i = 1; 
    j = 0; 
    
    while(i <= E)
        index = mod(k0 + j, N_cb) + 1;
        
        if (index >= filler_low) && (index <= filler_high)
            buffer(index) = 100; % Certeza infinita para NULL
            j = j + 1; 
            continue; 
        end
        
        % Soft-combining: Soma o novo LLR do canal no buffer
        buffer(index) = buffer(index) + llr_signal(i);
        i = i + 1;
        j = j + 1;
    end
    
    llr_signal_out = buffer;
    
    %% 6. PREPENDING PUNCTURED BITS
    llr_signal = [zeros(1, 2 * Zc), llr_signal_out];
end