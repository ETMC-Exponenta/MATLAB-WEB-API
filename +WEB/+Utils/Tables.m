classdef Tables
    % Additional functions for tables
    
    methods
        function obj = Tables()
            % Tables Construct an instance of this class
        end
        
        function ss = concat(obj, ss, preserveFormat)
            %% Fix VK Response
            ist = false;
            if iscell(ss)
                ss = ss(:);
                emp = cellfun('isempty', ss);
                if all(emp)
                    ss = {};
                elseif any(emp)
                    ss = ss(~emp);
                end
                if ~isempty(ss)
                    ist = cellfun(@istable, ss);
                    ss(ist) = cellfun(@(x) table2struct(x), ss(ist), 'un', 0);
                    fs = cellfun(@(x) fieldnames(x), ss, 'un', 0);
                    fs = reshape(vertcat(fs{:}), [], 1);
                    fs = unique(fs);
                    ss = obj.fill_empty(ss, fs);
                    ss = vertcat(ss{:});
                end
                if any(ist) || nargin < 3 || ~preserveFormat
                    if isstruct(ss)
                        ss = struct2table(ss, 'AsArray', true);
                    end
                end
            end
        end
        
        function ss = fill_empty(obj, ss, fields, emptvals)
            %% Fill absent values with empty
            if nargin < 4
                emptvals = {-1, ''};
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
                        e = emptvals{1};
                    else
                        e = emptvals{2};
                    end
                else
                    tc = cellfun(@(x, f) class(getfield(x, f)), ss(fex), repmat(f, length(ss(fex)), 1), 'un', 0);
                    if length(unique(tc)) == 1 && tc{1} == "double"
                        e = emptvals{1};
                    else
                        e = emptvals{2};
                    end
                end
                ss(~fex) = obj.addfield(ss(~fex), f{1}, e);
            end
            if ist
                ss = struct2table(ss{1}, 'AsArray', true);
            end
        end

        function a = cell2double(~, c, fs)
            %% Convert cell array of doubles to numeric array
            ist = istable(c);
            if ist
                t = c;
                c = t{:, fs};
            end
            c = cellfun(@double, c, 'un', 0);
            ise = cellfun('isempty', c);
            c(ise) = {NaN};
            a = cell2mat(c);
            if ist
                fs = string(fs);
                for i = 1 : length(fs)
                    t.(fs(i)) = a(:, i);
                end
                a = t;
            end
        end
        
        function T = cm2table(obj, cm)
            %% Convert containers.Map to table
            k = keys(cm)';
            v = values(cm)';
            if istable(v{1}) || isstruct(v{1})
                v = obj.concat(v);
            else
                v = reshape([v{:}], 2, [])';
            end
            T = table(k, v, 'VariableNames', {'Keys' 'Values'});
        end
        
        function t = fillmissingfrom(~, t, var1, var2)
            %% Fill empty values in var1 with values from var2
            ise = ismissing(t{:, var1});
            t{ise, var1} = t{ise, var2};
        end
        
        function ss = addfield(~, ss, f, val)
            %% Add field to struct cell
            isc = iscell(ss);
            ist = istable(ss);
            if ist, ss = table2struct(ss); end
            if ~isc, ss = {ss}; end
            if ~iscell(val), val = {val}; end
            addfwrap = @(x) addfield_helper(x, f, val);
            ss = cellfun(@(x) addfwrap(x), ss, 'un', 0);
            function x = addfield_helper(x, f, e)
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
            if ist
                s = table2struct(s);
            end
            if isfield(s, f)
                vals = {s.(f)}';
                isVal = ~cellfun('isempty', vals);
                hasField = false(size(isVal));
                hasField(isVal) = cellfun(@(c) isfield(c, subf), vals(isVal));
                vals(hasField) = cellfun(@(c) c.(subf), vals(hasField), 'un', 0);
                c = cellfun(@class, vals(hasField), 'un', 0);
                c = unique(c);
                if length(c) == 1
                    if c == "double"
                        emp = {-1};
                    elseif c == "char"
                        emp = {''};
                    end
                    vals(~hasField) = emp;
                end
                [s.(newf)] = vals{:};
            end
            if ist, s = struct2table(s, 'AsArray', true); end
        end
        
        function t = expand(obj, t, f, preserve, append_names)
            %% Expand table's structure variable to new variables
            if nargin < 4
                preserve = false;
            end
            if nargin < 5
                append_names = true;
            end
            newt = obj.concat(t{:, f});
            if isstruct(newt)
                newt = struct2table(newt);
            end
            vnames = newt.Properties.VariableNames;
            if append_names
                vnames = f + "_" + vnames;
            end
            newt.Properties.VariableNames = vnames;
            t = [t newt];
            if ~preserve
                t(:, f) = [];
            end
        end
        
        function t = rmvars(~, t, vars)
            %% Remove vars from table
            if ~iscell(vars)
                vars = {vars};
            end
            isVar = ismember(vars, t.Properties.VariableNames);
            rmVar = vars(isVar);
            if ~isempty(rmVar)
                t = removevars(t, rmVar);
            end
        end
        
        function t = selectvars(~, t, vnames)
            %% Order variables
            if isa(vnames, 'containers.Map')
                vnames = keys(vnames);
            end
            t = t(:, vnames);
        end
        
        function t = count(~, vec, vname)
            %% Count occurences in vector
            vec = categorical(vec);
            t = table(categories(vec), countcats(vec), 'VariableNames', {vname, 'count'});
        end
        
        function t = unique(~, t, vname)
            %% Unique rows in table by vname
            [~, ia] = unique(t{:, vname});
            t = t(ia, :);
        end
    end
end

