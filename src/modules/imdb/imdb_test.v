module imdb_test
import imdb {InMemDb,create_db,Record,EventType}
import json

fn test_record_decode(){
	r:=Record{
		id:"werwer"
	}
	rs:=json.encode(r)
	// println(rs)

	rs1:='{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}'
	// println(rs1)
	r1:=json.decode(Record,rs1) or {
		panic ("could not decode $rs1")
	}
	// println(r1)

	assert 1==1
}
fn test_imdb_create(){
	mut a:=create_db("vspace")
	// println(a.string())
	assert 1==1
}

fn before_each() InMemDb{
	mut a:=create_db("vspace")
	return a
}

fn test_imdb_index_by(){

}
fn test_imdb_on(){

}
fn test_imdb_add(){
	mut db:=create_db("vspace")
	for k,v in db.indexers {
		println("$k => $v")
	}

	db.add('{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')
	db.add('{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')
	db.add('{"id":"xcvxc","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')
	db.add('{"id":"tyuty","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')
	println(db.string())
	assert db.data.values().len == 4

}
fn test_imdb_remove(){
	mut db:=create_db("vspace")
	for k,v in db.indexers {
		println("$k => $v")
	}

	db.add('{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')
	db.add('{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')
	db.add('{"id":"xcvxc","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')
	db.add('{"id":"tyuty","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')
	println(db.string())
	assert db.data.values().len == 4
	db.remove('{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')
	println(db.string())
	assert db.data.values().len == 3
	assert db.indexes["id"]["werwer"].len == 0

}
fn test_imdb_update(){

}
fn test_imdb_find_by_indexes(){

}
fn test_imdb_find_by_index(){

}
fn test_imdb_index(){

}
fn test_imdb_remove_from_indexes(){

}
fn test_imdb_broadcast_event(){

}