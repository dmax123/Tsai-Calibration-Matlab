function [xmatch, varargout] = matchpoints(ncams, camParaCalib, Ximg)

Np = size(Ximg,1);
xmatch = zeros(Np, 3);
dist3D = zeros(Np, 1);
for n = 1:Np
	M = zeros(3, 3);
	pM = zeros(3, ncams);
	u = zeros(3, ncams);
	for icam = 1:ncams
		ximg = (Ximg(n,(icam-1)*2+1) - camParaCalib(icam).Npixw/2 - camParaCalib(icam).Noffw) * camParaCalib(icam).wpix;
		yimg = (camParaCalib(icam).Npixh/2 - camParaCalib(icam).Noffh - Ximg(n,(icam-1)*2+2)) * camParaCalib(icam).hpix;
		u(:, icam) = camParaCalib(icam).Rinv * [ximg yimg camParaCalib(icam).f_eff]';
		u(:, icam) = u(:,icam) / sqrt(sum(u(:,icam).*u(:,icam)));
		uM = eye(3) - u(:,icam) * (u(:,icam))';
		pM(:,icam) = uM * camParaCalib(icam).Tinv;
		M = M + uM;
	end
	p = M \ sum(pM, 2);
	h = zeros(1, ncams);
	for icam = 1:ncams
		temp = p - ((p')*u(:,icam)) * u(:,icam) - pM(:,icam);
		h(icam) = sqrt(temp' * temp);
	end
	xmatch(n,:) = p';
	dist3D(n) = sqrt(mean(h.*h));
end
if nargout > 1
	varargout(1) = {dist3D};
end	