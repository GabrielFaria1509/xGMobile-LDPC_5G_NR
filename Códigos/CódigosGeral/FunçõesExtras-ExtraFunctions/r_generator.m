function llr_values = r_generator(received_bits, crossover_probability)

%% LLR Generation for Binary Symmetric Channel (BSC)
% Computes the Log-Likelihood Ratio (LLR) values based on the received
% binary sequence and the channel crossover probability.

llr_values = zeros(1, length(received_bits));

for i = 1:length(received_bits)

    if received_bits(i) == 1

        llr_values(i) = log(crossover_probability / (1 - crossover_probability));

    else

        llr_values(i) = log((1 - crossover_probability) / crossover_probability);

    end

end

end