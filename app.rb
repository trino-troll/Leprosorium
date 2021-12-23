#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

#before вызывается каждый раз при перезагрузки 
#любой страницы

before do
	#инициализация БД
	init_db
end

#configure вызывается каждый раз при конфигурации приложения
#когда изменился код программы и перезагрузилась страница

configure do
	#инициализация БД
	
	init_db
	#создает таблицу, если уё нет
	
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts (
	id	INTEGER PRIMARY KEY AUTOINCREMENT,
	created_date	DATE,
	content	TEXT
)'
end	

get '/' do
	#выбираем список постов из БД
	@results = @db.execute 'select * from Posts order by id desc'


	erb :index
end

#обработчит get-запроса /new
#(браузер получает страницу с сервера)

get '/new' do
  erb :new
end

#обработчик post-запросов /new
#(браузер отправляет данные на сервер)

post '/new' do
	#получаем переменную из post-запроса
 	content = params[:content]

 	if content.size <= 0
 		@error = 'Type post text.'
 		return erb :new
 	end

 	#сохранение данных в БД
 	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

 	#перенаправление на главную страницу
	redirect to '/'
end

#вывод информации о посте
get '/details/:post_id' do 
	#получаю переменную из URL
	post_id = params[:post_id]

	#получаю список постов
	#(пост будет толлько один)
	results = @db.execute 'select * from Posts where id = ?', [post_id ]
	
	#выбираю этот пост в переменную @row
	@row = results[0]

	#возвращает представление details.erb
	erb :details
end





