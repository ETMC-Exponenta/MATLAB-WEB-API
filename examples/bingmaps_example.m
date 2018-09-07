%% Set auth data
api_key = '...'; % place here your API Key
%% Create service object
bm = WEB.BingMaps(api_key);
%% Set data path
bm.set_data_path('../data/');
%% Get location geocode
[res, gcode] = bm.location_findByQuery('moscow', 'maxResults', 1, 'useStorage', 1)
%% Get location geocodes and plot result
[res, gcodes] = bm.location_findByQuery('moscow', 'maxResults', 5, 'plot', 1)
%% Get location address by geocode
res = bm.location_findByPoint([55.7570, 37.6150], 'useStorage', 1)
%% Get geocode by address
[res, gcode] = bm.location_findByAddress('locality', 'RU', 'postalCode', 115088, 'addressLine', 'Moscow, 2-nd Yuzhnoportovy Proyezd, 31', 'maxResults', 1, 'plot', 1)
%% Get local business entities near that location
res = bm.location_recognition([42.2994411, -71.3513379]);
res.businessesAtLocation{1}(1).businessInfo
%% Get Moscow image and save to 'data' folder
bm.imagery_staticMap('aerialwithlabels', 'moscow, city', 'show', 1, 'mapSize', [1000,1000], 'dpi', 'large', 'save', 1, 'name', 'Moscow');
%% Get horse photo
bm.imagery_staticMap('aerial', [51.1011 1.1395], 'zoomLevel', 19, 'show', 1, 'mapSize', [600, 600]);