function G = G_matrix_generator_2(H, Zc)
tic
%Inicializa dimensões da matriz

H = full(H);%função gf só aceita matriz cheia,não sparse
[m,n] = size(H);

%bits de informação
k = n - m;

%Divisão da matriz H recebida em dois blocos(Matrizes)
% Dividir a matriz H em dois blocos(A == bits de informação,B = matriz quadrada,bits de paridade)
display("Gerando G,pode demorar para Zc maiores")
A = H(:,1:k);
B = H(:,k+1:n);

% 1. Definimos o ponto de corte do núcleo (as 4 primeiras linhas de bloco)
m_core = 4 * Zc;

% 2. Fatiamos a matriz nas exatas regiões que vimos no mapa
A1 = A(1:m_core, :);           % Topo Esquerdo
A2 = A(m_core+1:end, :);       % Fundo Esquerdo
B1 = B(1:m_core, 1:m_core);    % O Núcleo de Paridade
B2 = B(m_core+1:end, 1:m_core);% A Extensão de Paridade

% --- A MATEMÁTICA ENTRA AQUI ---

% Passo 1: Resolve P1 usando gf() SÓ na parte minúscula
P1_gf = gf(B1) \ gf(A1);
P1 = double(P1_gf.x);

% Passo 2: Resolve P2 usando matemática super rápida de matrizes (sem inversa)
P2 = mod(A2 + B2 * P1, 2);

% 3. Junta as duas partes encontradas
P = [P1; P2];
I = speye(k); %matriz identidade esparsa do tamanho da mensagem
G = [I,P']; % Combina a matriz identidade com a matriz de paridade
tempo = toc
end