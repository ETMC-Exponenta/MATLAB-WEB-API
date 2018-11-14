classdef Req < handle
    % Library for easy work with WEB requests

    properties
        url % Request URL
        query % Request Query Fields
        body % Request Body Ffields
        opts % Request Options
    end
    
    methods
        function obj = Req(url)
            %% Create new Req object
            if nargin < 1
                url = '';
            end
            obj.url = url;
            obj.clearquery();
            obj.clearbody();
            obj.clearopts();
        end
        
        function value = getheader(obj, name)
            %% Get header fields
            value = obj.convert(obj.opts.HeaderFields);
            if nargin > 1
                value = obj.getbyname(value, name);
            end
        end
        
        function header = setheader(obj, header)
            %% Set header (i.e. for JSON data)
            if istable(header)
                header = obj.convert(header);
            end
            obj.opts.HeaderFields = header;
        end
        
        function header = addheader(obj, name, value)
            %% Add header fields
            header = obj.convert(obj.opts.HeaderFields);
            if isnumeric(value)
                value = num2str(value);
            end
            header = obj.addrow(header, name, value);
            obj.opts.HeaderFields = obj.convert(header);
        end
        
        function header = clearheader(obj, header)
            %% Clear header fields
            opts = weboptions();
            obj.opts.HeaderFields = opts.HeaderFields;
        end
        
        function value = getquery(obj, name)
            %% Get query fields
            value = obj.query;
            if nargin > 1
                value = obj.getbyname(value, name);
            end
        end
        
        function query = setquery(obj, query)
            %% Set query fields
            if isempty(query)
                obj.clearquery();
            else
                if isstruct(query)
                    obj.clearquery();
                    for f = fieldnames(query)'
                        obj.addquery(f{1}, query.(f{1}));
                    end
                else
                    obj.query = query;
                end
            end
            query = obj.query;
        end
        
        function query = addquery(obj, name, value)
            %% Add query fields
            if istable(name)
                name = table2cell(name);
            elseif isstruct(name)
                name = [fieldnames(name) struct2cell(name)];
            end
            if iscell(name)
                name(:, 2) = obj.urlencode(name(:, 2));
                query = [obj.query; name];
            else
                query = obj.addrow(obj.query, obj.urlencode(name), obj.urlencode(value));
            end
            obj.query = query;
        end
        
        function query = clearquery(obj)
            %% Clear query fields
            query = obj.newtable();
            obj.query = query;
        end
        
        function value = getbody(obj, name)
            %% Get body
            value = obj.body;
            if nargin > 1
                value = obj.getbyname(value, name);
            end
        end
        
        function body = setbody(obj, body, asTable)
            %% Set body
            if nargin < 3
                asTable = false;
            end
            if isempty(body)
                obj.clearbody();
            else
                if isstruct(body) && asTable
                    obj.clearbody();
                    for f = fieldnames(body)'
                        obj.addbody(f{1}, body.(f{1}));
                    end
                else
                    obj.body = body;
                end
            end
            body = obj.body;
        end
        
        function body = addbody(obj, name, value)
            %% Add body fields
            if istable(name) || iscell(name)
                body = [obj.body; name];
            else
                body = obj.addrow(obj.body, name, value);
            end
            obj.body = body;
        end
        
        function body = clearbody(obj)
            %% Clear body
            body = obj.newtable();
            obj.body = body;
        end
        
        function url = geturl(obj)
            %% Get Request URL
            url = char(obj.url);
        end
        
        function seturl(obj, url)
            %% Set Request URL
            obj.url = string(url);
        end
        
        function addurl(obj, add)
            %% Add method to URL
            if ~isempty(obj.url)
                 if ~endsWith(obj.url, '/')
                     obj.url = obj.url + "/";
                 end
                 obj.url = obj.url + string(add);
            end
        end
        
        function fullurl = getfullurl(obj)
            %% Get full Request url (i.e. for web browser or 'webread')
            fullurl = char(obj.url);
            if endsWith(fullurl, '/')
                fullurl(end) = '';
            end
            if ~isempty(obj.query)
                fullurl = fullurl + "?" + strjoin(obj.query.name + "=" + obj.query.value, '&');
            end
            fullurl = char(fullurl);
        end
        
        function opts = getopts(obj)
            %% Get Request options
            opts = obj.opts;
        end
        
        function opts = setopts(obj, name, value)
            %% Set particular web option (see 'weboptions' function)
            if nargin == 2
                if class(name) == "weboptions" % set whole set of options
                    obj.opts = name;
                else
                    error('Not enough input arguments');
                end
            else
                obj.opts.(name) = value;
            end
            opts = obj.opts;
        end
        
        function opts = clearopts(obj)
            %% Reset Request options
            opts = weboptions;
            obj.opts = opts;
        end
        
        function [resp, err] = call(obj, method)
            %% Perfom request
            switch lower(method)
                case 'get'
                    [resp, err] = obj.get();
                case 'post'
                    [resp, err] = obj.post();
                case 'put'
                    [resp, err] = obj.put();
                case 'delete'
                    [resp, err] = obj.delete();
                case 'patch'
                    [resp, err] = obj.patch();
                otherwise
                    error('Unknown request method')
            end
        end

        function [resp, err] = get(obj)
            %% Perform GET request
            err = false;
            resp = [];
            try
                resp = webread(obj.getfullurl(), obj.opts);
            catch e
                err = e.message;
            end
        end
        
        function [resp, err] = post(obj)
            %% Perform POST request
            err = false;
            resp = [];
            try
                if obj.opts.MediaType == "application/x-www-form-urlencoded"
                    form = table2cell(obj.body)';
                    fp = matlab.net.http.io.MultipartFormProvider(form{:});
                    req = matlab.net.http.RequestMessage('post', [], fp);
                    resp = req.send(obj.getfullurl());
                else
                    resp = webwrite(obj.getfullurl(), obj.getstruct(obj.body), obj.opts);
                end
            catch e
                err = e.message;
            end
        end
        
        function [resp, err] = put(obj)
            %% Perform PUT request
            err = false;
            resp = [];
            obj.opts.RequestMethod = 'put';
            try
                resp = webwrite(obj.getfullurl(), obj.getstruct(obj.body), obj.opts);
            catch e
                err = e.message;
            end
        end
        
        function [resp, err] = delete(obj)
            %% Perform DELETE request
            err = false;
            resp = [];
            obj.opts.RequestMethod = 'delete';
            try
                resp = webwrite(obj.getfullurl(), obj.getstruct(obj.body), obj.opts);
            catch e
                err = e.message;
            end
        end
        
        function [resp, err] = patch(obj)
            %% Perform PATCH request
            err = false;
            resp = [];
            obj.opts.RequestMethod = 'patch';
            try
                resp = webwrite(obj.getfullurl, obj.getstruct(obj.body), obj.opts);
            catch e
                err = e.message;
            end
        end
        
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
        
        function value = getbyname(~, T, name)
            %% Get value by name
            value = T.value(strcmp(T.name, name));
            if length(value) == 1
                value = char(value);
            end
        end
        
        function h = convert(obj, h)
            %% Convert header between formats
            if istable(h)
                h = h{:, :};
            else
                T = obj.newtable();
                if iscell(h) || isstring(h)
                    h = cellstr(h);
                    for i = 1 : size(h, 1)
                        T = [T; h(i, :)];
                    end
                end
                h = T;
            end
        end
        
        function data = getstruct(~, data)
            %% convert data to struct
            if istable(data)
                for i = 1 : height(data)
                    s.(char(data{i, 1})) = data{i, 2};
                end
                data = s;
            end
        end
        
        function txt = decode(~, txt)
            %% Decode text
            txt = unicode2native(txt, 'utf-8');
            txt = native2unicode(txt, 'windows-1251');
        end
        
        function txt = urlencode(~, txt)
            %% Fixed urlencode
            if isnumeric(txt) && ~isscalar(txt)
                txt = join(string(txt(:)), ',');
            else
                txt = string(txt);
            end
            txt = txt(:);
            for i = 1 : length(txt)
                txt(i) = char(java.net.URLEncoder.encode(txt(i), 'UTF-8'));
                txt(i) = strrep(txt(i), '+', '%20');
            end
            if isscalar(txt)
                txt = char(txt);
            else
                txt = cellstr(txt);
            end
        end
        
    end
end