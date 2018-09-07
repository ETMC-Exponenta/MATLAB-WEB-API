%% Set auth data
app_key = '...';  % place here your App Key
app_secret = '...';  % place here your App Secret
%% Create service object
fl = WEB.Flickr(app_key, app_secret);
%% Set data path
fl.set_data_path('../data/');
%% Get Token
res = fl.login()
%% Test Login
res = fl.test_login()
%% Test Echo
res = fl.test_echo()
%% Get Photos
photos = fl.groups_getPhotos('967057@N23')
%% Get Available Sizes
sizes = fl.photos_getSizes(photos.photo.id{1})
%% Get Photo
photo = fl.get_photo(photos.photo.id{1}, 'size', 'medium', 'show', 1);
%% Save Photo
photo = fl.get_photo(photos.photo.id{1}, 'size', 'original', 'show', 1, 'save', 1, 'name', 'pic.jpg');
%% Search Photos
photos = fl.photos_search('text', 'cat', 'tags', 'cat')
%% Log Out
fl.logout();