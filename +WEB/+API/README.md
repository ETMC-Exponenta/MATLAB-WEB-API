[English](#web-api-key-components-description-gb) | [Русский](#Описание-основных-компонентов-web-api-ru)

# WEB API key components description :gb:

Key components for any WEB API.

## [Common](Common.m)

Common class that any WEB API inherits. Contains methods required for API building:
- **prepare_params** - preparing of WEB API method calling parameters
- **extract** - extraction of data arrays from response

## [Auth](Auth.m)

Use this class to add to your WEB API OAuth 1.0 ([example](../Flickr.m)) and OAuth 2.0 ([example](../VK.m)) support.

## [Req](Req.m)

Library for HTTP WEB requests. More handy alternative to builtin [webread](https://www.mathworks.com/help/matlab/ref/webread.html) and [webwrite](https://www.mathworks.com/help/matlab/ref/webwrite.html).

[Example](../../examples/req_example.m) of using.

#### Main functions:
- `seturl` - set request base URL
- `addurl` - add method to request URL
- `getfullurl` - get full URL with query parameters
- `addquery` - add a query parameter
- `addbody` - add body field
- `addheader` - add header field
- `setopts` - set request options (see [weboptions](https://www.mathworks.com/help/matlab/ref/weboptions.html))
- `get`, `post`, `put`, `delete`, `patch` - perform request

#### All functions:
`doc WEB.API.Req`



# Описание основных компонентов WEB API :ru:

Ключевые компоненты для создания любого WEB API.

## [Common](Common.m)

Общий класс, который наследует каждый WEB API. Содержит методы, необходимые для построения API:
- **prepare_params** - подготовка параметров, которые передаются при вызове конкретонго метода WEB API
- **extract** - извлечение массивов данных из результата запроса

## [Auth](Auth.m)

Этот класс позволяет добавить в WEB API поддержку авторизации OAuth 1.0 ([пример](../Flickr.m)) и OAuth 2.0 ([пример](../VK.m))

## [Req](Req.m)

Библиотека для создания и выполнения HTTP WEB запросов. Является более удобной альтернативой применению команд [webread](https://www.mathworks.com/help/matlab/ref/webread.html), [webwrite](https://www.mathworks.com/help/matlab/ref/webwrite.html).

[Пример](../../examples/req_example.m) использования.

#### Основные функции:
- `seturl` - установить адрес запроса
- `addurl` - добавить к адресу название метода
- `getfullurl` - получить полный адрес с учетом параметров запроса
- `addquery` - добавить параметр запроса
- `addbody` - добавить тело запроса
- `addheader` - добавить заголовок запроса
- `setopts` - задать настройки запроса (см. [weboptions](https://www.mathworks.com/help/matlab/ref/weboptions.html))
- `get`, `post`, `put`, `delete`, `patch` - выполнить запрос

#### Все функции:
`doc WEB.API.Req`