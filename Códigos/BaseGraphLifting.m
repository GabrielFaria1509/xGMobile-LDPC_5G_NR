% =========================================================================
% Script de Teste - Bit-Flipping Decoding (Baseado na Apostila)
% =========================================================================
clc; clear;

% 1. Matriz de Paridade H (Exemplo 1.12)
B = [0 2 -1 1;1 -1 2 0];
Zc = 3;
s = 5;

H = BaseGraphLifting(B,Zc,s);

display(H);

max_iter = 30; % Limite de segurança

%% Teste: O Cenário de Sucesso (Exemplo 2.3)
disp('======================================================');
disp(' TESTE: Exemplo 2.3 - Correção por Bit-Flipping');
disp('======================================================');

%Descubro o núemro de colunas de m da matriz H gerada
m = width(H);

% Vetor aleatório recebido
y = geradormessage(m);

% Chamando a função que criamos
[M, iter] = BitFlipping(y, H, max_iter);

fprintf('Iterações necessárias para convergência: %d\n', iter);
disp('Vetor Recebido com Erro:');
disp(y);
disp('Vetor Decodificado pelo MATLAB:');
disp(M);
