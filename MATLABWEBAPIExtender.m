classdef MATLABWEBAPIExtender < handle
    % Contains core functions. Required for other classes and functionality
    % By Pavel Roslovets, ETMC Exponenta
    % https://github.com/ETMC-Exponenta/ToolboxExtender
    
    properties
        name % project name
        pname % name of project file
        type % type of project
        root % root dir
        remote % GitHub link
        vc % current installed version
        extv % Toolbox Extender version
    end
    
    properties (Hidden)
        config = 'ToolboxConfig.xml' % configuration file name
    end
    
    methods
        function obj = MATLABWEBAPIExtender(root)
            % Init
            if nargin < 1
                obj.root = fileparts(mfilename('fullpath'));
            else
                obj.root = root;
            end
        end
        
        function set.root(obj, root)
            % Set root path
            obj.root = root;
            if ~obj.readconfig()
                obj.getpname();
                obj.gettype();
                obj.getname();
                obj.getremote();
            end
            obj.gvc();
        end
        
        function [vc, guid] = gvc(obj)
            % Get current installed version
            if obj.type == "toolbox"
                tbx = matlab.addons.toolbox.installedToolboxes;
                tbx = struct2table(tbx, 'AsArray', true);
                idx = strcmp(tbx.Name, obj.name);
                vc = tbx.Version(idx);
                guid = tbx.Guid(idx);
                if isscalar(vc)
                    vc = char(vc);
                elseif isempty(vc)
                    vc = '';
                else
                    vc = char(vc(end));
                end
            else
                tbx = matlab.apputil.getInstalledAppInfo;
                vc = '';
                guid = '';
            end
            obj.vc = vc;
        end
        
        function res = install(obj, fpath)
            % Install toolbox or app
            if nargin < 2
                fpath = obj.getbinpath();
            end
            if obj.type == "toolbox"
                res = matlab.addons.install(fpath);
            else
                res = matlab.apputil.install(fpath);
            end
            obj.gvc();
            obj.echo('has been installed');
        end
        
        function uninstall(obj)
            % Uninstall toolbox or app
            [~, guid] = obj.gvc();
            if isempty(guid)
                disp('Nothing to uninstall');
            else
                if obj.type == "toolbox"
                    matlab.addons.uninstall(char(guid));
                else
                    matlab.apputil.uninstall(char(guid));
                end
                disp('Uninstalled');
                try
                    obj.gvc();
                end
            end
        end
        
        function doc(obj, name)
            % Open page from documentation
            if (nargin < 2) || isempty(name)
                name = 'GettingStarted';
            end
            if ~any(endsWith(name, {'.mlx' '.html'}))
                name = name + ".html";
            end
            docpath = fullfile(obj.root, 'doc', name);
            if endsWith(name, '.html')
                web(docpath);
            else
                open(docpath);
            end
        end
        
        function examples(obj)
            % cd to Examples dir
            expath = fullfile(obj.root, 'examples');
            cd(expath);
        end
        
        function web(obj)
            % Open GitHub page
            web(obj.remote, '-browser');
        end
        
    end
    
    
    methods (Hidden)
        
        function echo(obj, msg)
            % Display service message
            fprintf('%s %s\n', obj.name, msg);
        end
        
        function name = getname(obj)
            % Get project name from project file
            name = '';
            ppath = obj.getppath();
            if isfile(ppath)
                txt = obj.readtxt(ppath);
                name = char(extractBetween(txt, '<param.appname>', '</param.appname>'));
            end
            obj.name = name;
        end
        
        function pname = getpname(obj)
            % Get project file name
            fs = dir(fullfile(obj.root, '*.prj'));
            if ~isempty(fs)
                names = {fs.name};
                isproj = false(1, length(names));
                for i = 1 : length(names)
                    txt = obj.readtxt(fullfile(obj.root, names{i}));
                    isproj(i) = ~contains(txt, '<MATLABProject');
                end
                if any(isproj)
                    names = names(isproj);
                    pname = names{1};
                    obj.pname = pname;
                else
                    warning('Project file was not found in a current folder');
                end
            else
                warning('Project file was not found in a current folder');
            end
        end
        
        function ppath = getppath(obj)
            % Get project file full path
            if ~isempty(obj.pname)
                ppath = fullfile(obj.root, obj.pname);
            else
                ppath = '';
            end
        end
        
        function type = gettype(obj)
            % Get project type (Toolbox/App)
            ppath = obj.getppath();
            txt = obj.readtxt(ppath);
            if contains(txt, 'plugin.toolbox')
                type = 'toolbox';
            elseif contains(txt, 'plugin.apptool')
                type = 'app';
            else
                type = '';
            end
            obj.type = type;
        end
        
        function remote = getremote(obj)
            % Get remote (GitHub) address via Git
            [~, cmdout] = system('git remote -v');
            remote = extractBetween(cmdout, 'https://', '.git', 'Boundaries', 'inclusive');
            if isempty(remote)
                remote = extractBetween(cmdout, 'https://', '(', 'Boundaries', 'inclusive');
                remote = strtrim(erase(remote, '('));
            end
            if ~isempty(remote)
                remote = remote(end);
            end
            remote = char(remote);
            obj.remote = remote;
        end
        
        function name = getvalidname(obj)
            % Get valid variable name
            name = char(obj.name);
            name = name(isstrprop(name, 'alpha'));
        end
        
        function txt = readtxt(~, fpath)
            % Read text from file
            if isfile(fpath)
                f = fopen(fpath, 'r', 'n', 'windows-1251');
                txt = fread(f, '*char')';
                fclose(f);
            else
                txt = '';
            end
        end
        
        function writetxt(~, txt, fpath)
            % Wtite text to file
            if isfile(fpath)
                fid = fopen(fpath, 'w', 'n', 'windows-1251');
                fwrite(fid, unicode2native(txt, 'windows-1251'));
                fclose(fid);
            end
        end
        
        function txt = txtrep(obj, fpath, old, new)
            % Replace in txt file
            txt = obj.readtxt(fpath);
            txt = replace(txt, old, new);
            obj.writetxt(txt, fpath);
        end
        
        function bpath = getbinpath(obj)
            % Get generated binary file path
            [~, name] = fileparts(obj.pname);
            if obj.type == "toolbox"
                ext = ".mltbx";
            else
                ext = ".mlappinstall";
            end
            bpath = fullfile(obj.root, name + ext);
        end
        
        function ok = readconfig(obj)
            % Read config from xml file
            confpath = fullfile(obj.root, obj.config);
            ok = isfile(confpath);
            if ok
                xml = xmlread(confpath);
                conf = obj.getxmlitem(xml, 'config', 0);
                obj.name = obj.getxmlitem(conf, 'name');
                obj.pname = obj.getxmlitem(conf, 'pname');
                obj.type = obj.getxmlitem(conf, 'type');
                obj.remote = erase(obj.getxmlitem(conf, 'remote'), '.git');
                obj.extv = obj.getxmlitem(conf, 'extv');
            end
        end
        
        function i = getxmlitem(~, xml, name, getData)
            % Get item from XML
            if nargin < 4
                getData = true;
            end
            i = xml.getElementsByTagName(name);
            i = i.item(0);
            if getData
                i = i.getFirstChild;
                if ~isempty(i)
                    i = i.getData;
                end
                i = char(i);
            end
        end
        
    end
end