classdef OpenWeatherMap < WEB.API.Common
    % Bing Maps
    % https://msdn.microsoft.com/en-us/library/ff701713.aspx
    
    properties
        URL = "http://api.openweathermap.org/data/2.5/" % Base URL
        key % API Key
    end
    
    methods
        function obj = OpenWeatherMap(api_key)
            %% OpenWeatherMap Construct an instance of this class
            obj.key = api_key;
        end
        
        function [res, apiopts] = call_api(obj, method, params, vars)
            %% Get via API
            [params, apiopts] = obj.prepare_params(params, vars);
            req = WEB.API.Req(obj.URL);
            req.addurl(method);
            req.setquery(params);
            req.addquery('APPID', obj.key);
            req.setopts('Timeout', obj.timeout);
            res = get(req);
        end
        
        function res = current(obj, varargin)
            %% Get current weather
            method = 'weather';
            params = {'q', 'optional', ''
                'id', 'optional', []
                'lat', 'optional', []
                'lon', 'optional', []
                'zip', 'optional', ''
                'units', 'optional', 'default'
                'show', 'apiOption', false};
            [res, apiopts] = obj.call_api(method, params, varargin);
            if apiopts.show
                obj.show_weather(res);
            end
        end
        
        function [res, data] = forecast(obj, varargin)
            %% Get 5 day / 3 hour forecast data
            method = 'forecast';
            params = {'q', 'optional', ''
                'id', 'optional', []
                'lat', 'optional', []
                'lon', 'optional', []
                'zip', 'optional', ''
                'units', 'optional', 'default'
                'show', 'apiOption', false};
            [res, apiopts] = obj.call_api(method, params, varargin);
            TU = WEB.Utils.Tables;
            data = TU.concat(res.list);
            if isstruct(data)
                data = struct2table(data, 'AsArray', true);
            end
            data.dt = datetime(data.dt, 'ConvertFrom', 'posixtime');
            if apiopts.show
                obj.plot_data(data);
            end
        end
        
        function ax = show_weather(~, res)
            %% Plot weather
            [img, ~, ~] = imread(['http://openweathermap.org/img/w/' res.weather.icon '.png']);
            P = WEB.Utils.Plotter();
            ax = P.image(img);
            text(3, 5, num2str(res.name), 'FontSize', 40);
            text(3, 43, num2str(res.main.temp) + "^o", 'FontSize', 50);
            text(36, 44, num2str(res.main.humidity) + "%", 'FontSize', 40, 'Color', 'b');
        end
        
        function plot_data(~, data)
            %% Plot weather forecast
            figure;
            % Plot weather
            subplot(8, 1, 1)
            icons = {data.weather.icon};
            uicons = unique(icons);
            cm = containers.Map;
            for i = uicons
                [img, ~, ~] = imread(['http://openweathermap.org/img/w/' i{1} '.png']);
                cm(i{1}) = img;
            end
            w = [];
            for i = icons
                w = [w cm(i{1})];
            end
            imshow(w)
            title('Weather')
            % Plot temperature
            subplot(8, 1, [2 4])
            plot(data.dt, [data.main.temp]);
            hold on
            plot(data.dt, [data.main.temp_min], 'b:');
            plot(data.dt, [data.main.temp_max], 'r:');
            hold off
            title('Temperature');
            grid on
            % Plot humidity
            subplot(8, 1, [6 8])
            plot(data.dt, [data.main.humidity]);
            title('Humidity');
            grid on
        end
    end
end

