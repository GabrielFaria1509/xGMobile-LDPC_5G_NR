% Generates a valid LDPC codeword
function codeword = codeword_generator(code_block, G)

    code_block_GF2 = code_block;
    code_block_GF2(code_block_GF2 == -1) = 0;

    codeword = mod(code_block_GF2 * G, 2);

    K = length(code_block);

    codeword(1:K) = code_block;

end