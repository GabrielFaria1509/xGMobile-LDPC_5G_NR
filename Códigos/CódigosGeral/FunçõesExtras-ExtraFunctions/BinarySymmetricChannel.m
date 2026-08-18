function y = BinarySymmetricChannel(flipping_probability, codeword)

%% Binary Symmetric Channel (Bit Flipping)
% Receives a bit-flipping probability and a codeword.
% Randomly flips bits according to the specified probability.

    y = codeword;

    n = length(codeword);

    for i = 1:n

        if rand <= flipping_probability

            y(i) = ~y(i);

        end

    end

end