%% Add project directory to path
addpath('../')
%% Set up Bing Maps API
api_key = '...'; % place here your API Key
owm = WEB.OpenWeatherMap(api_key);
%% Get current weather by query
res = owm.current('q', 'moscow,ru', 'units', 'metric')
%% Get current weather by coordinates (Vostok station, Antarctica)
res = owm.current('lat', -78.464167, 'lon', 106.837222, 'units', 'metric', 'show', true)
%% Get weather forecast (The MathWorks, Natick)
[res, data] = owm.forecast('Zip', '01760,us', 'units', 'metric', 'show', true)