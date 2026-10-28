
function G = G_matrix_generator_2(H, Zc)

    % Dimensoes da matriz
    H = full(H);

    [M, N] = size(H);
    K = N - M;
    M_core = 4 * Zc;

    % Particionamento da matriz H
    A = H(:, 1:K);
    B = H(:, K+1:N);

    A1 = A(1:M_core, :);
    A2 = A(M_core+1:end, :);

    B1 = B(1:M_core, 1:M_core);
    B2 = B(M_core+1:end, 1:M_core);

    % Etapa 1: resolve em GF(2)
    P1_gf = gf(B1) \ gf(A1);
    P1 = double(P1_gf.x);

    % Etapa 2: calcula P2 em GF(2)
    P2 = mod(A2 + B2 * P1, 2);

    % Monta a matriz de paridade
    P = [P1; P2];

    % Matriz geradora
    G = [speye(K), P'];

end
