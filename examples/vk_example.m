%% Set auth data
client_id = '...';      % place here your Client ID
client_secret = '...';  % place here your Client Secret
scope = {'friends', 'pages', 'groups', 'wall'}; % selective scope
% scope = 'all';
% scope = 140492255 % all
%% Create service object
vk = WEB.VK(client_id, scope, client_secret);
%% Set data path
vk.set_data_path('../data/');
%% Login to VK.com
vk.login()
%% Get friends
[res, count] = vk.friends_get('852372', 'fields', 'nickname')
%% Groups search
[res, count] = vk.groups_search('MATLAB', 'type', 'page', 'sort', 1)
%% Get all group members
[res, count] = vk.groups_getMembers('41030489', 'fields', 'city,sex', 'getAll', 1)
%% Get user followers
[res, count] = vk.users_getFollowers('1', 'fields', 'city,sex', 'count', 1000)
%% Get user subscriptions
res = vk.users_getSubscriptions('10050301', 'extended', true, 'extract', true)
%% Log out
vk.logout();