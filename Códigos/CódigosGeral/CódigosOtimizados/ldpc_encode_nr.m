
function c = ldpc_encode_nr(s, H, Z_c)

    s = s(:);

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

    % Pre-processamento executado em toda chamada
    Dinv = mod(round(inv(full(D))), 2);
    Dinv_C = mod(Dinv * full(C), 2);

    % Calcula os primeiros bits de paridade
    p1 = mod(Dinv_C * s, 2);

    % Calcula os bits de paridade restantes
    p2 = mod(A * s + B * p1, 2);

    % Vetor completo de bits de paridade
    p = [p1; p2];

    c = [s; p]';
end
