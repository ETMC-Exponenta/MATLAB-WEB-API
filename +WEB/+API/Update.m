function Update
% Update MATLAB WEB API from GitHub to latest release
[v, vl, r] = WEB.API.Ver;
if ~isequal(v, vl)
    fprintf('Installing the latest version: v%s...\n', vl);
    dpath = tempname;
    mkdir(dpath);
    fpath = fullfile(dpath, r.assets.name);
    websave(fpath, r.assets.browser_download_url);
    res = matlab.addons.install(fpath);
    fprintf('%s v%s has been installed\n', res.Name{1}, res.Version{1});
    delete(fpath);
end
