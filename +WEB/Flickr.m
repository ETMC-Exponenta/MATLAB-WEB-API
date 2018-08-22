classdef Flickr < WEB.API.Common
    %FLICKR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        URL = "https://www.flickr.com/services/rest"
        appKey
        appSecret
        authdata % auth data
    end
    
    methods
        function obj = Flickr(appKey, appSecret)
            %% FLICKR Construct an instance of this class
            obj.authdata = WEB.Utils.Storage('flickr_auth_data.mat');
            obj.appKey = appKey;
            obj.appSecret = appSecret;
        end
        
        function set_data_path(obj, path)
            %% Set auth data path
            obj.authdata.path = path;
        end
        
        function auth_data = login(obj, opt)
            %% Login to Flickr
            if (nargin > 1) && opt == "force"
                auth_data = [];
            else
                auth_data = obj.authdata.load();
            end
            if isempty(auth_data)
                auth_data = obj.getAccessToken();
                obj.authdata.save(auth_data);
            end
            if isempty(auth_data)
                error('Flickr API Error: Unsucessfull Authorization');
            end
        end
        
        function logout(obj)
            %% Delete auth data
            obj.authdata.clear();
        end
        
        function a = getAuth(obj)
            %% Set Auth paramaters
            ad = obj.authdata.data;
            tokenSecret = '';
            if ~isempty(ad)
                if all(isfield(ad, {'oauth_token', 'oauth_token_secret'}))
                    a.oauth_token = ad.oauth_token;
                    tokenSecret = ad.oauth_token_secret;
                end
            end
            a.secret = {obj.appSecret tokenSecret};
            a.oauth_version = '1.0';
            a.oauth_consumer_key = obj.appKey;
            a.oauth_signature_method = 'HMAC-SHA1';
        end
        
        function res = getAccessToken(obj)
            %% Get access token
            % Get request token
            URL = 'https://www.flickr.com/services/oauth/'; %#ok<*PROP>
            req = WEB.API.Req(URL);
            req.addurl('request_token');
            a = obj.getAuth();
            a.oauth_callback = 'localhost';
            A = WEB.API.Auth(req, a, 'GET');
            rt = A.gettoken();
            a.oauth_token = rt.oauth_token;
            % Get auth verifier
            req = WEB.API.Req(URL);
            req.addurl('authorize');
            req.addquery('oauth_token', rt.oauth_token);
            A = WEB.API.Auth(req, [], 'browser');
            res = A.gettoken('oauth_verifier');
            a.oauth_verifier = res.oauth_verifier;
            % Get access token
            req = WEB.API.Req(URL);
            req.addurl('access_token');
            a.secret = {obj.appSecret rt.oauth_token_secret};
            A = WEB.API.Auth(req, a, 'GET');
            res = A.gettoken();
        end
        
        function res = call_api(obj, method, params, vars)
            %% Call Flickr API
            if nargin < 3
                params = {};
                vars = {};
            end
            [params, apiopts] = obj.prepare_params(params, vars);
            req = WEB.API.Req(obj.URL);
            if ~isempty(params)
                req.setquery(params);
            end
            req.addquery('format', 'json');
            req.addquery('nojsoncallback', 1);
            req.addquery('api_key', obj.appKey);
            req.addquery('method', method);
            A = WEB.API.Auth(req, obj.getAuth(), 'GET');
            req = A.oauth10();
            res = get(req);
            obj.check_api_error(res);
        end
        
        function check_api_error(~, resp)
            %% Check API Call Error
            if isfield(resp, 'stat') && resp.stat == "fail"
                error(['API error: ' resp.message]);
            end
        end
        
        function res = test_login(obj)
            %% Test successful login
            method = 'flickr.test.login';
            res = obj.call_api(method);
        end
        
        function res = test_echo(obj)
            %% Test echo
            method = 'flickr.test.echo';
            res = obj.call_api(method);
        end
        
        function res = photos_getPopular(obj, varargin)
            %% Get popular photos
            method = 'flickr.photos.getPopular';
            params = {'user_id', 'optional', ''
                'sort', 'optional', 'interesting'
                'extras', 'optional', ''
                'per_page', 'optional', 100
                'page', 'optional', 1
                'getAll', 'apiOption', false};
            res = obj.call_api(method, params, varargin);
            res = res.photos;
            res.photo = struct2table(res.photo, 'AsArray', 1);
        end
        
        function res = photos_getSizes(obj, photo_id, varargin)
            %% Get popular photos
            method = 'flickr.photos.getSizes';
            params = {'photo_id', 'required', photo_id};
            res = obj.call_api(method, params, varargin);
            res = res.sizes;
            res.size = struct2table(res.size, 'AsArray', 1);
        end
        
        function res = photos_search(obj, varargin)
            %% Get popular photos
            method = 'flickr.photos.search';
            params = {'user_id', 'optional', ''
                'tags', 'optional', ''
                'tag_mode', 'optional', 'any'
                'text', 'optional', ''
                'sort', 'optional', 'date-posted-desc'};
            res = obj.call_api(method, params, varargin);
            res = res.photos;
            res.photo = struct2table(res.photo, 'AsArray', 1);
        end
        
        function res = groups_getPhotos(obj, group_id, varargin)
            %% Get popular photos
            method = 'flickr.groups.pools.getPhotos';
            params = {'group_id', 'required', group_id
                'tags', 'optional', ''
                'user_id', 'optional', ''
                'extras', 'optional', ''
                'per_page', 'optional', 100
                'page', 'optional', 1
                'getAll', 'apiOption', false};
            res = obj.call_api(method, params, varargin);
            res = res.photos;
            res.photo = struct2table(res.photo, 'AsArray', 1);
        end
        
        function res = get_photo(~, T, size, varargin)
            %% Download Photo
            url = T.source{strcmpi(T.label, size)};
            res = webread(url);
        end
        
    end
end

