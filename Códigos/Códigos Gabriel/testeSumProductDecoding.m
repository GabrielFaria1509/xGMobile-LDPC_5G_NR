% =========================================================================
% Script de Teste Min-Sum Decoding Decoding (Baseado no Exemplo 2.5 da Apostila)
% =========================================================================
clc; clear;

% 1. Matriz de Paridade H
% 2. Gera a matriz e faz o lifting
% No C++ seria: cout << "Digite o Zc: "; cin >> Zc;
% No MATLAB é apenas:
Zc = input('Digite o valor de Zc para a matriz: ');  
set_index = input("Digite o set index : ");
opcao_bg = input("Digite o BG base : ");
% 2. Gera a matriz e faz o lifting
disp('Gerando Matriz do 5G...');
  if opcao_bg == 1
      BG = GeradorBG("Códigos\Códigos Gabriel\BG1.csv", set_index, Zc,opcao_bg);
  elseif opcao_bg == 2
      BG = GeradorBG("Códigos\Códigos Gabriel\BG2.csv", set_index, Zc,opcao_bg);

  else
    error('Opção de BG inválida! O script será encerrado.');

  end
      
H = BaseGraphLifting(BG, Zc);
disp('Matriz H gerada com sucesso!');

m = width(H);

spy(H);

% 2. Vetor LLR de entrada calculado
r = (4*rand(1,m) - 2);

%3Simular canal com ruídos
noise_level = 0.6;
% Gerar ruído gaussiano e adicionar ao vetor LLR de entrada
noise = noise_level * randn(1, m);
r = r + noise;


% Limite de iterações definido na apostila
max_iter = 60;

disp('======================================================');
disp(' TESTE - Sum-Product Decoding');
disp('======================================================');

% Chamando a função que criamos
[z, iter, L,success] = minSumDecoding(r, H, max_iter);

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
