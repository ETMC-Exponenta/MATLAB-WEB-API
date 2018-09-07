function Update
% Update MATLAB WEB API from GitHub to latest release
url = 'https://api.github.com/repos/ETMC-Exponenta/MATLAB-WEB-API/releases/latest';
r = webread(url);
dpath = tempname;
mkdir(dpath);
fpath = fullfile(dpath, r.assets.name);
websave(fpath, r.assets.browser_download_url);
open(fpath)