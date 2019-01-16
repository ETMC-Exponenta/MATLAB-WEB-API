classdef Plotter
    % Helper functions for plotting
    
    methods
        function obj = Plotter()
            % Plotter Construct an instance of this class
        end
        
        function g = geoBubble(~, gc, varargin)
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
            figure;
            g = geobubble(gc(:, 1), gc(:, 2), size, color);
            if ~isempty(p.Results.Title)
                g.Title = p.Results.Title;
            end
        end
        
        function g = geoScatter(~, gc, varargin)
            %% Plot geoscatter map
            p = inputParser;
            p.addRequired('gc');
            p.addParameter('Size', []);
            p.addParameter('Color', [0 0 1]);
            p.addParameter('Tips', '');
            p.addParameter('Title', '');
            p.parse(gc, varargin{:});
            size = p.Results.Size;
            color = p.Results.Color;
            figure;
            g = geoscatter(gc(:, 1), gc(:, 2), size * 2000, color, '.');
            if ~isempty(p.Results.Title)
                title(p.Results.Title);
            end
            if ~isempty(p.Results.Tips)
                dcm = datacursormode(gcf);
                dcm.UpdateFcn = @(~, e) pointtips([], e, p.Results.Tips);
            end
            function txt = pointtips(~, event_obj, tips)
                % Customizes text of data tips
                i = event_obj.DataIndex;
                txt = tips(i, :)';
            end
        end
        
        function ax = image(~, im, varargin)
            %% Plot image
            p = inputParser;
            p.addRequired('im');
            p.addParameter('title', '');
            p.parse(im, varargin{:});
            figure;
            image(im);
            ax = gca;
            ax.Visible = 'off';
            if ~isempty(p.Results.title)
                ax.Title = p.Results.title;
            end
        end
        
    end
end

