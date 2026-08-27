function H = H_matrix_generator(BG, Zc)

    [M, N] = size(BG);

    % Initialize the parity-check matrix
    H = zeros(M * Zc, N * Zc);

    for row = 1:M
        for col = 1:N

            if BG(row, col) ~= -1

                % Generate the circulantly shifted identity matrix
                circulant_block = circshift(eye(Zc), [0, BG(row, col)]);

                H((row-1)*Zc+1:row*Zc, ...
                  (col-1)*Zc+1:col*Zc) = circulant_block;

            end

        end
    end

    H = sparse(H);

end