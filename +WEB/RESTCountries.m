classdef RESTCountries < WEB.API.Common
    % Get information about countries via a RESTful API
    % http://restcountries.eu
    
    properties
        URL = 'https://restcountries.eu/rest/v2/' % Base URL
    end
    
    methods
        function obj = RESTCountries()
            % RESTCountries Construct an instance of this class
        end
        
        function [res, apiopts] = call_api(obj, method, params, vars)
            %% Call WEB API
            req = WEB.API.Req(obj.URL);
            req.addurl(method);
            if ~isempty(params)
                [params, apiopts] = obj.prepare_params(params, vars);
                req.setquery(params);
            end
            req.setopts('Timeout', obj.timeout);
            res = get(req);
            if ~isempty(res) && ~isscalar(res)
                res = struct2table(res);
            end
        end
        
        function res = all(obj, varargin)
            %% Get info about all countries
            method = 'all';
            res = obj.call_api(method, {}, varargin);
        end
        
        function res = byName(obj, name, varargin)
            %% Search by country name. It can be the native name or partial or full name
            method = "name/" + name;
            params = {'name', 'required', name
                'fullText', 'optional', false};
            res = obj.call_api(method, params, varargin);
        end
        
        function res = byCode(obj, codes, varargin)
            %% Search by ISO 3166-1 2-letter or 3-letter country code
            method = 'alpha';
            codes = string(codes);
            if ~isscalar(codes)
                codes = join(codes, ';');
            end
            params = {'codes', 'optional', codes};
            vars = {'codes', codes};
            res = obj.call_api(method, params, vars);
        end
        
        function res = byCurrency(obj, curcode, varargin)
            %% Search by ISO 4217 currency code
            method = "currency/" + curcode;
            res = obj.call_api(method, {}, varargin);
        end
        
        function res = byRegion(obj, region, varargin)
            %% Search by region
            method = "region/" + region;
            res = obj.call_api(method, {}, varargin);
        end
        
    end
end

