classdef Tables
    % Additional functions for tables
    
    methods
        function obj = Tables()
            % Tables Construct an instance of this class
        end
        
        function ss = concat(obj, ss)
            %% Fix VK Response
            if iscell(ss)
                ss = ss(:);
                ist = istable(ss{1});
                if ist
                    ss = cellfun(@(x) table2struct(x), ss, 'un', 0);
                end
                fs = cellfun(@(x) fieldnames(x), ss, 'un', 0);
                fs = reshape(vertcat(fs{:}), [], 1);
                fs = unique(fs);
                ss = obj.fill_empty(ss, fs);
                ss = vertcat(ss{:});
                if ist
                    ss = struct2table(ss);
                end
            end
        end
        
        function ss = fill_empty(obj, ss, fields, evals)
            %% Fill absent values with empty
            if nargin < 4
                evals = {-1, ''};
            end
            ist = istable(ss);
            if ist
                ss = {table2struct(ss)};
            end
            iscm = isa(fields, 'containers.Map');
            if iscm
                fs = keys(fields);
            else
                fs = fields;
            end
            for f = fs(:)'
                fex = cellfun(@(x, f) isfield(x, f), ss, repmat(f, length(ss), 1));
                if iscm
                    if fields(f{1}) == "double"
                        e = evals{1};
                    else
                        e = evals{2};
                    end
                else
                    tc = cellfun(@(x, f) class(getfield(x, f)), ss(fex), repmat(f, length(ss(fex)), 1), 'un', 0);
                    if length(unique(tc)) == 1 && tc{1} == "double"
                        e = evals{1};
                    else
                        e = evals{2};
                    end
                end
                ss(~fex) = obj.addfield(ss(~fex), f{1}, e);
            end
            if ist
                ss = struct2table(ss{1}, 'AsArray', true);
            end
        end
        
        function ss = addfield(~, ss, f, val)
            %% add field to struct cell
            isc = iscell(ss);
            ist = istable(ss);
            if ist, ss = table2struct(ss); end
            if ~isc, ss = {ss}; end
            if ~iscell(val), val = {val}; end
            addfwrap = @(x) addf(x, f, val);
            ss = cellfun(@(x) addfwrap(x), ss, 'un', 0);
            function x = addf(x, f, e)
                em = repmat(e, length(x), 1);
                if iscell(em)
                    [x.(f)] = em{:};
                else
                    [x.(f)] = em;
                end
            end
            if ~isc, ss = ss{1}; end
            if ist, ss = struct2table(ss, 'AsArray', true); end
        end
        
        function s = extract(~, s, f, subf, newf)
            %% Extract subfield from field
            if nargin < 5
                newf = f;
            end
            ist = istable(s);
            if ist, s = table2struct(s); end
            if isfield(s, f)
                vals = {s.(f)}';
                isVal = ~cellfun('isempty', vals);
                vals(isVal) = cellfun(@(c) c.(subf), vals(isVal), 'un', 0);
                c = cellfun(@class, vals(isVal), 'un', 0);
                c = unique(c);
                if (length(c) == 1) && (c == "double")
                    vals(~isVal) = {-1};
                end
                [s.(newf)] = vals{:};
            end
            if ist, s = struct2table(s, 'AsArray', true); end
        end
        
        function t = rmvars(~, t, vars)
            %% Remove vars from table
            if ~iscell(vars), vars = {vars}; end
            isVar = ismember(vars, t.Properties.VariableNames);
            rmVar = vars(isVar);
            if ~isempty(rmVar)
                t = removevars(t, rmVar);
            end
        end
        
        function t = ordervars(~, t, vnames)
            %% Order variables
            if isa(vnames, 'containers.Map')
                vnames = keys(vnames);
            end
            t = t(:, vnames);
        end
        
        function t = count(~, vec, vname)
            %% Count occurances in vector
            vec = categorical(vec);
            t = table(categories(vec), countcats(vec), 'VariableNames', {vname, 'count'});
        end
    end
end

