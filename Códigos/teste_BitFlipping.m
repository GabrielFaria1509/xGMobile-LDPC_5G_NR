% =========================================================================
% Script de Teste - Bit-Flipping Decoding (Baseado na Apostila)
% =========================================================================
clc; clear;

% 1. Matriz de Paridade H (Exemplo 1.12)
H = [1 1 0 1 0 0;
     0 1 1 0 1 0;
     1 0 0 0 1 1;
     0 0 1 1 0 1];

max_iter = 10; % Limite de segurança

%% Teste: O Cenário de Sucesso (Exemplo 2.3)
disp('======================================================');
disp(' TESTE: Exemplo 2.3 - Correção por Bit-Flipping');
disp('======================================================');

% Vetor recebido com o primeiro bit corrompido pelo ruído
y = [1, 0, 1, 0, 1, 1]; 

% Chamando a função que criamos
[M, iter] = BitFlipping(y, H, max_iter);

fprintf('Iterações necessárias para convergência: %d\n', iter);
disp('Vetor Recebido com Erro:');
disp(y);
disp('Vetor Decodificado pelo MATLAB:');
disp(M);
disp('Vetor Esperado pela Apostila:');
disp('     0     0     1     0     1     1');
disp('======================================================');