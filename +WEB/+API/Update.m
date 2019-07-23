function Update(force)
% Update MATLAB WEB API from GitHub to latest release
if nargin < 1
    force = 0;
end
TU = MATLABWEBAPIUpdater;
if ~force
    TU.update();
else
    TU.installweb();
end
