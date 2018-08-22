classdef DataGov < WEB.API.Common
    % DataGov.ru API
    % https://data.gov.ru/pravila-i-rekomendacii
    
    properties
        URL = 'https://data.gov.ru/api/'
        access_token
    end
    
    methods
        function obj = DataGov(access_token)
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
            req.addquery('access_token', obj.access_token);
            req.setopts('ContentType', 'json');
            req.setopts('Timeout', 15);
            res = get(req);
%             obj.check_api_error(res);
        end
        
        function check_api_error(~, resp)
            %% Check API Call Error
            if isfield(resp, 'errors')
                error(['API error: ' jsonencode(resp.errors)]);
            end
        end
        
        function res = main(obj)
            %% Get self info
            method = '';
            res = obj.call_api(method);
        end
        
        function res = datasets(obj, varargin)
            %% Get datasets
            method = 'dataset';
            params = {'organization', 'optional', ''
                'topic', 'optional', ''};
            res = obj.call_api(method, params, varargin);
            res = struct2table(res);
        end
        
        function [res, vers] = dataset(obj, id)
            %% Get dataset
            method = "dataset/" + id;
            res = obj.call_api(method);
            res.created = datetime(res.created);
            res.modified = datetime(res.modified);
            if nargout > 1
                vers = obj.call_api(method + "/version");
                vers = cellstr(vertcat(vers.created));
                vers = unique(vers);
            end
        end
        
        function [res, str, cont] = version(obj, id, ver)
            %% Get dataset version info
            method = "dataset/" + id + "/version/" + ver;
            res = obj.call_api(method);
            if length(res) > 1
                res = struct2table(res, 'AsArray', 1);
                res = unique(res);
                res = table2struct(res);
            end
            if nargout > 1
                str = obj.call_api(method + "/structure");
            end
            if nargout > 2
                cont = obj.call_api(method + "/content");
                if ~isempty(cont)
                    cont = struct2table(cont, 'AsArray', 1);
                end
            end
        end
        
        function res = organizations(obj)
            %% Get datasets
            method = 'organization';
            res = obj.call_api(method);
            res = struct2table(res);
            res.title = strtrim(res.title);
            res = sortrows(res, 'title');
        end
        
        function [info, data] = organization(obj, id)
            %% Get datasets
            method = "organization/" + id;
            info = obj.call_api(method);
            if nargout > 1
                data = obj.call_api(method + "/dataset");
                data = struct2table(data, 'AsArray', 1);
            end
        end
        
        function res = topics(obj)
            %% Get datasets
            method = 'topic';
            res = obj.call_api(method);
            res = sort({res.name}');
        end
        
        function [info, data] = topic(obj, title)
            %% Get datasets
            method = "topic/" + title;
            info = obj.call_api(method);
            if nargout > 1
                data = obj.call_api(method + "/dataset");
                data = struct2table(data, 'AsArray', 1);
            end
        end
        
    end
end
