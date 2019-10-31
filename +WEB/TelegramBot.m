classdef TelegramBot < WEB.API.Common
    % Telegram Bot API
    
    properties
        URL = "https://api.telegram.org/" % Base URL
        token % Bot token
    end
    
    methods
        function obj = TelegramBot(token)
            %% Constructor
            obj.token = token;
        end
        
        function [res, err] = call_api(obj, method, params, vars)
            %% Call Bot API
            [params, apiopts] = obj.prepare_params(params, vars); % prepare call parameters and options
            % params - API method parameters (will be added to HTTP request)
            % apiopts - API options (wil NOT be added to HTTP request. Use it for better user experience if you want)
            req = WEB.API.Req(obj.URL); % new WEB Request
            req.addurl("bot" + obj.token); % add bot token
            req.addurl(method); % add API method
            req.setquery(params); % add method parameters
            req.setopts('ContentType', 'json'); % MATLAB works with JSON data
            req.setopts('Timeout', obj.timeout); % for heavy calls
            [res, err] = get(req); % call WEB API
            if ~err
                if ~res.ok
                    err = res;
                    res = [];
                end
            end
        end
        
        function [res, err] = getMe(obj)
            %% Get bot information
            method = 'getMe';
            [res, err] = obj.call_api(method, [], []);
        end
        
        function [res, err] = getUpdates(obj, varargin)
            %% Get last updates
            method = 'getUpdates'; % WEB API Method (see WEB API documentation)
            params = {
                'ofset', 'optional', 0
                'limit', 'optional', 100
                'timeout', 'optional', 0
                'allowed_updates', 'optional', []
                };
            [res, err] = obj.call_api(method, params, varargin);
        end
        
        function [res, err] = sendMessage(obj, chat_id, text, varargin)
            %% Send message from bot
            method = 'sendMessage';
            params = {
                'chat_id', 'required', chat_id
                'text', 'required', text
                'parse_mode', 'optional', ''
                'disable_web_page_preview', 'optional', false
                'disable_notification', 'optional', false
                'reply_to_message_id', 'optional', []
                'reply_markup', 'optional', ''
                };
            [res, err] = obj.call_api(method, params, varargin);
        end
        
    end
end
