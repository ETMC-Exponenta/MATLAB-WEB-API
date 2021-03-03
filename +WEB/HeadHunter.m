classdef HeadHunter < WEB.API.Common
    % hh.ru API
    % https://github.com/hhru/api
    
    properties
        URL = 'https://api.hh.ru/' % Base URL
        access_token % Access Token
        TU = WEB.Utils.Tables
    end
    
    methods
        function obj = HeadHunter(access_token)
            %% VK Construct an instance of this class
            if nargin > 0
                obj.access_token = access_token;
            end
        end
        
        function [res, err] = call_api(obj, method, params, vars)
            %% Get via VK API
            if nargin < 3
                params = {};
                vars = {};
            end
            if ~isstruct(params)
                [params, apiopts] = obj.prepare_params(params, vars);
            end
            params = obj.fix_dates(params);
            req = WEB.API.Req(obj.URL);
            req.addurl(method);
            req.setquery(params);
            if ~isempty(obj.access_token)
                req.addheader('Authorization', "Bearer " + obj.access_token);
            end
            req.setopts('ContentType', 'json');
            req.setopts('Timeout', 15);
            [res, err] = get(req);
        end
        
        function p = fix_dates(~, p)
            % Convert dates to ISO 8601 format
            if ~isempty(p)
                for f = fieldnames(p)'
                    if ismember(f{1}, {'date_from', 'date_to'})
                        pval = p.(f{1});
                        if isdatetime(pval)
                            p.(f{1}) = datestr(pval, 30);
                        end
                    end
                end
            end
        end
        
        function [res, err] = me(obj)
            %% Get self info
            method = 'me';
            [res, err] = obj.call_api(method);
        end
        
        function [res, err] = dictionaries(obj)
            %% Get dictionaries
            method = 'dictionaries';
            [res, err] = obj.call_api(method);
            res = orderfields(res);
            res = structfun(@struct2table, res, 'un', 0);
        end
        
        function [res, err] = industries(obj)
            %% Get industries
            method = 'industries';
            [res, err] = obj.call_api(method);
            res = struct2table(res);
        end
        
        function [res, err] = specializations(obj)
            %% Get specializations
            method = 'specializations';
            [res, err] = obj.call_api(method);
            res = struct2table(res);
        end
        
        function [res, err] = areas(obj)
            %% Get areas
            method = 'areas';
            [res, err] = obj.call_api(method);
            res = struct2table(res);
        end
        
        function [res, err] = metro(obj)
            %% Get metro
            method = 'metro';
            [res, err] = obj.call_api(method);
            res = struct2table(res);
        end
        
        function [res, err] = vacancies(obj, varargin)
            %% Get vacancies
            method = 'vacancies';
            params = {'text', 'optional', ''
                'search_field', 'optional', ''
                'experience', 'optional', ''
                'employment', 'optional', ''
                'schedule', 'optional', ''
                'area', 'optional', []
                'metro', 'optional', ''
                'specialization', 'optional', ''
                'industry', 'optional', ''
                'employer_id', 'optional', ''
                'currency', 'optional', ''
                'salary', 'optional', ''
                'label', 'optional', ''
                'only_with_salary', 'optional', false
                'period', 'optional', 30
                'date_from', 'optional', ''
                'date_to', 'optional', ''
                'top_lat', 'optional', []
                'bottom_lat', 'optional', []
                'left_lng', 'optional', []
                'right_lng', 'optional', []
                'order_by', 'optional', ''
                'sort_point_lat', 'optional', []
                'sort_point_lng', 'optional', []
                'clusters', 'optional', false
                'describe_arguments', 'optional', false
                'per_page', 'optional', 20
                'page', 'optional', 0
                'no_magic', 'optional', true
                'premium', 'optional', false
                'getAll', 'apiOption', false
                'step', 'apiOption', 12
                'batchSave', 'apiOption', false
                'saveParams', 'apiOption', false
                'toFile', 'apiOption', ''};
            [params, apiopts] = obj.prepare_params(params, varargin);
            if apiopts.getAll
                k = 0;
                if isfield(params, 'date_to')
                    d2 = params.date_to;
                else
                    d2 = dateshift(datetime('now'), 'start', 'day', 'next');
                end
                if isfield(params, 'date_from')
                    d1 = params.date_from;
                else
                    d1 = d2 - calmonths(1);
                end
                ds = d1 : hours(apiopts.step) : d2;
                ns = length(ds) - 1;
                items = [];
                if apiopts.batchSave
                    if ~isfolder('data')
                        mkdir('data');
                    end
                    k = 0;
                end
                for n = 1 : ns
                    p = 1;
                    if apiopts.batchSave
                        items = [];
                        k = k + 1;
                    end
                    fprintf('%d/%d: page %d\n', n, ns, p);
                    [res, err] = getBatch(obj, method, params, ds, n, p);
                    if err
                        disp("ERROR:" + newline + err)
                    else
                        items1 = obj.TU.concat(res.items);
                        if isempty(items)
                            items = items1;
                        else
                            items = obj.TU.concat({items items1});
                        end
                        ps = res.pages;
                        if ps > 1
                            for p = 2 : ps
                                fprintf('%d/%d: page %d/%d\n', n, ns, p, ps);
                                if ps == 20
                                    warning('Bulk overflow, some data lost');
                                end
                                [res, err] = getBatch(obj, method, params, ds, n, p);
                                if err
                                    disp(err);
                                else
                                    items1 = obj.TU.concat(res.items);
                                    if isempty(items)
                                        items = items1;
                                    else
                                        items = obj.TU.concat({items items1});
                                    end
                                end
                                pause(0.05);
                            end
                        end
                    end
                    if apiopts.batchSave
                        if ~isempty(items)
                            if apiopts.saveParams
                                data = struct('items', items, 'params', params, 'apiopts', apiopts);
                                vartosave = 'data';
                            else
                                vartosave = 'items';
                            end
                            timestamp = datestr(datetime, 'yyyymmddhhMMssFFF');
                            save("data/data" + timestamp, vartosave);
                        end
                    end
                end
                if ~apiopts.batchSave
                    res = obj.TU.unique(items, 'id');
                end
                tof = apiopts.toFile;
                if tof
                    if endsWith(tof, {'xlsx', 'xls', 'csv', 'txt'})
                        writetable(items, tof);
                    else
                        save(tof, 'items');
                    end
                end
            else
                [res, err] = obj.call_api(method, params);
                res.items = obj.extract(res, 'items');
            end
            function [res, err] = getBatch(obj, method, params, ds, n, p)
                params.date_from = ds(n);
                params.date_to = ds(n + 1);
                params.per_page = 100;
                params.page = p - 1;
                [res, err] = obj.call_api(method, params);
            end
        end
        
    end
end
