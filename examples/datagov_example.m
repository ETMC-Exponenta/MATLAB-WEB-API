%% Set auth data
api_key = '...'; % place here your API Key
%% Create service object
dg = WEB.DataGov(api_key);
%% Get main page
res = dg.main()
%% Get dataset
res = dg.datasets()
%% Get museum statistics
res = dg.datasets('topic', 'Culture', 'organization', '7705851331')
%% Get dataset info and versions
[res, vers] = dg.dataset('7705851331-stat_museum')
%% Get version data, structure and content
[res, str, cont] = dg.version('7705851331-stat_museum', vers{end})
%% Get organizations
orgs = dg.organizations()
%% Get organization title
[res, data] = dg.organization('5752056337')
%% Get topics
topics = dg.topics()
%% Get topic datasets
[res, data] = dg.topic('Weather')