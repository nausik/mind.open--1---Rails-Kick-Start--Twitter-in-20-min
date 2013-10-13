Ruby-on-Rails Kick-Start: A twitter-like app in 20 minutes
============================================================

Генерация проекта и начало
----------------------------------
Для начала, нужно создать проект
Откроем консоль с Ruby и введем:
```ruby
rails new twit
```
twit - имя проекта, соответственно, можно поменять

После генерации проекта, перейдем в папку с ним
cd twit

Теперь нам нужно создать scaffold для сообщений. Scaffold - полностью рабочий набор из View, Model и Controller, уже подготовленные для базового использования
Ввдем команду
```ruby
rails g scaffold Post text:text
```
где, g - сокращение от generate, Post - имя нашего класса (модели), text - имя нужного нам поля (т.к. нам нужны только посты, то создадим только их) и text - тип данных

Поменяем корень нашего сайта на /posts (чтобы сайт сразу выводил общий список постов)
Зайдем в папку /config и зайдем в файл routes. Допишите строку
```ruby
root :to => 'Posts#index'
```
это укажет на контроллер Posts и метод index


Аутентификация
----------------------------------
Создадим систему аутентификации. Для этого, используем гем devise
откроем Gemfile в корне проекта и добавим строку
```ruby
gem 'devise'
```

Теперь установим его
Для этого нужно ввести команду 
```ruby
rails g devise:install
```
А теперь, создадим модель для пользователя
```ruby
rails g devise User
```

Следующее что мы сделаем, это изменим вход с почты на имя пользователя. Перейдем в папку conig/initializers и откроем файл devise.rb
Теперь раскомментируем строку 
```ruby
config.authentication_keys
```
и изменим :email на :username
Еще в этом файле изменим минимальную длину пароля (по-умолчанию она равна 8 символам. Изменим до 4). Найдем строку 
```ruby
config.password_length = 8..128
```
и изменим 8 на 4

Следующее что мы сделаем, это добавим геттеры и сеттеры для имени пользователя (закон Деметра в ООП)
Для этого перейдем в папку app/models и откроем файл user.rb
Теперь нужно просто дописать к 
```ruby
attr_accessible :username
```
Все остальное руби сделает за вас

Теперь осталось только добавить поля для имени пользователя на страницу
Для этого нужно ввести команду 
```ruby
rails g devise:views
```
Это сгенерирует views, стандартные для devise

Чтобы добавить поля, нужно открыть папку app/views/devise и зайти в папку registrations
Откроем файл new.html.erb (он отвечает за новые регистрации).
Добавьте строки:
```ruby
<div><%= f.label :username %><br />
<%= f.text_field :username %></div>
```
Выделение <%= %> отвечает за руби-код, возвратимое значение которого, будет отображаться на странице
(если мы делаем что-то, что не выводится на страницу, например if, тогда выделение такое же, но бе знака равенства)
Теперь нужно проделать то же самое, но уже с файлом new.html.erb из папки sessions (она находится рядом с папкой registrations)

Следующее, что мы хотим, это добавить поле username к таблице Users в бд. Для этого в консоли нужно ввести 
```ruby
rails g migration AddUsernameToUser username:string
```
Рельсы автоматически определят то, что мы хотим сделать из названия миграции. username:string отвечает, соотвественно, за название нового поля и за тип данных в нем

Для того, чтобы вывести ссылку на выход, нужно открыть app/views/layouts и открыть единственный существующий там файл и добавить 
```ruby
<% if signed_in? %>
  Hi, <%= current_user.username %>! <%= link_to('Logout', destroy_user_session_path, :method => :delete) %>
  <hr>
<% end %>
```

signed_in? - стандартный метод для devise, который возвращает true или false в зависимости от того, вошел пользователь или нет
current_user.username - выводи имя пользователя
link_to - стандартный для рельс метод, который выводит ссылку на что-то (в данном случае на destroy_user_session_path с запросом delete)

Авторизация
----------------------------------
Для авторизации нужно добавить гем cancan (Gemfile в корне проекта -> gem 'cancan')

Следующее что нам нужно, это сгенерировать файл с "возможностями" каждой пользовательской группы. Для этого нужно ввести в консоли 
```ruby
rails g cancan:ability
```

Откройте появившийся файл в app/models (ability.rb) и допишите внутри метода иницилизации 
```ruby
can :manage, Post, user_id: user.id
```
can - стандартный метод для cancan, позволяющий что-то сделать. Post - модель, к которой относится разрешение. user_id - поле этой модели, которое мы будем сравнивать, user.id - то, с чем мы будем сравнивать. В данном случае, мы сравниваем id автора поста с id пользователя

Следующее, что мы сделаем - запретим делать что-либо пользователям, которые не вошли. Нужно открыть контроллер для постов (posts_controller) и, внутри класса, дописать 
```ruby
before_filter :authenticate_user!
```
Благодаря совместимости cancan и devise, cancan проверит вошел ли пользователь и отправит его на страницу с ошибкой, если не вошел

Чтобы запретить пользователям редактировать и удалять не свои посты, найдите методы update и delete и, после инициализации переменной @post, добавьте 
```ruby
authorize! :manage, @post
```
Это тоже стандартный метод для cancan. :manage - метка (символ), указанная в ability.rb, указывающая на типа прав

