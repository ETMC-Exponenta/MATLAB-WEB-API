classdef Template < WEB.API.Common
    % Template Class for your new API
    
    properties
        URL = "https://example.com/api/" % Base URL
        api_key = 'example_key' % API Key (if required)
        storage % Data Storage (if you need)
    end
    
    methods
        function obj = Template(api_key)
            %% Template Construct an instance of this class
            obj.api_key = api_key;
            obj.storage = WEB.Utils.Storage('template_data.mat');
        end
        
        function set_data_path(obj, path)
            %% Set data storage path
            obj.storage.path = path;
        end
        
        function res = call_api(obj, method, params, vars)
            %% Call Template API - common method
            [params, apiopts] = obj.prepare_params(params, vars); % prepare call parameters and options
            % params - API method parameters (will be added to HTTP request)
            % apiopts - API options (wil NOT be added to HTTP request. Use it for better user experience if you want)
            req = WEB.API.Req(obj.URL); % new WEB Request
            req.addurl(method); % add API method
            req.setquery(params); % add method parameters
            req.setopts('ContentType', 'json'); % MATLAB works with JSON data
            req.setopts('Timeout', obj.timeout); % for heavy calls
            res = get(req); % call WEB API
            if apiopts.checkerr % check API auxiliary option
                obj.check_api_error(res); % check for WEB API errors if you need
            end
        end
        
        function check_api_error(~, res)
            %% Check API Call Error
            if isempty(res)
                error('API error: response is empty');
            elseif isfield(res, 'error')
                error(['API error: ' res.error.error_msg]);
            end
        end
        
        function res = method1(obj, p1, varargin)
            %% Method1 example
            method = 'meth1'; % WEB API Method (see WEB API documentation)
            params = {'p1', 'required', p1      % required HTTP request parameter
                'p2', 'optional', ''            % optional HTTP request parameter
                'p3', 'optional', 100           % optional HTTP request parameter
                'checkErr', 'apiOption', true}; % auxiliary API option
            res = obj.call_api(method, params, varargin); % call API
        end
        
        function res = method2(obj, varargin)
            %% Method2 example
            method = 'meth2';
            params = {'p1', 'optional', 0}; % Only one optional parameter
            res = obj.call_api(method, params, varargin);
        end
        
        function res = method3(obj, varargin)
            %% Method3 example
            method = 'meth3';
            % Method has no parameters
            res = obj.call_api(method, [], []);
        end
        
    end
end
