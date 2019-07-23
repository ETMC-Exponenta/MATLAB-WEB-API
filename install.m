function install
% Generated with Toolbox Extender https://github.com/ETMC-Exponenta/ToolboxExtender
dev = MATLABWEBAPIDev;
dev.test('', false);
% Post-install commands
cd('..');
ext = MATLABWEBAPIExtender;
ext.doc;
% Add your post-install commands below