classdef NetSuite < WEB.API.Common
    % Work with NetSuite
    
    properties (Access = private, Hidden = true)
        URL = 'https://%s.restlets.api.netsuite.com/app/site/hosting/restlet.nl'
        account
        consumer_key
        consumer_secret
        token_id
        token_secret
        sd_search = [149 1]; % [script deploy]
        sd_submit = [150 1]; % [script deploy]
        email % NLAuth email
        password % NLAuth password
        role % NLAuth role
    end
    
    methods
        function obj = NetSuite(account, email, password, role, token_secret)
            %% NS Construct an instance of this class
            obj.account = account;
            if nargin < 5
                obj.email = email;
                obj.password = password;
                obj.role = role;
            else
                obj.consumer_key = email;
                obj.consumer_secret = password;
                obj.token_id = role;
                obj.token_secret = token_secret;
            end
        end
        
        function url = getUrl(obj)
            %% Get request URL
            url = 'https://%s.restlets.api.netsuite.com/app/site/hosting/restlet.nl';
            url = sprintf(url, obj.account);
        end
        
        function [res, err] = call_api(obj, sd, method, query, body)
            %% New request
            req = WEB.API.Req(obj.getUrl());
            sd = string(sd);
            req.addquery('script', sd(1));
            req.addquery('deploy', sd(2));
            if nargin > 3 && ~isempty(query)
                req.addquery(query);
            end
            if nargin > 4 && ~isempty(body)
                req.addbody(body);
            end
            req.setopts('Timeout', 15);
            req.setopts('ArrayFormat', 'json');
            req.setopts('ContentType', 'json');
            req.setopts('MediaType', 'application/json');
            req.addheader('Content-type', 'application/json');
            req = obj.auth(req, method);
            [res, err] = req.call(method);
        end
        
        function [resp, err] = search(obj, type, columns, filters)
            %% NetSuite search
            query = {'type', type
                'columns', jsonencode(columns)
                'filters', jsonencode(filters)};
            [resp, err] = obj.call_api(obj.sd_search, 'GET', query);
        end
        
        function [resp, err] = submit(obj, type, ids, values)
            %% NetSuite record submit
            ids = str2double(ids);
            if isscalar(ids)
                ids = {ids};
            end
            body = {'type', type
                'ids', jsonencode(ids)
                'values', jsonencode(values)};
            [resp, err] = obj.call_api(obj.sd_submit, 'PUT', [], body);
        end
        
        function [resp, err] = getEmployee(obj, email)
            %% Get self name
            [resp, err] = obj.search('employee', {'firstname' 'lastname'}, {'email' 'is' email});
            if ~err
                resp = obj.extractVal(resp);
            end
        end
        
        function req = auth(obj, req, method)
            %% Set Auth paramaters
            if ~isempty(obj.email) && ~isempty(obj.password)
                req = obj.nlauth(req);
            else
                req = obj.oauth(req, method);
            end
        end
        
        function req = nlauth(obj, req)
            %% NLAuth method
            str = 'NLAuth nlauth_account=%s,nlauth_email=%s,nlauth_signature=%s,nlauth_role=%d';
            authstr = sprintf(str, obj.account, obj.email, obj.password, obj.role);
            req.addheader('Authorization', authstr);
        end
        
        function req = oauth(obj, req, method)
            %% OAuth1.0
            a.oauth_version = '1.0';
            a.oauth_consumer_key = obj.consumer_key;
            a.oauth_token = obj.token_id;
            a.oauth_signature_method = 'HMAC-SHA1';
            a.secret = {obj.consumer_secret obj.token_secret};
            a.realm = obj.account;
            a.authtype = 'header';
            A = WEB.API.Auth(req, a, method);
            req = A.oauth10();
        end
        
        function val = extractVal(~, res)
            %% Extract Values
            if isfield(res, 'values')
                val = res.values;
            else
                warning('Result has no values');
                val = [];
            end
        end
        
    end
end

