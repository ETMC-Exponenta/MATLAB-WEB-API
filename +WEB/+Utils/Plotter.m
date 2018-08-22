classdef Plotter
    % Helper functions for plotting
    
    methods
        function obj = Plotter()
            % Plotter Construct an instance of this class
        end
        
        function g = map(~, gc, varargin)
            %% Plot geobubble map
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
        
        function ax = image(~, im, varargin)
            %% Plot image
            p = inputParser;
            p.addRequired('im');
            p.addParameter('title', '');
            p.parse(im, varargin{:});
            image(im);
            ax = gca;
            ax.Toolbar.Visible = 'on';
            ax.Visible = 'off';
            removeToolbarExplorationButtons(gcf);
            if ~isempty(p.Results.title)
                ax.Title = p.Results.title;
            end
        end
        
    end
end

