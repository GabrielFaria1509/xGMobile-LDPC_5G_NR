%%Gerador da matriz G
function G = GeradorG(H)
%Inicializa dimensões da matriz

H = full(H);%função gf só aceita matriz cheia,não sparse
[m,n] = size(H);

%bits de informação
k = n - m;

%Divisão da matriz H recebida em dois blocos(Matrizes)
% Dividir a matriz H em dois blocos(A == bits de informação,B = matriz quadrada,bits de paridade)
display("Gerando G,pode demorar apra Zc maiores")
A = H(:,1:k);
B = H(:,k+1:n);

%Calculo inversa de B utilizando mod2 e multiplica pela matriz A()
%mod2 é para soma e multiplicação de matrizes

P = gf(B)\gf(A);  %esse comanda com barra equivale a fazer inversa de B vezes A

%Voltando P para double(Precisa tirar gf para juntar com I)
P = double(P.x);

I = speye(k); %matriz identidade esparsa do tamanho da mensagem
G = [I,P']; % Combina a matriz identidade com a matriz de paridade
%apostrófe indica transposta,vírgula junta matriz lado a lado

end



