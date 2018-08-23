%% Add project directory to path
addpath('../')
%% Create NetSuite object
% Place your credentials
account = '...';
consumer_key = '...';
consumer_secret = '...';
token_id = '...';
token_secret = '...';
ns = WEB.NetSuite(account, consumer_key, consumer_secret, token_id, token_secret)
%% Call API
[res, err] = ns.getEmployee('roslovets@exponenta.ru')