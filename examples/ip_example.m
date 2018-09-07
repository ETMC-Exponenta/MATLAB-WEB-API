%% Create service object
ip = WEB.IP();
%% Get my IP info
[info, addr] = ip.get()
%% Get Google info
info = ip.get('8.8.8.8')
%% Get ETMC Exponenta info
[info, addr] = ip.get('exponenta.ru', 'plot')