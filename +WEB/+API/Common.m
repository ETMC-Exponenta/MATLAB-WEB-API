classdef (Abstract) Common < handle
    % API Common Class
    
    properties
        
    end
    
    methods
        function obj = Common()
            %API Construct an instance of this class
        end
        
        function [params, apiopts] = prepare_params(~, ps, vars)
            %% Prepare method parameters
            if ~isempty(ps)
                reqps = ps(ps(:, 2) == "required", :);
                optps = ps(ps(:, 2) == "optional", :);
                paropps = ps(ismember(ps(:, 2), {'optional', 'apiOption'}), :);
                apips = ps(ps(:, 2) == "apiOption", :);
                params = struct();
                apiopts = struct();
                if ~isempty(paropps)
                    p = inputParser;
                    for i = 1 : size(paropps, 1)
                        addParameter(p, paropps{i, 1}, paropps{i, 3});
                    end
                    parse(p, vars{:});
                    params = p.Results;
                    params = rmfield(params, intersect(p.UsingDefaults, optps(:,1)));
                end
                for i = 1 : size(reqps, 1)
                    params.(reqps{i, 1}) = (reqps{i, 3});
                end
                for i = 1 : size(apips, 1)
                    fname = apips{i, 1};
                    apiopts.(fname) = params.(fname);
                    params = rmfield(params, fname);
                end
            else
                params = {};
                apiopts = {};
            end
        end
        
        function [items, count] = extract(~, resp, name)
            %% Extract items from repsonse
            if isfield(resp, name)
                items = resp.(name);
            else
                items = resp;
            end
            if isstruct(items)
                items = struct2table(items, 'AsArray', 1);
            end
            if isfield(resp, 'count')
                count = resp.count;
            else
                count = [];
            end
        end
        
    end
end

