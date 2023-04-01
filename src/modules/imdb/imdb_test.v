module imdb_test
import imdb {IndexedJsonStore,create_db,Record,EventType,record_from_json,typed_record_from_json}
import geometry { Box }
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
fn test_record_from_json(){
	rs1:='{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}'
	r:=record_from_json(rs1)

	println(r)

	assert r.id == "werwer"
	assert r.data == '{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}'
	rs2:='{"anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}'
	r2:=record_from_json(rs2)

	println(r2)
	assert r2.id != ""
	assert r2.id.len == 39

}
fn test_record_cast(){
	rs1:='{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}'
	r:=record_from_json(rs1)
	b:=r.cast[Box]()
	println(b)
	assert b.anchor.x == 10
	assert b.anchor.y == 20
	assert b.size.x == 20
	assert b.size.y == 40
	assert r.id == "werwer"
	assert r.id.len == 6

}
fn test_imdb_create(){
	mut a:=create_db("vspace")
	// println(a.string())
	assert 1==1
}

fn before_each() IndexedJsonStore{
	mut a:=create_db("vspace")
	return a
}

fn test_imdb_index_by(){

}
fn test_imdb_on(){

}
fn test_imdb_add(){
	mut db:=create_db("vspace")

	db.add('{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')
	db.add('{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')
	db.add('{"id":"xcvxc","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')
	db.add('{"id":"tyuty","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')
	println(db.string())
	assert db.data.values().len == 4

}
fn test_imdb_remove(){
	mut db:=create_db("vspace")

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
	mut db:=create_db("vspace")
	rj:='{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}'
	db.add(rj)
	mut r:=record_from_json(rj)
	db.update(r.id,fn(o string)string{return '{"id":"acpi","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}'})
	println(db)

	assert db.indexes["id"]["acpi"].len==1
	assert db.indexes["id"]["werwer"].len==0
	assert db.data["werwer"]==""

}
fn test_imdb_find_by_indexes(){
	//TODO
}
fn test_imdb_find_by_index(){
	mut db:=create_db("vspace")
	db.index_by("box",fn(str string)[]string{
		record:=record_from_json(str)
		box:=record.cast[Box]()
		return box.all_slices(20).map( fn (slice Box) string {
			return "${slice.anchor.x},${slice.anchor.y}@20"
		})
	})

	db.add('{"id":"werwer","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}')
	db.add('{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":10,"y":10}}')
	db.add('{"id":"xcvxc","anchor":{"x":15,"y":10},"size":{"x":40,"y":40}}')
	db.add('{"id":"tyuty","anchor":{"x":20,"y":90},"size":{"x":20,"y":20}}')
	db.add('{"id":"acpi","anchor":{"x":80,"y":20},"size":{"x":20,"y":40}}')
	println(db)
	a:=db.find_by_index("id","acpi").map( fn(r string) Box {return record_from_json(r).cast[Box]()})
	b:=db.find_by_index("box","60.0,100.0@20").map( fn(r string) Box {return typed_record_from_json[Box](r).data})
	println(a)
	println(b)

	assert a.len == 1
	assert b.len == 2
	
}
fn test_imdb_index(){

}
fn test_imdb_remove_from_indexes(){

}
fn test_imdb_broadcast_event(){

}