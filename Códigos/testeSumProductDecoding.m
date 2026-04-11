% =========================================================================
% Script de Teste - Sum-Product Decoding (Baseado no Exemplo 2.5 da Apostila)
% =========================================================================
clc; clear;

% 1. Matriz de Paridade H
B = [0 2 -1 1;1 -1 2 0];
Zc = 3;
s = 5;

H = BaseGraphLifting(B,Zc,s);

m = width(H);

display(H);

% 2. Vetor LLR de entrada calculado na apostila (página 33)
r = (4*rand(1,m) - 2);


% Limite de iterações definido na apostila
max_iter = 10;

disp('======================================================');
disp(' TESTE - Sum-Product Decoding');
disp('======================================================');

% Chamando a função que criamos
[z, iter, L] = sumProductDecoding(r, H, max_iter);

% =========================================================================
% Resultados para Comparação (Baseado nas páginas 35 e 36)
% =========================================================================
fprintf('Iterações necessárias para convergência: %d\n\n', iter);

disp('Vetor LLR Total (A Posteriori) final - L:');
disp(L);

disp('Vetor Decodificado pelo MATLAB (Hard Decision) - z:');
disp(z);

