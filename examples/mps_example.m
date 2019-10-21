%% Create service object
addr = 'http://<address>:<port>'; % enter your MATLAB Production Server address
app = '...'; % enter your deployed application name
mps = WEB.MPS(addr, app);
%% Get server health
mps.health()
%% Services discovery
[res, err] = mps.discovery()
%% Execute deployed function
mps.setOutputFormat('mode', 'large'); % set output format (optional)
fcnname = '...'; % deployed function name
argsin = {'...'}; % input arguments
nargsout = 1; % number of output arguments
[res, err] = mps.exec(fcnname, argsin, nargsout)