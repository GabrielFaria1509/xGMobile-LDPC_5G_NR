function [code_block_with_filler, F] = filler_bits(code_block, Kcb)
    B = length(code_block);

    if B ~= Kcb

        F = Kcb - B;

        if F < 0
            error("The code block is larger than the generator matrix. Increase Zc.");
        end

        % Filler bits are temporarily represented by -1 (NULL)
        filler = -1 * ones(1, F);

        code_block_with_filler = [code_block, filler];

    else

        F = 0;

        % No filler bits are required
        code_block_with_filler = code_block;

    end

end