function llr_signal = derate_matching(demodulated_signal, BG, Zc, Q_m, TBS, attempt)

%desfazazer o interleaving

    E = length(demodulated_signal);
    num_rows = Q_m;
    num_cols = E / Q_m;
    
    reshaped = reshape(demodulated_signal, num_cols, num_rows);
    
    transposed_matrix = reshaped.';
    llr_signal = transposed_matrix(:).';


    rv_sequency = [0,2,3,1];
    rv_idx = rv_sequency(attempt);

%Criar um vetor de zeros tamanho N_cb
    if BG == 1
        %tamanho do buffer para BG1 já sem os primeiros 2*Zc
        N_cb = Zc*66;
        filler_bits = 20*Zc - TBS;

        switch rv_idx
            case 0, k0 = 0;
            case 1, k0 = floor((17 * N_cb) / (66 * Zc)) * Zc;
            case 2, k0 = floor((33 * N_cb) / (66 * Zc)) * Zc;
            case 3, k0 = floor((56 * N_cb) / (66 * Zc)) * Zc;
        end
    elseif BG == 2
        N_cb = Zc*50;
        filler_bits = 10*Zc - TBS;

        switch rv_idx
            case 0, k0 = 0;
            case 1, k0 = floor((13 * N_cb) / (50 * Zc)) * Zc;
            case 2, k0 = floor((25 * N_cb) / (50 * Zc)) * Zc;
            case 3, k0 = floor((43 * N_cb) / (50 * Zc)) * Zc;
        end
    end
    
    buffer = zeros(1, N_cb);

    if filler_bits ~= 0
        filler_low = (TBS + 1) - 2*Zc;
        filler_high = (TBS + filler_bits) - 2*Zc;
    end
    i = 1;
    j = 0;
    while(i <= E)
        index = mod(k0 + j, N_cb) + 1;

        if (index >= filler_low) && (index <= filler_high)
            buffer(index) = 100;
            j = j + 1; 
            continue;
        end
        buffer(index) = buffer(index)+llr_signal(i);
        i = i + 1;
        j = j+1;
    end

    llr_signal = buffer;
    llr_signal = [zeros(1,2*Zc), llr_signal];
%Você lê o primeiro bit do seu vetor desentrelaçado (Passo 1).

%Você olha para o buffer: Essa posição seria um filler bit (-1)?

    %Se sim: Você pula essa posição do buffer (não coloca nada ali) e mantém o bit do canal na mão.

    %Se não: Você insere (ou soma, no caso do HARQ) o LLR do canal nessa posição.

%Você avança o ponteiro do buffer de forma circular (mod). Repita isso até acabar os E bits vindos do canal.