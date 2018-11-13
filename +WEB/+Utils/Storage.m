classdef Storage < handle
    % Data Storage Class
    
    properties
        data % Data
        path = '' % Data Path
        file = 'data.mat' % Data File Name
    end
    
    methods
        function obj = Storage(file, path)
            %% Storage Construct an instance of this class
            obj.file = file;
            if nargin > 1
                obj.path = path;
            end
            obj.load();
        end
        
        function set.path(obj, path)
            %% Set data path
            obj.path = path;
            obj.load();
        end
        
        function path = get.path(obj)
            %% Get path
            path = obj.path;
        end
        
        function file = get.file(obj)
            %% Get file name
            file = obj.file;
        end
        
        function set.file(obj, file)
            %% Set file name
            obj.file = file;
            obj.load();
        end
        
        function data = get.data(obj)
            %% Get data
            data = obj.data;
        end
        
        function set.data(obj, data)
            %% Set data
            obj.data = data;
        end
        
        function fp = fullpath(obj)
            %% Full path to data
            fp = fullfile(obj.path, obj.file);
        end
        
        function data = load(obj)
            %% Load data from file
            if isfile(obj.fullpath())
                load(obj.fullpath(), 'data');
            else
                data = [];
            end
            obj.data = data;
        end
        
        function data = save(obj, data)
            %% Save data to file
            if nargin > 1
                obj.data = data;
            else
                data = obj.data;
            end
            save(obj.fullpath(), 'data');
        end
        
        function clear(obj)
            %% Delete data and file
            obj.data = [];
            if isfile(obj.fullpath())
                delete(obj.fullpath());
            end
        end
        
        function val = get_cm(obj, key, cm)
            %% Get from containers map
            if nargin < 3
                cm = obj.data;
            end
            val = [];
            if ~isempty(cm) && cm.isKey(key)
                val = cm(key);
            end
        end
        
        function cm = set_cm(obj, key, val, cm)
            %% Set containers map value
            if nargin < 4
                cm = obj.data;
            end
            if isempty(cm)
                cm = containers.Map();
            end
            cm(key) = val;
            if nargin < 4
                obj.data = cm;
            end
        end
        
        function imsave(obj, fname, im)
            %% Save image
            if nargin < 2
                im = obj.data;
            end
            imwrite(im, fullfile(obj.path, char(fname)));
        end
        
    end
end

