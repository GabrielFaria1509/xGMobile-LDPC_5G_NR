% =========================================================================
% Script de Teste - Bit-Flipping Decoding (Baseado na Apostila)
% =========================================================================
clc; clear;

% 1. Matriz de Paridade H (Exemplo 1.12)
B = [0 2 -1 1;1 -1 2 0];
Zc = 3;


H = BaseGraphLifting(B,Zc);

display(H);

max_iter = 30; % Limite de segurança

%% Teste: O Cenário de Sucesso (Exemplo 2.3)
disp('======================================================');
disp(' TESTE - Correção por Bit-Flipping');
disp('======================================================');

%Descubro o núemro de colunas de m da matriz H gerada
m = width(H);

% Vetor aleatório recebido
y = geradormessage(m);

%Exibir mensagem antes de sofrer ruído
disp("Mensagem original sem ruído")
display(y);

%Simulação de canal com ruído
% Adicionando ruído ao vetor recebido
noise_level = 0.5; 

%Crio um vetor de 1 linha e colunas m,gera aleatórios entre 0 e 1(rand)
% Onde for menor que 0.1, ele marca como 1 (erro), caso contrário 0 (ok).
mascara_erros = rand(1,m) < noise_level

disp("Máscara de erros");
disp(double(mascara_erros));


y_ruidoso = double(xor(y,mascara_erros));

% Exibir o vetor ruidoso
disp('Vetor Ruidoso:');
disp(y_ruidoso);


% Chamando a função que criamos
[M, iter] = BitFlipping(y_ruidoso, H, max_iter);

fprintf('Iterações necessárias para convergência: %d\n', iter);
disp('Vetor Recebido com Erro:');
disp(y_ruidoso);
disp('Vetor Decodificado pelo MATLAB:');
disp(M);



