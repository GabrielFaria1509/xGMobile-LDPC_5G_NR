function dematched_blocks = codeBlockRateDematching(full_llr, C, E, BG_number, Zc, Q_m, K_perblock, attempt, buffer_in)

    % Initializes an empty buffer (first transmission attempt)

    if nargin < 9 || isempty(buffer_in)

        buffer_in = num2cell(-1 * ones(1, C));

    end


    dematched_blocks = cell(1, C);



    %% CORRECTION: Symbol-based division (ensures multiples of Q_m)

    symbol_chunks = floor(E / Q_m);          % Total available symbols

    chunks_base = floor(symbol_chunks / C);  % Symbols per code block

    chunks_rest = mod(symbol_chunks, C);     % Extra symbols to distribute


    E_base = chunks_base * Q_m;              % Base number of bits per block



    pointer = 1;


    for i = 1 : C


        % The first 'chunks_rest' blocks receive one extra symbol (Q_m bits)

        if (i - 1) < chunks_rest

            E_i = E_base + Q_m;

        else

            E_i = E_base;

        end



        % Exact LLR vector slicing

        sub_llr = full_llr(pointer : pointer + (E_i - 1));


        pointer = pointer + E_i;



        % HARQ processing and De-Rate Matching

        block_buffer = buffer_in{i};


        output_block = derate_matching(sub_llr, BG_number, Zc, Q_m, K_perblock, attempt, block_buffer);



        dematched_blocks{i} = output_block;


    end

end