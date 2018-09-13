function Tag(v)
% Tag git project for specified version
pname = 'MATLAB.WEB.API.prj';
if nargin > 0
    matlab.addons.toolbox.toolboxVersion(pname, v);
else
    v = matlab.addons.toolbox.toolboxVersion(pname);
end
tagcmd = sprintf('git tag -a v%s -m v%s', v, v);
system(tagcmd);
system('git push --tags')
fprintf('MATLAB WEB API v%s has been tagged\n', v);