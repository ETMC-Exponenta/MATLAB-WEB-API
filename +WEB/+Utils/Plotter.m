classdef Plotter
    % Plotter Class
    
    properties
        
    end
    
    methods
        function obj = Plotter()
            %% Plotter Construct an instance of this class
        end
        
        function g = map(~, gc, varargin)
            %% Set data path
            p = inputParser;
            p.addRequired('gc');
            p.addParameter('Size', []);
            p.addParameter('Color', []);
            p.addParameter('Title', '');
            p.parse(gc, varargin{:});
            size = p.Results.Size;
            color = p.Results.Color;
            if ~iscategorical(color)
                color = categorical(string(color));
            end
            g = geobubble(gc(:, 1), gc(:, 2), size, color);
            if ~isempty(p.Results.Title)
                g.Title = p.Results.Title;
            end
        end
        
    end
end