Следующее, что нужно сделать - скрыть кнопки edit и destroy для всех, кроме автора. Откройте views/posts и все файлы, где это нужно сделать (index, show). Оберните ссылки на edit и destroy в 
```ruby
<% if can? :manage, post %> <% end %>
```
can? - метод cancan, который возвращает true или false в зависимости от того, может пользователь (в данном случае) :manage post или нет (для того, что бы пользователь мог :manage, id автора и пользователя должны совпадать)

Личные блоги
----------------------------------
Но это все хорошо и хотелось бы добавить личные профили для каждого пользователя, а также рабочие хэштэги. Пускай по /@username у нас будет список постов пользователя username, а по /!hashtag все посты, отмеченные хэштегом hashtag. Но вернемся к хэштегам позже
Для начала нужно создать контроллер для профиля. Чтобы это сделать, нужно ввести в консоль 
```ruby
rails g controller User index
```
Рельсы автоматически сгенерируют контроллер User с методом index, а так же подходящий view (в данном случае, он будет почти пустой и не очень полезный, но мы это исправим)

Следующее, что нам нужно сделать, это перенаправить /@username на этот метод. Откройте routes.rb (находится в папке config) и добавьте 
```ruby
match '/@:username' => "User#index"
```

Теперь нужно сделать вывод постов. Откройте сгенерированный контроллер (user_controller) и допишите в метод index     
```ruby
@user = User.find_by_username(params[:username])
@posts = @user.posts

respond_to do |format|
  format.html
  format.json { render json: @posts}
end
```
это найдет пользователя с именем params[:username] (params[:username] получает имя пользователя как параметр из url) и найдет все его посты, а затем отправит все в нужный view (user/index.html.erb)
Чтобы долго не заморачиваться (мы ведь пишем бэкэнд, а не фронтэнд), можно скопировать index.html.erb из папки posts

Хэштеги
----------------------------------
Чтобы сделать рабочими хэштэги, нужно:
1. Пропарсить текст сообщения, чтобы найти все хэштэги
2. Сделать связь между постами и тэгами
3. При отображении постов, пропарсить каждый пост и сделать ссылку на каждом тэге
4. Создать страницу, где будут выводится все посты, отмеченные определенным хэштэгом

Для начала, поставим гем acts-as-taggable-on (Gemfile -> gem 'acts-as-taggable-on') и сгенерируем его таблицу (rails g migration acts-as-taggable-on:migration в консоли)
Откройте модель Post и добавьте строку 
```ruby
acts_as_taggable_on :tags
```
в класс. Это укажет acts-as-taggable-on "класс" тэгов (проще говоря - их критерий. Но так как нам что-то кроме обычных тэгов не нужно, пускай он будет называться :tags)

Теперь нужно отметить все посты своими тэгами. Для этого нужно открыть контроллер posts и найти методы create и update (при редактировании постов тэги тоже могут изменяться). Для нахождения тэгов воспользуемся регулярными выражениями. Для этого после инициализации @post добавим
```ruby
tags =  @post.text.scan(/\B#\w+/)
@post.tag_list = (tags * ', ').gsub! '#', ''
```
scan выделит все попадания под регулярное выражение, а @post.tag_list = (tags * ', ').gsub! '#', '' объеденит массив найденных значений в одну строку и удалит в ней все # (чтобы получить чистые тэги), а затем добавит их в tag_list. tag_list - список тэгов нашего поста, хранится в виде строки

Теперь нужно сгенерировать контроллер (rails g controller Tag index в консоли). Откроем его и добавим в метод index:
```ruby
@posts = Post.tagged_with(params[:tag])

respond_to do |format|
  format.html # index.html.erb
  format.json { render json: @posts }
end
```
  первая строка инициализирует переменную @posts в виде массива постов, которые отмечены тэгом params[:tag] (как и :username, берется из url).
Как и в случае с профилем пользователя, view можно скопировать из posts

Для того, чтобы преобразовать текст в ссылки, снова воспользуемся регулярным выражением, но, на этот раз, уже во фронтэнде. Откройте все view, где отображаются посты (index и show в User, Posts и Tag) и добавьте к td, содержащему <%= post.text %> (текст поста) класс post_body. Получится:
```ruby
<td class = "post_body"><%= post.text %></td>
```

Теперь перейдем в app/assets/javascript и создадим новый файл с расширением js. Так как в рельсы jQuery подключен по-умолчанию, то воспользуемся селекторами из него:

```javascript
function make_hashtags(source){
  return source.replace(/\B[\#|\@]\w+/gi, function(match) { return match.link('/' + match.replace('#', '!')); })
}

$(document).ready(function(){
 $(".post_body").each(function(){
 	$(this).html(make_hashtags($(this).text()));
 });
});
```

Запуск
------------------------------------------------
Для запуска в консоли нужно ввести
```ruby
bundle install
```
Вводится это единоразово. Эта команда установит все отсутствующие у вас гемы

Затем
```ruby
rake db:migrate
```

Это смигрирует все в БД

И, наконец
```ruby
rails server
```
Это запустит сервер. Страница будет доступна по адресу 0.0.0.0:3000 или localhost:3000 (3000 - порт по-умолчанию) в зависимости от вашей ОС
