function dados = ldpc_encode_nr_preprocess(H, Z_c)

    % Dimensoes da matriz
    n = size(H, 2);
    r = size(H, 1);
    k = n - r;
    g = 4 * Z_c;

    % Particionamento da matriz H
    A = H(g+1:end, 1:k);
    B = H(g+1:end, k+1:k+g);
    C = H(1:g, 1:k);
    D = H(1:g, k+1:k+g);

    % Pre-processamento
    Dinv = mod(round(inv(full(D))), 2);
    Dinv_C = mod(Dinv * full(C), 2);

    % Armazena os dados para reutilizacao
    dados.A = A;
    dados.B = B;
    dados.Dinv_C = Dinv_C;
    dados.k = k;
    dados.n = n;

end