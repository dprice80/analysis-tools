function PCAdist = MahalPCA(S,D,lim)

[Rpca,Dpca,~,~,E] = pca(D);
stdDpca = std(Dpca);
Spca = S*Rpca;
ei = find(cumsum(E) > lim)+1;
Spca(:,ei:end) = [];
stdDpca(ei:end) = [];

PCAdist = sum((Spca./repmat(stdDpca,[size(S,1) 1])).^2,2); % sum of squared distances