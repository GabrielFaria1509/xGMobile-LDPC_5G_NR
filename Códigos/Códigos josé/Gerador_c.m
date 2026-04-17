% vetor de informação
u = randi([0 1], 1, k);

% separa H
H1 = H(:, 1:k);
H2 = H(:, k+1:end);

% resolve H2 * p = H1 * u
rhs = mod(H1 * u', 2);

% resolver sistema linear mod 2
p = gflineq(H2, rhs);

c = [u p']