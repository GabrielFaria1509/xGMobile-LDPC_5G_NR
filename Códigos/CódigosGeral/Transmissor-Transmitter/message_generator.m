%% Generate the Transport Block
function transport_block = message_generator(transport_block_size)

    % Generate a random Transport Block with the specified number of bits
    transport_block = randi([0 1], 1, transport_block_size);

end