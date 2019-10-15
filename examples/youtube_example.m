%% Set auth data
key = '...';      % place here your YouTube API v3 Key
%% Create service object
yt = WEB.YouTube(key);
%% Search videos
v = yt.search('q', 'matlab getting started')
%% Full list of search options
[v, res, err] = yt.search('q', 'matlab', 'channelId', 'UCgdHSFcXvkN6O3NXvif0-pA', 'maxResults', 50, 'order', 'date')