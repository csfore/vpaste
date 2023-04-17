module main
import vweb
import databases
import net.http

// [middleware: check_auth]
['/admin']
fn (mut app App) admin() vweb.Result {
	config := http.HeaderQueryConfig{
		exact: true
	}

	println('h - ${app.header}')
	auth_header := app.header.get_custom('is_auth', config) or {
		''
	}
	// header := app.get_header('is_auth')
	// println('a $header')
	println(auth_header)
	if auth_header != 'true' { 
		return app.redirect('/login') 
	} 

	db := databases.create_db_connection() or {
		panic(err)
	}

	pastes := sql db {
		select from Paste
	} or {
		eprintln(err)
		exit(1)
	}

	// for paste in pastes {
	// 	println('${paste.id} - ${paste.content} - ${paste.hash}')
	// }

	last := sql db {
		select from Paste order by id desc limit 1
	} or {
		eprintln(err)
		exit(1)
	}
	// println(last)
	
	println('isauth: ${auth_header}')

	validated := if auth_header == 'true' { true } else { false }
	println(validated)

	return $vweb.html()
}

['/login'; post]
pub fn (mut app App) check_auth() vweb.Result {
	db := databases.create_db_connection() or {
		panic(err)
	}
	admins := sql db {
		select from Admin
	} or {
		eprintln(err)
		exit(1)
	}

	for admin in admins {
		if admin.password == app.form['pass'] {
			println('Good!')
			app.is_authenticated = true
			app.add_header('is_auth', 'true')
			return app.redirect('/admin')
		}
	}

	// if app.get_cookie('auth') == '' {
	// 	return false
	// }
	return app.text('hello')
}

['/login']
pub fn (mut app App) login() vweb.Result {
	db := databases.create_db_connection() or {
		panic(err)
	}
	admins := sql db {
		select from Admin
	} or {
		eprintln(err)
		exit(1)
	}

	for admin in admins {
		if admin.password == app.form['pass'] {
			println('Good!')
			app.is_authenticated = true
			app.add_header('is_auth', 'true')
			return app.admin()
		}
	}

	// if app.get_cookie('auth') == '' {
	// 	return false
	// }
	return $vweb.html()
}