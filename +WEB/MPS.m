classdef MPS < WEB.API.Common
    % MATLAB Production Server API
    
    properties
        addr % Server address with port
        app % MPS application
        outputFormat % output Format for synchronous request
        client % client ID for asynchronous request
        id % ID of asynchronous request
        self % URI of asynchronous request
        up % URI of asynchronous requests collection
        state % state of asynchronous request
        lastModifiedSeq % server state number
    end
    
    methods
        
        function obj = MPS(address, application)
            %% Template Construct an instance of this class
            obj.addr = address;
            obj.app = application;
            obj.setOutputFormat();
            obj.client = char(java.net.InetAddress.getLocalHost.getHostName);
        end
        
        function setOutputFormat(obj, options)
            %% Set output format
            arguments
                obj
                options.mode char {mustBeMember(options.mode, {'small', 'large'})} = 'small'
                options.nanInfFormat char {mustBeMember(options.nanInfFormat, {'string', 'object'})} = 'object'
            end
            obj.outputFormat = options;
        end
        
        function [res, err] = health(obj)
            %% Check server health
            [res, err] = obj.get('api', 'health');
            if err
                res = false;
            else
                res = true;
            end
        end
        
        function [res, err] = discovery(obj)
            %% Discovery methods
            [res, err] = obj.get('api', 'discovery');
        end
        
        function [res, err] = exec(obj, fcn, rhs, nout)
            %% Execute synchronous request
            arguments
                obj
                fcn
                rhs = []
                nout double = 1
            end
            body = obj.createBody(rhs, nout);
            [res, err] = obj.post(obj.app, fcn, body);
            if ~err
                res = mps.json.decoderesponse(res);
            end
        end

        function [res, err] = async(obj, fcn, rhs, nout)
            %% Asynchronous execution
            arguments
                obj
                fcn
                rhs = []
                nout double = 1
            end
            body = obj.createBody(rhs, nout);
            query = struct('mode', 'async', 'client', obj.client);
            [res, err] = obj.post(obj.app, fcn, body, query); % call WEB API
            if ~err
                res = jsondecode(res);
                obj.id = res.id;
                obj.self = res.self;
                obj.up = res.up;
                obj.state = res.state;
                obj.lastModifiedSeq = res.lastModifiedSeq;
            end
        end
        
        function [res, err] = representation(obj)
            %% Get representation of asynchronous request
            [res, err] = obj.get(obj.self, '');
            if ~err
                obj.self = res.self;
                obj.state = res.state;
            end
        end
        
        function [res, err] = collection(obj, since, clients, ids)
            %% Get collections of asynchronous requests
            arguments
                obj
                since double = obj.lastModifiedSeq
                clients = ''
                ids = ''
            end
            if isempty(clients)
                clients = obj.client;
            end
            if ~isempty(ids)
                query = struct('since', since, 'ids', obj.id);
            else
                query = struct('since', since, 'clients', clients);
            end
            [res, err] = obj.get(obj.up, '', query);
        end
        
        function [res, err] = information(obj)
            %% Get information about asynchronous requests
            [res, err] = obj.get(obj.self, 'info');
            if ~err
                obj.lastModifiedSeq = res.lastModifiedSeq;
                obj.state = res.state;
            end
        end
        
        function [res, err, raw] = result(obj)
            %% Get asynchronous requests result
            [raw, err] = obj.get(obj.self, 'result');
            if ~err
                if isstruct(raw)
                    res = raw;
                else
                    res = jsondecode(char(raw'));
                end
                res = res.lhs;
            end
        end
        
        function [res, err] = cancel(obj)
            %% Cancel asynchronous requests
            [res, err] = obj.post(obj.self, 'cancel');
        end
        
        function [res, err] = delete(obj)
            %% Delete asynchronous request
            if ~isempty(obj.self)
                [res, err] = obj.delete_req(obj.self);
                obj.self = [];
                obj.id = [];
                obj.state = '';
            end
        end
        
        function help(~)
            %% Open online documentation
            web('https://www.mathworks.com/help/mps/restful-api-and-json.html');
        end
        
    end
    
    methods (Access = private)
        
        function [res, err] = get(obj, app, fcn, query)
            %% Perform get request
            req = WEB.API.Req(obj.addr);
            req.addurl(app);
            req.addurl(fcn);
            if nargin > 3
                req.addquery(query);
            end
            req.setopts('Timeout', obj.timeout);
            [res, err] = req.get();
        end
        
        function [res, err] = post(obj, app, fcn, body, query)
            %% Execute synchronous request
            req = WEB.API.Req(obj.addr);
            req.addurl(app);
            req.addurl(fcn);
            if nargin > 4
                req.addquery(query);
            end
            if nargin > 3
                req.setbody(body);
            end
            req.setopts('ContentType', 'text');
            req.setopts('MediaType', 'application/json');
            req.setopts('Timeout', obj.timeout);
            [res, err] = post(req);
        end
        
        function [res, err] = delete_req(obj, uri)
            %% Perform get request
            req = WEB.API.Req(obj.addr);
            req.addurl(uri);
            req.setopts('Timeout', obj.timeout);
            [res, err] = req.call('delete');
        end
        
        function body = createBody(obj, rhs, nout)
            %% Create body for post request
            if ~iscell(rhs)
                rhs = {rhs};
            end
            body = mps.json.encoderequest(rhs, 'Nargout', nout,...
                'OutputFormat', obj.outputFormat.mode,...
                'OutputNanInfType', obj.outputFormat.nanInfFormat);
        end
        
    end
    
end