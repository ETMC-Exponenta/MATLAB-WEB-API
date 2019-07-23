%% Create service object
rc = WEB.RESTCountries();
%% Get all info
res = rc.all()
res = rc.all('fields', 'name;capital;region;population;area')
%% Get by country name
res = rc.byName('Russia')
res = rc.byName('Russian Federation', 'fullText', true)
%% Get by code
res = rc.byCode('RU')
res = rc.byCode({'US','GB'})
%% Get by currency code
res = rc.byCurrency('USD')
%% Get by region
res = rc.byRegion('Africa')
res = rc.byRegion('Asia', 'fields', 'name;capital')