classdef YouTube < WEB.API.Common
    % YouTube video service
    % https://developers.google.com/youtube/v3
    
    properties
        URL = "https://www.googleapis.com/youtube/v3/" % Base URL
        key % API Key
    end
    
    properties (Access = private)
        TU = WEB.Utils.Tables
    end
    
    methods
        function obj = YouTube(api_key)
            %% Constructor
            obj.key = api_key;
        end
        
        function [res, err, apiopts] = call_api(obj, method, params, vars)
            %% Get via API
            [params, apiopts] = obj.prepare_params(params, vars);
            req = WEB.API.Req(obj.URL);
            req.addurl(method);
            req.setquery(params);
            req.addquery('key', obj.key);
            if isempty(req.getquery('part'))
                req.addquery('part', 'snippet');
            end
            req.setopts('Timeout', obj.timeout);
            [res, err] = get(req);
        end
        
        function [T, res, err] = search(obj, varargin)
            %% Get search results
            method = 'search';
            params = {
                'q', 'optional', ''
                'channelId', 'optional', ''
                'maxResults', 'optional', 5
                'order', 'optional', 'relevance'
                };
            [res, err, apiopts] = obj.call_api(method, params, varargin);
            if ~isempty(res) && ~isempty(res.items)
                info = obj.TU.concat({res.items.id});
                if obj.TU.isvar(info, 'channelId')
                    info = removevars(info, 'channelId');
                end
                T = [obj.TU.concat({res.items.snippet}) info];
                T.publishedAt = datetime(T.publishedAt, 'InputFormat', "yyyy-MM-dd'T'HH:mm:ss'Z'");
                if ~obj.TU.isvar(T, 'videoId')
                    T = obj.TU.addfield(T, 'videoId', '');
                    T = movevars(T, 'videoId', 'after', 'kind');
                end
                if ~obj.TU.isvar(T, 'playlistId')
                    T = obj.TU.addfield(T, 'playlistId', '');
                end
            else
                T = table();
            end
        end
        
        function [res, err] = channels_list(obj, part, varargin)
            %% Get channels info
            method = 'channels';
            params = {
                'part', 'required', part
                'categoryId', 'optional', ''
                'forUsername', 'optional', ''
                'id', 'optional', ''
                'managedByMe', 'optional', false
                'mine', 'optional', false
                'h1', 'optional', ''
                'maxResults', 'optional', 5
                'onBehalfOfContentOwner', 'optional', ''
                'pageToken', 'optional', ''
                };
            [res, err, apiopts] = obj.call_api(method, params, varargin);
        end
        
        function [res, err] = playlistItems_list(obj, part, varargin)
            %% Get playlist items info
            method = 'playlistItems';
            params = {
                'part', 'required', part
                'id', 'optional', ''
                'playlistId', 'optional', ''
                'maxResults', 'optional', 5
                'onBehalfOfContentOwner', 'optional', ''
                'pageToken', 'optional', ''
                'videoId', 'optional', ''
                };
            [res, err, apiopts] = obj.call_api(method, params, varargin);
        end
        
    end
end
