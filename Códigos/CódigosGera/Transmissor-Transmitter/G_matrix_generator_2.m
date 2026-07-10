function G = G_matrix_generator_2(H, Zc)

% Convert to full matrix (gf() does not accept sparse matrices)
H = full(H);

% Matrix dimensions
[M, N] = size(H);

% Number of information bits
K = N - M;

% Split the parity-check matrix H
% A: information part
% B: parity part
disp("Generating G matrix. This may take longer for larger Zc values.")

A = H(:, 1:K);
B = H(:, K+1:N);

% Number of rows corresponding to the parity core
M_core = 4 * Zc;

% Partition the matrices
A1 = A(1:M_core, :);
A2 = A(M_core+1:end, :);

B1 = B(1:M_core, 1:M_core);
B2 = B(M_core+1:end, 1:M_core);

% -------------------------------------------------------------------------
% Generator matrix computation
% -------------------------------------------------------------------------

% Step 1: Solve P1 over GF(2)
P1_gf = gf(B1) \ gf(A1);
P1 = double(P1_gf.x);

% Step 2: Compute P2
P2 = mod(A2 + B2 * P1, 2);

% Combine parity matrices
P = [P1; P2];

% Identity matrix
I = speye(K);

% Generator matrix
G = [I, P'];

end