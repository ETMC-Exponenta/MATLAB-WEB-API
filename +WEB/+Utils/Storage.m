classdef Storage < handle
    % Storage Class
    
    properties
        data % data
        path % data path
        file = 'data.mat' % data file
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
        
    end
end

