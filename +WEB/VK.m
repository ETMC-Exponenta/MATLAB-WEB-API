classdef VK < WEB.API.Common
    % VK.com API
    % https://vk.com/dev/manuals
    
    properties
        URL = "https://api.vk.com/method/"
        client_id
        client_secret
        scope
        ver = '5.8'
        authdata
    end
    
    methods
        function obj = VK(client_id, scope, client_secret)
            %% VK Construct an instance of this class
            obj.client_id = client_id;
            obj.authdata = WEB.Utils.Storage('vk_auth_data.mat');
            if isnumeric(scope)
                obj.scope = scope;
            else
                obj.scope = obj.get_scope(scope);
            end
            if nargin > 2
                obj.client_secret = client_secret;
            end
        end
        
        function set_data_path(obj, path)
            %% Set auth data path
            obj.authdata.path = path;
        end
        
        function scope = get_scope(~, names)
            %% Get scope value
            s = struct('notify',1,'friends',2,'photos',4,'audio',8,'video',16,...
                'stories',64,'pages',128,'app',256,'status',1024,'notes',2048,...
                'messages',4096,'wall',8192,'ads',32768,'offline',65536,'docs',131072,...
                'groups',262144,'notifications',524288,'stats',1048576,'email',4194304,...
                'market',134217728);
            names = cellstr(names);
            if strcmpi(names, 'all')
                scope = sum(struct2array(s));
            else
                ss = cellfun(@(f)getfield(s,f), names, 'un', 0); %#ok<GFLD>
                scope = sum(cell2mat(ss));
            end
        end
        
        function res = call_api(obj, method, params, vars)
            %% Get via VK API
            [params, apiopts] = obj.prepare_params(params, vars);
            if isfield(apiopts, 'getAll')
                getAll = apiopts.('getAll');
            else
                getAll = false;
            end
            req = WEB.API.Req(obj.URL);
            req.addurl(method);
            req.setquery(params);
            req.addquery('v', obj.ver);
            req.setopts('ContentType', 'json');
            req.setopts('Timeout', 15);
            A = WEB.API.Auth(req, obj.authdata.data);
            req = A.oauth20();
            res = get(req);
            obj.check_api_error(res);
            [res, count] = obj.get_items(res.response);
            if getAll && (count >= params.count)
                % get all items
                addRes = res;
                while ~isempty(addRes)
                    offset = str2double(req.getquery('offset')) + params.count;
                    req.addquery('offset', offset);
                    addRes = get(req);
                    addRes = obj.get_items(addRes.response);
                    res = [res; addRes];
                end
            end
        end
        
        function check_api_error(~, resp)
            %% Check API Call Error
            if isfield(resp, 'error')
                error(['API error: ' resp.error.error_msg]);
            end
        end
        
        function [items, count] = get_items(~, resp)
            %% Get items from repsonse
            if isfield(resp, 'items')
                items = resp.items;
            elseif isfield(resp, 'users')
                items = resp.users;
            else
                items = resp;
            end
            if isfield(resp, 'count')
                count = resp.count;
            else
                count = [];
            end
        end
        
        function auth_data = login(obj, opt)
            %% Authorization
            if (nargin > 1)
                auth_data = [];
            else
                auth_data = obj.load_auth_data();
            end
            if isempty(auth_data)
                a.client_id = obj.client_id;
                a.scope = obj.scope;
                a.redirect_uri = 'https://oauth.vk.com/blank.html';
                a.display = 'page';
                a.v = obj.ver;
                if (nargin > 1) && strcmpi(opt, 'implicit')
                    % Implicit flow
                    req = WEB.API.Req('https://oauth.vk.com/authorize');
                    req.addquery('response_type', 'token');
                    A = WEB.API.Auth(req, a);
                    auth_data = A.gettoken20('implicit');
                else
                    % Authorization Code Flow
                    req1 = WEB.API.Req('https://oauth.vk.com/authorize');
                    req1.addquery('response_type', 'code');
                    req2 = WEB.API.Req('https://oauth.vk.com/access_token');
                    A = WEB.API.Auth([req1 req2], a);
                    auth_data = A.gettoken20('code', obj.client_secret);
                end
                if ~isempty(auth_data)
                    obj.authdata.save(auth_data);
                else
                    error('VK API Error: Unsucessfull Authorization');
                end
            end
        end
        
        function data = load_auth_data(obj)
            %% Load and verify authorization data from file
            data = obj.authdata.load;
            if ~isempty(data)
                expires_in = data.expires_in;
                expired = (expires_in ~= 0) && datetime('now') < (data.date + seconds(expires_in) - hours(1));
                if ~isfield(data, 'access_token') || isempty(data.access_token) || expired
                    data = [];
                    obj.authdata.data = data;
                end
            end
        end
        
        function logout(obj)
            %% Delete auth data
            obj.authdata.clear();
        end
        
        function res = friends_get(obj, user_id, varargin)
            %% Get user subscriptions
            method = 'friends.get';
            params = {'user_id', 'required', user_id
                'fields', 'optional', ''
                'offset', 'optional', 0
                'count', 'optional', 5000
                'getAll', 'apiOption', false};
            res = obj.call_api(method, params, varargin);
        end
        
        function res = groups_getMembers(obj, group_id, varargin)
            %% Search groups
            method = 'groups.getMembers';
            params = {'group_id', 'required', group_id
                'fields', 'optional', ''
                'filter', 'optional', ''
                'sort', 'optional', 'id_asc'
                'offset', 'optional', 0
                'count', 'optional', 1000;
                'getAll', 'apiOption', 0};
            res = obj.call_api(method, params, varargin);
        end
        
        function res = groups_search(obj, q, varargin)
            %% Search groups
            method = 'groups.search';
            params = {'q', 'required', q
                'type', 'optional', 'group,page,event'
                'sort', 'optional', 0
                'offset', 'optional', 0
                'count', 'optional', 1000};
            res = obj.call_api(method, params, varargin);
        end
        
        function res = users_getFollowers(obj, user_id, varargin)
            %% Get user followers
            method = 'users.getFollowers';
            params = {'user_id', 'required', user_id
                'fields', 'optional', ''
                'name_case', 'optional', 'nom'
                'offset', 'optional', 0
                'count', 'optional', 1000
                'getAll', 'apiOption', false};
            res = obj.call_api(method, params, varargin);
        end
        
        function res = users_getSubscriptions(obj, user_id, varargin)
            %% Get user subscriptions
            method = 'users.getSubscriptions';
            params = {'user_id', 'required', user_id
                'fields', 'optional', ''
                'offset', 'optional', 0
                'count', 'optional', 200
                'extended', 'optional', 0
                'getAll', 'apiOption', false};
            res = obj.call_api(method, params, varargin);
        end
        
        function res = wall_post(obj, owner_id, message, varargin)
            %% Get user followers
            method = 'wall.post';
            params = {'owner_id', 'required', owner_id
                'message', 'required', message
                'friends_only', 'optional', 0};
            res = obj.call_api(method, params, varargin);
        end
        
    end
end
