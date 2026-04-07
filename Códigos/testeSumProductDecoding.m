% =========================================================================
% Script de Teste - Sum-Product Decoding (Baseado no Exemplo 2.5 da Apostila)
% =========================================================================
clc; clear;

% 1. Matriz de Paridade H (Exemplo 1.12)
H = [1 1 0 1 0 0;
     0 1 1 0 1 0;
     1 0 0 0 1 1;
     0 0 1 1 0 1];

% 2. Vetor LLR de entrada calculado na apostila (página 33)
r = [-1.3863, 1.3863, -1.3863, 1.3863, -1.3863, -1.3863];

% Limite de iterações definido na apostila
max_iter = 3;

disp('======================================================');
disp(' TESTE: Exemplo 2.5 - Sum-Product Decoding');
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

disp('======================================================');
disp(' VALIDAÇÃO COM A APOSTILA (Iteração 1 - Página 36)');
disp('======================================================');
disp('LLRs esperados para L_1 e L_2 na Iteração 1:');
disp('L_1 = 0.1213 (Apostila)');
disp('L_2 = 1.3863 (Apostila)');
disp('Vetor z esperado na Iteração 1:');
disp('z = [0  0  1  0  1  1]');
disp('======================================================');