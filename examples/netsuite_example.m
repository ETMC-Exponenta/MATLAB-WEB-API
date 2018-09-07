%% Set auth data
account = '...';
consumer_key = '...';
consumer_secret = '...';
token_id = '...';
token_secret = '...';
%% Create service object
ns = WEB.NetSuite(account, consumer_key, consumer_secret, token_id, token_secret)
%% Call API
[res, err] = ns.getEmployee('roslovets@exponenta.ru')