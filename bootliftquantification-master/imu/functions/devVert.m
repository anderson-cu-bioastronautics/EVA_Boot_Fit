function angVert = devVert(quat)
X = zeros(length(quat),3);
X(:,1) = 1;
Y = zeros(length(quat),3);
Y(:,2) = 1;
Z = zeros(length(quat),3);
Z(:,3) = 1;

Xg = quatrotate(quat, X);
%Yg = quatrotate(quat, Y);
%Zg = quatrotate(quat, Z);

angVert = zeros(1,length(Xg));
for i = 1:length(Xg)
    angVert(i) =atan2(norm(cross(-Z(i,:),Xg(i,:))), dot(-Z(i,:),Xg(i,:)));
end

end