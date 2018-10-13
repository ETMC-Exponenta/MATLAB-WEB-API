function Update(force)
% Update MATLAB WEB API from GitHub to latest release
if nargin < 1
    force = 0;
end
updater = MATLABWEBAPIUpdater;
if ~force
    updater.update();
else
    updater.install();
end
