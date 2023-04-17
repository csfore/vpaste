module main

[table: 'pastes']
pub struct Paste {
mut:
	id      int    [primary; sql: serial]
	content string [sql_type: 'TEXT']
	hash    string [sql_type: 'TEXT']
}

[table: 'admins']
pub struct Admin {
	id       int    [primary; sql: serial]
	username string
	password string
}
