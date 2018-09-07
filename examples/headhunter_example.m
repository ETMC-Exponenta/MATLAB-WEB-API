%% Set auth data
access_token = '...';  % place here your Access Token
%% Create service object
hh = WEB.HeadHunter(access_token);
%% Get info about me
res = hh.me()
%% Get dictionaries
dicts = hh.dictionaries()
%% Search vacancies
res = hh.vacancies('text', 'MATLAB', 'date_from', '2018-07-31', 'per_page', 100)