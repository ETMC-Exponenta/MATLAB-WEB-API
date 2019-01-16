function Update(force)
% Update MATLAB WEB API from GitHub to latest release
if nargin < 1
    force = 0;
end
UT = MATLABWEBAPIUpdater;
if ~force
    UT.update();
else
    UT.installweb();
end
