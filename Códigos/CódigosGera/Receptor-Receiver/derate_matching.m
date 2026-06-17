function llr_signal = derate_matching(demodulated_signal, BG, Zc, Q_m, B, attempt, buffer)
    arguments
        demodulated_signal
        BG
        Zc
        Q_m
        B
        attempt
        buffer = -1
    end
    %% DE-RATE MATCHING PROCESS (3GPP TS 38.212)
    % Reconstructs the circular buffer and prepends punctured bits.
    % Reconstroi o buffer circular e adiciona os bits puncionados.
    
    %% VARIABLE DICTIONARY / DICIONÁRIO DE VARIÁVEIS
    % demodulated_signal: Received LLRs from the channel / LLRs recebidos do canal (tamanho E)
    % BG: Base Graph index (1 or 2) / Índice do Grafo Base selecionado (1 ou 2)
    % Zc: Lifting size / Tamanho de elevação da matriz
    % Q_m: Modulation order / Ordem de modulação (ex: 2 para QPSK)
    % TBS: Transport Block Size / Tamanho da mensagem original antes do LDPC
    % attempt: HARQ transmission attempt (1 to 4) / Tentativa de transmissão HARQ (1 a 4)
    % E: Length of the received signal / Tamanho do sinal recebido do canal
    % N_cb: Circular buffer size / Tamanho do buffer circular
    % filler_bits: Number of <NULL> bits / Número de bits de preenchimento nulos
    % k0: Starting point in the circular buffer / Ponto de partida no buffer circular
    
    %% 1. DE-INTERLEAVING / DESENTRELAÇAMENTO
    % Reverts the row-column interleaving applied at the transmitter.
    % Desfaz o entrelaçamento de linha-coluna aplicado no transmissor.
    E = length(demodulated_signal);
    num_rows = Q_m;
    num_cols = E / Q_m;
    
    % Reshape into matrix and transpose to get original sequence
    % Remolda em matriz e transpõe para obter a sequência original
    reshaped = reshape(demodulated_signal, num_cols, num_rows);
    transposed_matrix = reshaped.';
    llr_signal = transposed_matrix(:).'; % Flatten back to 1D / Achata para 1D
    
    %% 2. HARQ REDUNDANCY VERSION (RV) / VERSÃO DE REDUNDÂNCIA HARQ
    % Maps the transmission attempt to the official 3GPP RV sequence.
    % Mapeia a tentativa de transmissão para a sequência RV oficial do 3GPP.
    rv_sequency = [0, 2, 3, 1];
    rv_idx = rv_sequency(attempt);
    
    %% 3. BUFFER INITIALIZATION & STARTING POINT (k0) / INICIALIZAÇÃO DO BUFFER E PONTO DE PARTIDA (k0)
    if BG == 1
        % Buffer size for BG1 excluding the first 2*Zc bits
        % Tamanho do buffer para BG1 já sem os primeiros 2*Zc bits
        N_cb = Zc * 66;
        
        %%Kb is exactly 22 for BG1. Total capacity is 22*Zc.
        %%Kb é exatamente 22 para o BG1. A capacidade total é 22*Zc.
        filler_bits = 22 * Zc - B; 
        
        switch rv_idx
            case 0, k0 = 0;
            case 1, k0 = floor((17 * N_cb) / (66 * Zc)) * Zc;
            case 2, k0 = floor((33 * N_cb) / (66 * Zc)) * Zc;
            case 3, k0 = floor((56 * N_cb) / (66 * Zc)) * Zc;
        end
    elseif BG == 2
        N_cb = Zc * 50;
        
        % Observação: Kb fixado em 10 temporariamente (idealmente varia com A)
        filler_bits = 10 * Zc - B;
        switch rv_idx
            case 0, k0 = 0;
            case 1, k0 = floor((13 * N_cb) / (50 * Zc)) * Zc;
            case 2, k0 = floor((25 * N_cb) / (50 * Zc)) * Zc;
            case 3, k0 = floor((43 * N_cb) / (50 * Zc)) * Zc;
        end
    end
    
    % Initialize buffer with neutral LLRs (0) / Inicializa o buffer com LLRs neutros (0)
    if buffer == -1
        buffer = zeros(1, N_cb);
    end
    
    %% 4. FILLER BITS POSITIONS / POSIÇÕES DOS BITS DE PREENCHIMENTO
    % Determines where the <NULL> bits were placed during encoding.
    % Determina onde os bits <NULL> foram colocados durante a codificação.
    
    % Safety initialization / Inicialização de segurança para evitar erros
    filler_low = -1; 
    filler_high = -1;
    
    if filler_bits ~= 0
        % Offset by 2*Zc because the first 2 columns are punctured
        % Deslocado em 2*Zc porque as primeiras 2 colunas foram puncionadas
        filler_low = (B + 1) - 2 * Zc;
        filler_high = (B + filler_bits) - 2 * Zc;
    end
    
    %% 5. CIRCULAR BUFFER WRITING / ESCRITA NO BUFFER CIRCULAR
    i = 1; % Pointer for the received channel LLRs / Ponteiro para os LLRs recebidos
    j = 0; % Counter starting from k0 / Contador a partir de k0
    
    while(i <= E)
        % Calculate circular index (1-based for MATLAB)
        % Calcula o índice circular (baseado em 1 para MATLAB)
        index = mod(k0 + j, N_cb) + 1;
        
        % If this position is a filler bit / Se esta posição for um filler bit
        if (index >= filler_low) && (index <= filler_high)
            % Assign infinite certainty for bit 0 (LLR = +100)
            % Atribui certeza infinita para o bit 0 (LLR = +100)
            buffer(index) = 100;
            j = j + 1; 
            continue; % Skip using a channel LLR / Pula sem usar um LLR do canal
        end
        
        % Soft-combining: Add channel LLR to the buffer
        % Soft-combining: Soma o LLR do canal no buffer
        buffer(index) = buffer(index) + llr_signal(i);
        i = i + 1;
        j = j + 1;
    end
    
    llr_signal = buffer;
    
    %% 6. PREPENDING PUNCTURED BITS / ADICIONANDO BITS PUNCIONADOS
    % The first 2*Zc bits are systematically punctured at TX. The RX has zero info (LLR=0).
    % Os primeiros 2*Zc bits são sempre puncionados no TX. O RX tem zero informação (LLR=0).
    llr_signal = [zeros(1, 2 * Zc), llr_signal];
    
end