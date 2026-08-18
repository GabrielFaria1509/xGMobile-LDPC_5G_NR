% Generates a random valid codeword
function codeword = RandomCodewordGenerator(generator_matrix)

    num_information_bits = size(generator_matrix, 1);

    information_bits = randi([0 1], 1, num_information_bits);

    codeword = mod(information_bits * generator_matrix, 2);

end