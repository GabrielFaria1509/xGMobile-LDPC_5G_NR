function llr_signal = derate_matching(demodulated_signal, BG, Zc, Q_m, TBS, Rv)

%desfazazer o interleaving

    E = length(demodulated_signal);
    num_rows = Q_m;
    num_cols = E / Q_m;
    
    interleaved_matrix = reshape(demodulated_signal, num_rows, num_cols);
    
    transposed_matrix = interleaved_matrix.';
    llr_signal = transposed_matrix(:).';


%Criar um vetor de zeros tamanho N_cb
 % N_cb: Tamanho do Buffer Circular | Circular Buffer Length
 %StandardPuncturing = 2 * Zc;
    %c(1:StandardPuncturing) = [];
    %d = c;
    
    %% 2. Tamanho do Buffer Circular | Circular buffer length
    % PT: Calcula o tamanho do vetor após o puncturing
    % EN: Calculates the vector length after puncturing
    %N_cb = length(d);

   
%Você lê o primeiro bit do seu vetor desentrelaçado (Passo 1).

%Você olha para o buffer: Essa posição seria um filler bit (-1)?

    %Se sim: Você pula essa posição do buffer (não coloca nada ali) e mantém o bit do canal na mão.

    %Se não: Você insere (ou soma, no caso do HARQ) o LLR do canal nessa posição.

%Você avança o ponteiro do buffer de forma circular (mod). Repita isso até acabar os E bits vindos do canal.