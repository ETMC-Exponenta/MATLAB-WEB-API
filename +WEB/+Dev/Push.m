function Push(v)
% Commit and push project of specified version
pname = 'MATLAB.WEB.API.prj';
if nargin > 0
    matlab.addons.toolbox.toolboxVersion(pname, v);
else
    v = matlab.addons.toolbox.toolboxVersion(pname);
end
commitcmd = sprintf('git commit -m v%s', v);
system('git add .');
system(commitcmd);
system('git push');
fprintf('MATLAB WEB API v%s has been pushed\n', v);