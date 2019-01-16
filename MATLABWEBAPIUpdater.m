classdef MATLABWEBAPIUpdater < handle
    % Control version of installed toolbox and update it from GitHub
    % By Pavel Roslovets, ETMC Exponenta
    % https://github.com/ETMC-Exponenta/ToolboxExtender
    
    properties
        TE % Toolbox Extender
        vr % latest remote version form internet (GitHub)
    end
    
    methods
        function obj = MATLABWEBAPIUpdater(extender)
            % Init
            if nargin < 1
                obj.TE = MATLABWEBAPIExtender;
            else
                obj.TE = extender;
            end
        end        
        
        function [vr, r] = gvr(obj)
            % Get remote version from GitHub
            iname = string(extractAfter(obj.TE.remote, 'https://github.com/'));
            url = "https://api.github.com/repos/" + iname + "/releases/latest";
            try
                r = webread(url);
                vr = r.tag_name;
                vr = erase(vr, 'v');
            catch
                vr = '';
                r = '';
            end
            obj.vr = vr;
        end
        
        function [vc, vr] = ver(obj)
            % Check curent installed and remote versions
            vc = obj.TE.gvc();
            if nargout == 0
                if isempty(vc)
                    fprintf('%s is not installed\n', obj.TE.name);
                else
                    fprintf('Installed version: %s\n', vc);
                end
            end
            % Check remote version
            vr = obj.gvr();
            if nargout == 0
                if ~isempty(vr)
                    fprintf('Latest version: %s\n', vr);
                    if isequal(vc, vr)
                        fprintf('You use the latest version\n');
                    else
                        fprintf('* Update is available: %s->%s *\n', vc, vr);
                        fprintf("To update call 'update' method of " + mfilename + "\n");
                    end
                else
                    fprintf('No remote version is available\n');
                end
            end
        end
        
        function yes = isonline(~)
            % Check connection to internet is available
            try
                java.net.InetAddress.getByName('google.com');
                yes = true;
            catch
                yes = false;
            end
        end
        
        function [isupd, r] = isupdate(obj)
            % Check that update is available
            if obj.isonline()
                vc = obj.TE.gvc();
                [vr, r] = obj.gvr();
                isupd = ~isempty(vr) & ~isequal(vc, vr);
            else
                r = [];
                isupd = false;
            end
        end
        
        function installweb(obj, r)
            % Download and install latest version from remote (GitHub)
            if nargin < 2
                [~, r] = obj.gvr();
            end
            fprintf('* Installation of %s is started *\n', obj.TE.name);
            fprintf('Installing the latest version: v%s...\n', obj.vr);
            dpath = tempname;
            mkdir(dpath);
            fpath = fullfile(dpath, r.assets.name);
            websave(fpath, r.assets.browser_download_url);
            res = obj.TE.install(fpath);
            fprintf('%s v%s has been installed\n', res.Name{1}, res.Version{1});
            delete(fpath);
        end
        
        function update(obj)
            % Update installed version to the latest from remote (GitHub)
            [isupd, r] = obj.isupdate();
            if isupd
                obj.installweb(r);
            end
        end
        
    end
end

