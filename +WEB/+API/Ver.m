function [cv, iv] = Ver
% Get local and latest version
updater = MATLABWEBAPIUpdater;
[cv, iv] = updater.ver;