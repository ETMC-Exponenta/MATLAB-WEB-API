classdef HeadHunter < WEB.API.Common
    % hh.ru API
    % https://github.com/hhru/api
    
    properties
        URL = 'https://api.hh.ru/' % Base URL
        access_token % Access Token
    end
    
    methods
        function obj = HeadHunter(access_token)
            %% VK Construct an instance of this class
            obj.access_token = access_token;
        end
        
        function res = call_api(obj, method, params, vars)
            %% Get via VK API
            if nargin < 3
                params = {};
                vars = {};
            end
            [params, apiopts] = obj.prepare_params(params, vars);
            req = WEB.API.Req(obj.URL);
            req.addurl(method);
            req.setquery(params);
            req.addheader('Authorization', "Bearer " + obj.access_token);
            req.setopts('ContentType', 'json');
            req.setopts('Timeout', 15);
            res = get(req);
        end
        
        function res = me(obj)
            %% Get self info
            method = 'me';
            res = obj.call_api(method);
        end
        
        function res = dictionaries(obj)
            %% Get dictionaries
            method = 'dictionaries';
            res = obj.call_api(method);
            res = orderfields(res);
            res = structfun(@struct2table, res, 'un', 0);
        end
        
        function res = vacancies(obj, varargin)
            %% Get vacancies
            method = 'vacancies';
            params = {'text', 'optional', ''
                'date_from', 'optional', ''
                'date_to', 'optional', ''
                'per_page', 'optional', 20
                'page', 'optional', 0};
            res = obj.call_api(method, params, varargin);
            res.items = obj.extract(res, 'items');
        end
        
    end
end
