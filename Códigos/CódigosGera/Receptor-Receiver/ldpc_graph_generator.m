function [B,A] = ldpc_graph_generator(H)

[m,n] = size(H);

B = cell(1,m);
A = cell(1,n);

% Check nodes -> Variable nodes
for j = 1:m
    B{j} = find(H(j,:) == 1);
end

% Variable nodes -> Check nodes
for i = 1:n
    A{i} = find(H(:,i) == 1)';
end

end