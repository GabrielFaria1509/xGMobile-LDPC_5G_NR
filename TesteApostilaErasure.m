% =========================================================================
% Script de Teste - Erasure Decoding (Baseado na Apostila de Sarah Johnson)
% =========================================================================
clc; clear;

% 1. Matriz de Paridade H (Exemplo 1.12)
H = [1 1 0 1 0 0;
     0 1 1 0 1 0;
     1 0 0 0 1 1;
     0 0 1 1 0 1];

max_iter = 10; % Limite de segurança

%% Teste 1: O Cenário de Sucesso (Exemplo 2.2)
disp('======================================================');
disp(' TESTE 1: Exemplo 2.2 - Apagamentos Recuperáveis');
disp('======================================================');
% Vetor recebido: [0 0 1 x x x] (usamos -1 para o 'x')
y1 = [0, 0, 1, -1, -1, -1]; 

[M1, iter1] = erasureDecoding(y1, H, max_iter);

fprintf('Iterações necessárias: %d\n', iter1);
disp('Vetor Decodificado pelo MATLAB:');
disp(M1);
disp('Vetor Esperado pela Apostila:');
disp('     0     0     1     0     1     1');
disp(' ');


%% Teste 2: O Cenário de Falha (Exemplo 4.3)
disp('======================================================');
disp(' TESTE 2: Exemplo 4.3 - Falha por Stopping Set');
disp('======================================================');
% Vetor recebido: [0 0 x 0 x x] (usamos -1 para o 'x')
y2 = [0, 0, -1, 0, -1, -1];

[M2, iter2] = erasureDecoding(y2, H, max_iter);

fprintf('Iterações rodadas: %d (Atingiu o limite max_iter)\n', iter2);
disp('Vetor Resultante pelo MATLAB (Note que os -1 continuam):');
disp(M2);
disp('A apostila confirma que o decodificador falha pois {3,5,6} é um Stopping Set.');
disp('======================================================');