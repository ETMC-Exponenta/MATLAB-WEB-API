classdef Uinames < WEB.API.Common
    % Get information about countries via a RESTful API
    % http://restcountries.eu
    
    properties
        URL = 'http://uinames.com/api/' % Base URL
    end
    
    methods
        function obj = Uinames()
            % Uinames Construct an instance of this class
        end
        
        function [res, apiopts] = get(obj, varargin)
            %% Call uinames API
            params = {'amount', 'optional', 1
                'gender', 'optional', ''
                'region', 'optional', ''
                'minlen', 'optional', 0
                'maxlen', 'optional', 0};
            req = WEB.API.Req(obj.URL);
            if ~isempty(params)
                [params, apiopts] = obj.prepare_params(params, varargin);
                req.setquery(params);
            end
            req.setopts('Timeout', obj.timeout);
            res = get(req);
            if ~isempty(res)
                res = struct2table(res, 'AsArray', true);
            end
        end
        
    end
end

