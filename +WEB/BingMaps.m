classdef BingMaps < WEB.API.Common
    % Geocode class
    
    properties
        URL = "http://dev.virtualearth.net/REST/v1/" % base URL
        key % API Key
        storage % Data storage
    end
    
    methods
        function obj = BingMaps(api_key)
            %% BingMaps Construct an instance of this class
            obj.key = api_key;
            obj.storage = WEB.Utils.Storage('bingmaps_gc_data.mat');
        end
        
        function set_data_path(obj, path)
            %% Set auth data path
            obj.storage.path = path;
        end
        
        function resCodes = get_geocode0(obj, locations)
            %% Get location Geocode
            gcodes = obj.load_gcodes();
            locations = cellstr(locations);
            n = length(locations);
            resCodes = zeros(n, 2);
            for i = 1 : n
                loc = locations{i};
                if isKey(gcodes, loc)
                    gcode = gcodes(loc);
                else
                    fprintf(' %d/%d: getting geocode of %s\n', i, n, loc);
                    res = obj.find_by_query(loc, 'maxResults', 1);
                    if ~isempty(res)
                        res = res.geocodePoints;
                        if iscell(res)
                            res = res{1};
                        end
                        gcode = res(1).coordinates;
                    else
                        warnig('WEB API: Location not found');
                        gcode = [NaN NaN];
                    end
                    gcodes(loc) = gcode;
                end
                resCodes(i, :) = gcode;
            end
            obj.save_gcodes(gcodes);
        end
        
        function [res, apiopts] = call_api(obj, method, params, vars)
            %% Get via API
            [params, apiopts] = obj.prepare_params(params, vars);
            req = WEB.API.Req(obj.URL);
            req.addurl(method);
            req.setquery(params);
            req.addquery('key', obj.key);
            req.setopts('Timeout', 10);
            res = get(req);
            if isempty(res)
                error('API Error: empty result')
            elseif isfield(res, 'resourceSets')
                res = res.resourceSets.resources;
                if ~isempty(res)
                    res = struct2table(res, 'AsArray', 1);
                    res.x__type = [];
                end
            end
        end
        
        function [res, geocode] = location_findByQuery(obj, query, varargin)
            %% Find location by query
            method = 'Locations';
            params = {'query', 'required', query
                'maxResults', 'optional', 5
                'incl', 'optional', ''
                'inclnb', 'optional', 0
                'useStorage', 'apiOption', 0
                'plot', 'apiOption', 0};
            [~, apiopts] = obj.prepare_params(params, varargin);
            if apiopts.useStorage
                geocode = obj.get_cm(query);
            end
            res = obj.call_api(method, params, varargin);
            geocode = obj.get_geocode(res);
            if apiopts.plot
                obj.plot_geo(res, query);
            end
        end
        
        function val = get_cm(obj, key)
            %% Get from containers map
            val = [];
            cm = obj.storage.data;
            if ~isempty(cm) && cm.isKey(key)
                val = cm(key);
            end
        end
        
        function cm = set_cm(obj, key, val)
            %% Get from containers map
            cm = obj.storage.data;
            if isempty(cm)
                cm = containers.Map();
            end
            cm(key) = val;
            obj.storage.data = cm;
        end
        
        function res = location_findByPoint(obj, point, varargin)
            %% Find location by point
            req = WEB.API.Req();
            method = "Locations/" + req.urlencode(point);
            params = {'includeEntityTypes', 'optional', ''
                'incl', 'optional', ''
                'inclnb', 'optional', 0
                'useStorage', 'apiOption', 0};
            res = obj.call_api(method, params, varargin);
        end
        
        function [res, geocode] = location_findByAddress(obj, varargin)
            %% Find location by address
            method = 'Locations';
            params = {'adminDistrict', 'optional', ''
                'locality', 'optional', ''
                'postalCode', 'optional', []
                'addressLine', 'optional', ''
                'countryRegion', 'optional', ''
                'includeNeighborhood', 'optional', 0
                'include', 'optional', ''
                'maxResults', 'optional', 10
                'useStorage', 'apiOption', 0
                'plot', 'apiOption', 0};
            [res, apiopts] = obj.call_api(method, params, varargin);
            geocode = obj.get_geocode(res);
            if apiopts.plot
                obj.plot_geo(res);
            end
        end
        
        function res = location_recognition(obj, point, varargin)
            %% Find location by address
            req = WEB.API.Req();
            method = "LocationRecog/" + req.urlencode(point);
            params = {'radius', 'optional', 0.25
                'top', 'optional', 10
                'distanceUnit', 'optional', 'km'
                'verboseplacenames', 'optional', false
                'includeEntityTypes', 'optional', 'businessAndPOI'};
            res = obj.call_api(method, params, varargin);
        end
        
        function res = imagery_staticMap(obj, imagerySet, query, varargin)
            %% Find location by address
            method = "Imagery/Map/" + imagerySet + "/";
            formats = struct('road', 'jpeg', 'aerial', 'jpeg', 'aerialwithlabels', 'jpeg',...
                'collinsbart', 'png', 'ordnancesurvey', 'png');
            params = {'mapSize', 'optional', [350 350]
                'mapLayer', 'optional', 'TrafficFlow'
                'mapMetadata', 'optional', 0
                'dpi', 'optional', ''
                'zoomLevel', 'optional', 0
                'show', 'apiOption', 0
                'save', 'apiOption', 0
                'name', 'apiOption', 'map'};
            ps = obj.prepare_params(params, varargin);
            if isnumeric(query)
                req = WEB.API.Req();
                point = req.urlencode(query);
                method = method + point + "/" + ps.zoomLevel;
            else
                method = method + query;
            end            
            [res, apiopts] = obj.call_api(method, params, varargin);
            if apiopts.show
                figure;
                imshow(res);
            end
            if apiopts.save
                fmt = "." + formats.(lower(imagerySet));
                imwrite(res, char(fullfile(obj.storage.path, apiopts.name + fmt)));
            end
        end
        
        function geocode = get_geocode(~, res)
            %% Extract geocode from response
            if ~isempty(res) && ismember('point', res.Properties.VariableNames)
                geocode = [res.point.coordinates]';
            else
                geocode = [];
            end
        end
        
        function g = plot_geo(obj, res, title)
            %% Plot geocodes on map
            gc = obj.get_geocode(res);
            conf = replace(res.confidence, {'Low','Medium','High'}, {'1','2','3'});
            P = WEB.Utils.Plotter;
            g = P.map(gc, 'Size', str2double(conf), 'Color', res.name);
            g.SizeLegendTitle = 'Confidence';
            g.ColorLegendTitle = 'Name';
            if nargin > 2
                g.Title = title;
            end
        end
        
        function gcodes = load_gcodes(obj)
            %% Load geocodes from file
            if isfile(obj.FNAME)
                load(obj.FNAME, 'gcodes');
            end
            if ~exist('gcodes', 'var')
                gcodes = containers.Map;
            end
        end
        
        function save_gcodes(obj, gcodes)
            %% Save geocodes to file
            save(obj.FNAME, 'gcodes');
        end
    end
end

