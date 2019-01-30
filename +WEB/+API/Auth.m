classdef Auth < handle
    % WEB Requests Authenticator 
    
    properties
        req % Req Object
        authdata % Authentication Data
        method % HTTP method
    end
    
    methods
        function obj = Auth(req, authdata, method)
            %% Create new Auth object
            if nargin > 0
                obj.req = req;
            end
            if nargin > 1
                obj.authdata = authdata;
            end
            if nargin > 2
                obj.method = method;
            end
        end
        
        function req = auth(obj)
            %% Authenticate
            a = obj.authdata;
            if ~isempty(a) && isfield(a, 'oauth_version')
                if a.oauth_version == "1.0"
                    obj.oauth10()
                end
            end
            req = obj.req;
        end
        
        function req = oauth10(obj)
            %% OAuth 1.0
            a = obj.authdata;
            A = obj.newtable();
            for f = fieldnames(a)'
                if startsWith(f, 'oauth_')
                    A = obj.addrow(A, f{1}, a.(f{1}));
                end
            end
            timestamp = round(java.lang.System.currentTimeMillis / 1000);
            A = obj.addrow(A, 'oauth_timestamp', num2str(timestamp));
            A = obj.addrow(A, 'oauth_nonce', dec2hex(round(rand*1e15)));
            B = sortrows([obj.req.query; A], 'name');
            base = strjoin(B.name + "=" + B.value, '&');
            base = strjoin({obj.method obj.req.urlencode(obj.req.geturl()) obj.req.urlencode(base)}, '&');
            key = join(string(a.secret), '&');
            sign = obj.HMAC(base, key, a.oauth_signature_method);
            A = obj.addrow(A, 'oauth_signature', sign);
            if isfield(a, 'realm')
                A = obj.addrow(A, 'realm', a.realm);
            end
            if isfield(a, 'authtype') && strcmpi(a.authtype, 'header')
                h = "OAuth " + strjoin(A.name + "=""" + obj.req.urlencode(A.value) + """", ', ');
                obj.req.addheader('Authorization', h);
            else
                obj.req.addquery(A);
            end
            req = obj.req;
        end
        
        function req = oauth20(obj)
            %% OAuth 2.0
            if ~isempty(obj.authdata)
                obj.req.addquery('access_token', obj.authdata.access_token);
            end
            req = obj.req;
        end
        
        function res = gettoken(obj, params)
            %% Get auth token
            if nargin < 2
                params = '';
            end
            obj.auth();
            if strcmpi(obj.method, 'browser')
                res = obj.getfrombrowser(params);
            else
                res = obj.req.call(obj.method);
                if ~isstruct(res)
                    res = obj.parsequery(res, params);
                end
            end
        end
        
        function auth_data = gettoken20(obj, type, client_secret)
            %% Get access token for Auth 2.0
            if strcmpi(type, 'implicit') % Implicit Auth 2.0
                obj.req.addquery(obj.authdata);
                obj.method = 'browser';
                auth_data = obj.gettoken({'access_token' 'expires_in'});
            elseif strcmpi(type, 'code') % Authorization Code Auth 2.0
                reqs = obj.req;
                req = reqs(1); %#ok<*PROPLC>
                req.addquery(obj.authdata);
                obj.req = req;
                obj.method = 'browser';
                c = obj.gettoken('code');
                req = reqs(2);
                req.addquery(obj.authdata);
                req.addquery('client_secret', client_secret);
                req.addquery('code', c.code);
                obj.req = req;
                obj.method = 'GET';
                auth_data = obj.gettoken();
            end
            auth_data.date = datetime('now');
            auth_data.expires_in = str2double(string(auth_data.expires_in));
        end
        
        function [values, url] = getfrombrowser(obj, params)
            %% Open URL in browser and get specified params values
            url = '';
            [~, h, ~] = web(obj.req.getfullurl(), '-new');
            while ~h.isValid
                % wait till Web Browser is ready
            end
            done = false;
            while ~done
                if ~isempty(h.getActiveBrowser)
                    url = char(h.getCurrentLocation());
                else
                    break
                end
                done = all(contains(url, params + "="));
            end
            values = obj.parsequery(url, params);
            close(h);
        end
        
        function ps = parsequery(~, url, params)
            %% Get query parameters from URL
            if nargin < 3 || isempty(params)
                qstr = '[^&#]+';
            else
                qstr = sprintf('(%s)([^&#]+)', char(join(params, '|')));
            end
            ps = regexp(url, qstr, 'match');
            ps = split(ps', '=');
            ps = reshape(ps, [], 2);
            ps = cell2struct(ps(:,2), ps(:,1));
        end
        
        function sign = HMAC(~, str, key, alg)
            %% HMAC encryption
            import java.net.*;
            import javax.crypto.*;
            import javax.crypto.spec.*;
            import org.apache.commons.codec.binary.*
            if contains(alg, 'SHA1')
                alg = 'HmacSHA1';
            elseif contains(alg, 'SHA256')
                alg = 'HmacSHA256';
            else
                error("Unknown HMAC Algorithm: " + alg);
            end
            keyStr = java.lang.String(key);
            key = SecretKeySpec(keyStr.getBytes(), alg);
            mac = Mac.getInstance(alg);
            mac.init(key);
            bytes = java.lang.String(str).getBytes();
            sign = mac.doFinal(bytes);
            sign = java.lang.String(Base64.encodeBase64(sign));
            sign = strtrim((sign.toCharArray())');
        end
    end
    
    
    methods (Access = private)
        
        function T = newtable(~)
            %% New empty name/value table
            T = cell2table(cell(0, 2), 'VariableNames', {'name', 'value'});
        end
        
        function T = addrow(~, T, name, value)
            %% Add row to table
            i = strcmpi(T.name, name);
            if any(i)
                T.value{i} = value;
            else
                T = [T; {name value}];
            end
        end
        
    end
end