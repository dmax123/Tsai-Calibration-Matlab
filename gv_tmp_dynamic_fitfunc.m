function deviation = gv_tmp_dynamic_fitfunc(calopt, calfixed, cam2d)

%calarray will be a 2D matrix nparameters by ncams.  Parameters need to be
%ordered--so I'll choose
%1 theta
%2 phi
%3 mu
%4 Tx
%5 Ty
%6 Tz
%7 f_eff
%8 k1
ncams=3;
calarray=calfixed;
calarray(1:8,2:3)=calopt(1:8,1:2);  %here we assume camera 1 is fixed.  If this changes, it needs to be changed here also.
for icam = 1:ncams
    R(:,:,icam) = gv_angles2rotmat(calarray(1:3,icam));
    Rinv(:,:,icam) = inv(R(:,:,icam));
    Tinv(:,icam) = Rinv(:,:,icam) * (-1* calarray(4:6,icam));
end

npoints=size(cam2d,1);
raymismatch=zeros(npoints,1);

for np=1:npoints 
M = zeros(3,3);
pM = zeros(3,ncams);
u = zeros(3, ncams);
for icam = 1:ncams
        % then find the unit vector designated by the camera position and
        % the 2D pixel coordinates. 
    u(:,icam) = gv_imgplane2unitvector(calarray(:,icam), Rinv(:,:,icam), cam2d(np,:,icam));
    uM = eye(3) - u(:,icam) * (u(:,icam))';
    pM(:,icam) = uM * Tinv(:,icam);
    M = M + uM;
end
% find the point minimizing the distance from all rays
p = M \ sum(pM,2);  % sums pm x together for all three cameras.  Makes a column vector, then does inv(M)*sum(pM,2)
h = zeros(1, ncams);
%find the distances from each ray.
for icam = 1:ncams
    temp = p - ((p') * u(:,icam)) * u(:,icam) - pM(:,icam);
    h(icam) = sqrt(temp' *temp);
end
hbar = sqrt(mean(h.*h));
raymismatch(np)=hbar;
end
deviation = mean(raymismatch);




