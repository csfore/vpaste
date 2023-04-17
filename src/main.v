module main

import vweb
import databases
import os
// import json
import crypto.sha512
import time
import net.http

const (
	port = 8082
)

struct App {
	vweb.Context
	middlewares map[string][]vweb.Middleware
mut:
	is_authenticated bool
}

pub fn (mut app App) before_request() {
	cookie := http.Cookie{
		name: 'auth'
		value: '0'
	}

	app.get_cookie('auth') or {
		app.set_cookie(cookie)
	}

	println('[web] before_request: ${app.req.method} ${app.req.url}')
}

fn new_app() &App {
	mut app := &App{
		middlewares: {
			// chaining is allowed, middleware will be evaluated in order
			'/admin/': []
		}
	}
	return app
}

fn main() {
	mut db := databases.create_db_connection() or { panic(err) }

	// one := Paste{
	// 	id: 1
	// 	content: 'hello'
	// 	hash: sha512.hexhash('hello' + time.now().unix_time_milli().str())[0..17]
	// }
	// two := Paste{
	// 	id: 2
	// 	content: 'world'
	// 	hash: sha512.hexhash('world' + time.now().unix_time_milli().str())[0..17]
	// }

	sql db {
		create table Paste
		create table Admin
		// insert one into Paste
		// insert two into Paste
	} or { panic('error on create table: ${err}') }



	db.close() or { panic(err) }

	mut app := &App{}
	app.serve_static('/favicon.ico', 'src/assets/favicon.ico')
	// makes all static files available.
	app.mount_static_folder_at(os.resource_abs_path('.'), '/')

	vweb.run(app, port)
}

['/']
pub fn (mut app App) index() vweb.Result {
	title := 'Paste'
	content := ''
	println(app.header)

	return $vweb.html()
}

['/paste'; post]
fn (mut app App) add_paste() vweb.Result {
	db := databases.create_db_connection() or {
		panic(err)
	}

	mut body := Paste{
		content: app.req.data
	}

	println(app.req.data)
	// mut body := 

	last := sql db {
		select from Paste order by id desc limit 1
	} or {
		eprintln(err)
		exit(1)
	}
	
	println(last)

	last_id := if last.len == 0 { 0 } else { last[0].id }
	body.id = last_id + 1
	body.hash = sha512.hexhash(body.content + time.now().unix_time_milli().str())[0..17]

	sql db {
		insert body into Paste
	} or {
		eprintln(err)
		exit(1)
	}

	println('${body.id}, ${body.content}')
	// println('http://localhost:8082/${body.hash}\n')
	
	return app.text('${body.hash}\n')
}


['/:paste']
fn (mut app App) paste(paste string) vweb.Result {
	title := 'Paste'
	db := databases.create_db_connection() or {
		panic(err)
	}

	raw := sql db {
		select from Paste where hash == '${paste}' limit 1 
	} or {
		eprintln(err)
		exit(1)
	}

	if raw.len == 0 {
		return app.not_found()
	}
	println(raw)
	content := raw[0].content

	app.add_header('content', content)

	return $vweb.html()
}

