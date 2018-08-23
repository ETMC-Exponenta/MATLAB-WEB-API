%% Add project directory to path
addpath('../')
%% Set up HH API
access_token = '...';  % place here your Access Token
hh = WEB.HeadHunter(access_token);
%% Get info about me
res = hh.me()
%% Get dictionaries
dicts = hh.dictionaries()
%% Search vacancies
res = hh.vacancies('text', 'MATLAB', 'date_from', '2018-07-31', 'per_page', 100)