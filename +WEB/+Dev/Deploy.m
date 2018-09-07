function Deploy(v)
% Deploy toolbox for specified version
pname = 'MATLAB.WEB.API.prj';
fname = 'MATLAB.WEB.API';
if nargin > 0
    matlab.addons.toolbox.toolboxVersion(pname, v);
end
matlab.addons.toolbox.packageToolbox(pname, fname);