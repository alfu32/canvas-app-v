module imdb_test
import imdb {InMemDb,create_db}


fn test_imdb_create(){
	mut a:=create_db("vspace")
	println(a.string())
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

}
fn test_imdb_remove(){

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