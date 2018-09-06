%% Add project directory to path
addpath('../')
%% Create Uinames API object
uin = WEB.Uinames();
%% Get random name
res = uin.get()
%% Get 5 names
res = uin.get('amount', 5)
%% Get 5 russian names
res = uin.get('amount', 5, 'region', 'russia')
%% Get long name
res = uin.get('minlen', 55)
%% Get short name
res = uin.get('maxlen', 6)