[English](#web-api-description-gb) | [Русский](#Описание-основных-компонентов-web-api)

# Описание основных компонентов WEB API

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
