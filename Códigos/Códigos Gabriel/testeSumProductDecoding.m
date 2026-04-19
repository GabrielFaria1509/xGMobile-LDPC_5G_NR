% =========================================================================
% Script de Teste - Sum-Product Decoding (Baseado no Exemplo 2.5 da Apostila)
% =========================================================================
clc; clear;

% 1. Matriz de Paridade H
% 2. Gera a matriz e faz o lifting
Zc = 384;      
set_index = 0;
disp('Gerando Matriz do 5G...');
BG = GeradorBG1("Códigos\Códigos Gabriel\BG1.csv", set_index, Zc);
H = BaseGraphLifting(BG, Zc);
disp('Matriz H gerada com sucesso!');

m = width(H);

display(H);

% 2. Vetor LLR de entrada calculado
r = (4*rand(1,m) - 2);

%3Simular canal com ruídos
noise_level = 0.6;
% Gerar ruído gaussiano e adicionar ao vetor LLR de entrada
noise = noise_level * randn(1, m);
r = r + noise;


% Limite de iterações definido na apostila
max_iter = 10;

disp('======================================================');
disp(' TESTE - Sum-Product Decoding');
disp('======================================================');

% Chamando a função que criamos
[z, iter, L,success] = sumProductDecoding(r, H, max_iter);

% =========================================================================
% Resultados para Comparação (Baseado nas páginas 35 e 36)
% =========================================================================
fprintf('Iterações necessárias para convergência: %d\n\n', iter);

disp('Vetor LLR Total (A Posteriori) final - L:');
disp(L);

disp('Vetor Decodificado pelo MATLAB (Hard Decision) - z:');
disp(z);

if success
    disp("Sucesso palavra-código válida");
else
    disp("Falha palavra-código inválida");
end
