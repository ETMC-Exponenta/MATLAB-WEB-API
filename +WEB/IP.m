classdef IP
    % IP-API - free IP geolocation API
    % http://ip-api.com
    
    properties
        URL = 'http://ip-api.com/json/'
    end
    
    methods
        function obj = IP()
            %IPFY Construct an instance of this class
        end
        
        function [info, addr] = get(obj, target, opt)
            % Get my IP
            req = WEB.API.Req(obj.URL);
            if nargin > 1
                req.addurl(target);
            end
            req.setopts('Timeout', 10);
            info = get(req);
            if ~isempty(info)
                addr = info.query;
                if (nargin > 2) && strcmpi(opt, 'plot')
                    obj.plot_geo(info);
                end
            else
                error('API Error: empty response')
            end
        end
        
        function g = plot_geo(~, info)
            %% Plot location in map
            P = WEB.Utils.Plotter;
            title = info.city + ", " + info.country;
            g = P.map([info.lat info.lon], 'Color', info.as, 'Title', title);
            g.ColorLegendTitle = 'Name';
        end
        
    end
end

