# MATLAB WEB API
![MATLAB WEB API Cover](/cover.png)

[English](#description-gb) | [Русский](#Описание-ru)

## Description :gb:

Framework for building handy WEB APIs to work with any WEB services from MATLAB

[Follow project on MathWorks File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/68611)

#### Key features:

* Set of methods, templates and examples for quick creation of WEB API to work with any WEB service from MATLAB
* Library to work with WEB requests
* Support of OAuth 1.0, OAuth 2.0 access protocols
#### At the moment, the work with services is partially done:
* [Bing Maps](https://www.bing.com/maps) - Mapping service
* [Data.gov.ru](http://data.gov.ru/) - Open data of Russian Federation
* [Flickr](http://flickr.com/) - Photohosting ![OAuth logo](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Oauth_logo.svg/16px-Oauth_logo.svg.png "OAuth 1.0")
* [HeadHunter](http://hh.com/) - Russian recruiting service
* [ip-api.com](http://ip-api.com) - IP geolocation
* [NetSuite](http://www.netsuite.com/portal/home.shtml) - CRM system ![OAuth logo](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Oauth_logo.svg/16px-Oauth_logo.svg.png "OAuth 1.0")
* [OpenWeatherMap](https://openweathermap.org/) - Weather service
* [REST Countries](http://restcountries.eu) - Countries information
* [uinames.com](https://uinames.com/) - Random names generator
* [VK](https://vk.com/) - Russian social network ![OAuth 2.0 logo](https://cdn-images-1.medium.com/max/16/0*QWNG5EAnPSaUSAHH.png "OAuth 2.0")

**[Welcome aboard!](https://git-scm.com/book/en/v2/GitHub-Contributing-to-a-Project) Together we will add more of services API and improve the existing.**

## How to install

### For use only

#### 1st approach (install from scratch)

In MATLAB execute:

```matlab
eval(webread('https://exponenta.ru/install/web'))
```
#### 2nd approach (install from scratch)

* Download [MATLAB-WEB-API.mltbx](https://roslovets.github.io/ghbin#ETMC-Exponenta/MATLAB-WEB-API#MATLAB-WEB-API.mltbx)
* Open it

#### 3rd approach (update installed)

Check the current and latest versions:
```matlab
WEB.API.Ver
```
Update to the latest version:
```matlab
WEB.API.Update
```

### For development

* Install [Git](https://git-scm.com/downloads)
* [Learn](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics) how to use Git
* In OS command line execute:
```bash
git clone https://github.com/ETMC-Exponenta/MATLAB-WEB-API.git
```

## Where to start

Start with [examples](/examples):

```matlab
WEB.API.Examples
```
*Note: to work with some WEB Services you need to register and get access keys. See particular Service Developer documentation*

Examine documentation:

```matlab
WEB.API.Doc
```

---
## Описание :ru:

Фреймворк для создания удобных WEB API для работы с любыми WEB-сервисами из MATLAB

[Страница проекта на MathWorks File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/68611)

#### Ключевые особенности:

* Набор методов, шаблонов и примеров для быстрого создания WEB API для работы с любым WEB-сервисом из MATLAB
* Библиотека для работы с WEB-запросами
* Поддержка протоколов авторизации OAuth 1.0, OAuth 2.0
#### На данный момент частично реализована работа с сервисами:
* [Bing Maps](https://www.bing.com/maps) - картографический сервис
* [Data.gov.ru](http://data.gov.ru/) - открытые данные России
* [Flickr](http://flickr.com/) - фотохостинг ![OAuth logo](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Oauth_logo.svg/16px-Oauth_logo.svg.png "OAuth 1.0")
* [HeadHunter](http://hh.com/) - сервис поиска работы
* [ip-api.com](http://ip-api.com) - геолокация оп IP
* [NetSuite](http://www.netsuite.com/portal/home.shtml) - CRM-система ![OAuth logo](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Oauth_logo.svg/16px-Oauth_logo.svg.png "OAuth 1.0")
* [OpenWeatherMap](https://openweathermap.org/) - сервис погоды
* [REST Countries](http://restcountries.eu) - информация о странах
* [uinames.com](https://uinames.com/) - генератор случайных имён
* [VK](https://vk.com/) - российская социальная сеть ![OAuth 2.0 logo](https://cdn-images-1.medium.com/max/16/0*QWNG5EAnPSaUSAHH.png "OAuth 2.0")

**[Присоединяйтесь!](https://git-scm.com/book/ru/v2/GitHub-Внесение-собственного-вклада-в-проекты) Вместе мы добавим больше сервисов и улучшим работу с имеющимися.**

## Как установить

### Только для использования

#### Способ 1 (установка с нуля)

В MATLAB выполните:

```matlab
eval(webread('https://exponenta.ru/install/web'))
```
#### Способ 2 (установка с нуля)

* Скачайте [MATLAB-WEB-API.mltbx](https://roslovets.github.io/ghbin#ETMC-Exponenta/MATLAB-WEB-API#MATLAB-WEB-API.mltbx)
* Откройте его

#### Способ 3 (обновление)

Узнать текущую и последнюю версии:
```matlab
WEB.API.Ver
```
Обновление до последней версии:
```matlab
WEB.API.Update
```

### Для разработчиков

* Установите [Git](https://git-scm.com/downloads)
* [Изучите](https://git-scm.com/book/ru/v2/%D0%92%D0%B2%D0%B5%D0%B4%D0%B5%D0%BD%D0%B8%D0%B5-%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git) основы работы с Git
* В командной строке ОС выполните:
```bash
git clone https://github.com/ETMC-Exponenta/MATLAB-WEB-API.git
```

## С чего начать

Начните с изучения [примеров](/examples):
```matlab
WEB.API.Examples
```

*Обратите внимание: для работы с некоторыми сервисами вам потребуется зарегистрироваться и получить ключи доступа. Изучайте документацию для разработчиков соответствующих сервисов*

Изучите документацию:

```matlab
WEB.API.Doc
```
