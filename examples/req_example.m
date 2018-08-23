% Req - library for WEB Requests. It's core component for all WEB APIs.
% Req can be usefull as standalone library.
%% Create Request
req = WEB.API.Req('http://uinames.com/api/');
%% Add query options
req.addquery('region', 'germany');
req.addquery('gender', 'female');
%% Set options
req.setopts('ContentType', 'json');
req.setopts('Timeout', 10);
%% Perform GET request
res = get(req)
%% Add more options
req.addquery('minlen', 20);
req.addquery('amount', 5);
req.addquery('gender', 'male');
res = get(req);
res = struct2table(res)
%% Explore req object
req
req.getquery()
req.getfullurl()
req.getopts()
%% Req documentation
doc(req)