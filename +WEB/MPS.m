classdef MPS < WEB.API.Common
    % MATLAB Production Server API
    
    properties
        addr % Server address with port
        app % MPS application
        outputFormat % output Format for synchronous request
    end
    
    methods
        
        function obj = MPS(address, application)
            %% Template Construct an instance of this class
            obj.addr = address;
            obj.app = application;
            obj.setOutputFormat();
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
            req = WEB.API.Req(obj.addr); % new WEB Request
            req.addurl(obj.app); % add API method
            req.addurl(fcn); % add API method
            body = struct('rhs', rhs, 'nargout', nout, 'outputFormat', obj.outputFormat);
            req.setbody(body);
            req.setopts('ContentType', 'json'); % MATLAB works with JSON data
            req.setopts('MediaType', 'application/json'); % MATLAB works with JSON data
            req.setopts('Timeout', obj.timeout); % for heavy calls
            [res, err] = post(req); % call WEB API
            if isfield(res, 'error')
                err = res.error;
            end
            if isfield(res, 'lhs')
                res = res.lhs;
            else
                res = [];
            end
        end
        
        function help(~)
            %% Open online documentation
            web('https://www.mathworks.com/help/mps/restful-api-and-json.html');
        end
        
    end
    
    methods (Access = private)
        
        function [res, err] = get(obj, app, fcn)
            %% Perform get request
            req = WEB.API.Req(obj.addr);
            req.addurl(app);
            req.addurl(fcn);
            req.setopts('Timeout', obj.timeout);
            [res, err] = req.get();
        end
        
    end
    
end
