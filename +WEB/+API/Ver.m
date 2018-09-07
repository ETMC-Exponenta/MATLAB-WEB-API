function Ver
% Get local version
name = 'MATLAB WEB API';
tbx = matlab.addons.toolbox.installedToolboxes;
tbx = struct2table(tbx, 'AsArray', true);
idx = strcmp(tbx.Name, name);
v = tbx.Version(idx);
if isscalar(v)
    v = char(v);
end
fprintf('Installed version: %s\n', v);
% Get latest version
url = 'https://api.github.com/repos/ETMC-Exponenta/MATLAB-WEB-API/releases/latest';
r = webread(url);
vl = r.tag_name;
vl(1) = '';
fprintf('Latest version: %s\n', vl);
if isequal(v, vl)
    fprintf('You use the latest version\n');
else
    fprintf('* Update is available: %s->%s *\n', v, vl);
    fprintf('To update run command: WEB.API.Update\n');
end