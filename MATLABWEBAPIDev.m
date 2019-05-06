classdef MATLABWEBAPIDev < handle
    % Helps you to build toolbox and deploy it to GitHub
    % By Pavel Roslovets, ETMC Exponenta
    % https://github.com/ETMC-Exponenta/ToolboxExtender
    
    properties
        TE % Toolbox Extender
        vp % project version
    end
    
    methods
        function obj = MATLABWEBAPIDev(extender)
            % Init
            if nargin < 1
                obj.TE = MATLABWEBAPIExtender;
            else
                if ischar(extender) || isStringScalar(extender)
                    obj.TE = MATLABWEBAPIExtender(extender);
                else
                    obj.TE = extender;
                end
            end
            if ~strcmp(obj.TE.root, pwd)
                warning("Project root folder does not math with current folder." +...
                    newline + "Consider to change folder, delete installed toolbox or restart MATLAB")
            end
            obj.gvp();
        end
        
        function vp = gvp(obj)
            % Get project version
            ppath = obj.TE.getppath();
            if isfile(ppath)
                if obj.TE.type == "toolbox"
                    vp = matlab.addons.toolbox.toolboxVersion(ppath);
                else
                    txt = obj.TE.readtxt(ppath);
                    vp = char(regexp(txt, '(?<=(<param.version>))(.*?)(?=(</param.version>))', 'match'));
                end
            else
                vp = '';
            end
            obj.vp = vp;
        end
        
        function build(obj, vp, gendoc)
            % Build toolbox for specified version
            ppath = obj.TE.getppath();
            if nargin < 3
                gendoc = true;
            end
            if gendoc
                obj.gendoc();
            end
            if nargin > 1 && ~isempty(vp)
                if obj.TE.type == "toolbox"
                    matlab.addons.toolbox.toolboxVersion(ppath, vp);
                else
                    txt = obj.TE.readtxt(ppath);
                    txt = regexprep(txt, '(?<=(<param.version>))(.*?)(?=(</param.version>))', vp);
                    txt = strrep(txt, '<param.version />', '');
                    obj.TE.writetxt(txt, ppath);
                end
            end
            [~, bname] = fileparts(obj.TE.pname);
            bpath = fullfile(obj.TE.root, bname);
            if obj.TE.type == "toolbox"
                obj.updateroot();
                obj.seticons();
                matlab.addons.toolbox.packageToolbox(ppath, bname);
            else
                matlab.apputil.package(ppath);
                movefile(fullfile(obj.TE.root, obj.TE.name + ".mlappinstall"), bpath + ".mlappinstall",'f');
            end
            obj.TE.echo('has been built');
        end
        
        function test(obj, gendoc)
            % Build and install
            if nargin < 2
                gendoc = false;
            end
            obj.build(obj.vp, gendoc);
            obj.TE.install();
        end
        
        function untag(obj, v)
            % Delete tag from local and remote
            untagcmd1 = sprintf('git push --delete origin v%s', v);
            untagcmd2 = sprintf('git tag -d v%s', v);
            system(untagcmd1);
            system(untagcmd2);
            system('git push --tags');
            obj.TE.echo('has been untagged');
        end
        
        function release(obj, vp)
            % Build toolbox, push and tag version
            if nargin > 1
                obj.vp = vp;
            else
                vp = '';
            end
            if ~isempty(obj.TE.pname)
                obj.build(vp);
            end
            obj.push();
            obj.tag();
            obj.TE.echo('has been deployed');
            if ~isempty(obj.TE.pname)
                clipboard('copy', ['"' char(obj.TE.getbinpath) '"'])
                disp("Binary path was copied to clipboard")
            end
            disp("* Now create release on GitHub page with binary attached *")
            pause(1)
            web(obj.TE.remote + "/releases/edit/v" + obj.vp, '-browser')
        end
        
    end
    
    
    methods (Hidden)
        
        function updateroot(obj)
            % Update project root
            service = com.mathworks.toolbox_packaging.services.ToolboxPackagingService;
            configKey = service.openProject(obj.TE.getppath());
            service.removeToolboxRoot(configKey);
            service.setToolboxRoot(configKey, obj.TE.root);
            service.closeProject(configKey);
        end
        
        function gendoc(obj)
            % Generate html from mlx doc
            docdir = fullfile(obj.TE.root, 'doc');
            fs = struct2table(dir(fullfile(docdir, '*.mlx')), 'AsArray', true);
            fs = convertvars(fs, 1:3, 'string');
            for i = 1 : height(fs)
                [~, fname] = fileparts(fs.name(i));
                fprintf('Converting %s...\n', fname);
                fpath = fullfile(fs.folder(i), fs.name{i});
                htmlpath = fullfile(fs.folder(i), fname + ".html");
                matlab.internal.liveeditor.openAndConvert(char(fpath), char(htmlpath));
                disp('Doc has been generated');
            end
        end
        
        function seticons(obj)
            % Set icons of app in toolbox
            xmlfile = 'DesktopToolset.xml';
            oldtxt = '<icon filename="matlab_app_generic_icon_' + string([16; 24]) + '"/>';
            newtxt = '<icon path="./" filename="icon_' + string([16; 24]) + '.png"/>';
            if isfile(xmlfile) && isfolder('resources')
                if all(isfile("resources/icon_" + [16 24] + ".png"))
                    txt = obj.TE.readtxt(xmlfile);
                    if contains(txt, oldtxt)
                        txt = replace(txt, oldtxt, newtxt);
                        obj.TE.writetxt(txt, xmlfile);
                    end
                end
            end
        end
        
        function push(obj)
            % Commit and push project to GitHub
            commitcmd = sprintf('git commit -m v%s', obj.vp);
            system('git add .');
            system(commitcmd);
            system('git push');
            obj.TE.echo('has been pushed');
        end
        
        function tag(obj)
            % Tag git project and push tag
            tagcmd = sprintf('git tag -a v%s -m v%s', obj.vp, obj.vp);
            system(tagcmd);
            system('git push --tags');
            obj.TE.echo('has been tagged');
        end
        
    end
    
end

