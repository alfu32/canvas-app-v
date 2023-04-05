module imdb
import geometry { Box }
import json
import topodb.types {Record,record_from_json,typed_record_from_json}

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
	r:=record_from_json(rs1)!

	println(r)

	assert r.id == "werwer"
	assert r.data == '{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}'
	rs2:='{"anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}'
	r2:=record_from_json(rs2)!

	println(r2)
	assert r2.id != ""
	assert r2.id.len == 36

}
fn test_record_cast(){
	rs1:='{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}'
	r:=record_from_json(rs1)!
	b:=r.cast[Box]()!
	println(b)
	assert b.anchor.x == 10
	assert b.anchor.y == 20
	assert b.size.x == 20
	assert b.size.y == 40
	assert r.id == "werwer"
	assert r.id.len == 6

}
fn test_imdb_create(){
	mut a:=create_db("_test_data/vspace")
	println(a)
	assert 1==1
}

fn before_each() IndexedJsonStore{
	mut a:=create_db("_test_data/vspace")
	return a
}

fn test_imdb_index_by(){

}
fn test_imdb_on(){

}
fn test_imdb_add(){
	mut db:=create_db("_test_data/vspace")

	db.add('{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')!
	db.add('{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')!
	db.add('{"id":"xcvxc","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')!
	db.add('{"id":"tyuty","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')!
	println(db.string())
	assert db.data.values().len == 4

}
fn test_imdb_remove(){
	mut db:=create_db("_test_data/vspace")

	db.add('{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')!
	db.add('{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')!
	db.add('{"id":"xcvxc","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')!
	db.add('{"id":"tyuty","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')!
	println(db.string())
	assert db.data.values().len == 4
	db.remove('{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}')!
	println(db.string())
	assert db.data.values().len == 3
	assert db.indexes["id"]["werwer"].len == 0

}
fn test_imdb_update(){
	mut db:=create_db("_test_data/vspace")
	rj:='{"id":"werwer","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}'
	db.add(rj)!
	mut r:=record_from_json(rj)!
	db.update(r.id,fn(o string)string{return '{"id":"acpi","anchor":{"x":10,"y":20},"size":{"x":20,"y":40}}'})!
	println(db)

	assert db.indexes["id"]["acpi"].len==1
	assert db.indexes["id"]["werwer"].len==0
	assert db.data["werwer"]==""

}
fn test_imdb_find_by_indexes(){
	//TODO
}
fn test_imdb_find_by_index(){
	mut db:=create_db("_test_data/vspace")
	db.index_by("box",fn(str string)![]string{
		record:=record_from_json(str)!
		box:=record.cast[Box]()!
		return box.all_slices(20).map( fn (slice Box) string {
			return "${slice.anchor.x},${slice.anchor.y}@20"
		})
	})

	db.add('{"id":"werwer","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}')!
	db.add('{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":10,"y":10}}')!
	db.add('{"id":"xcvxc","anchor":{"x":15,"y":10},"size":{"x":40,"y":40}}')!
	db.add('{"id":"tyuty","anchor":{"x":20,"y":90},"size":{"x":20,"y":20}}')!
	db.add('{"id":"acpi","anchor":{"x":80,"y":20},"size":{"x":20,"y":40}}')!
	println(db)
	a:=db.find_by_index("id","acpi").map( fn(r string) !Box {return record_from_json(r)!.cast[Box]()!})
	b:=db.find_by_index("box","60.0,100.0@20").map( fn(r string) !Box {return typed_record_from_json[Box](r)!.data})
	println(a)
	println(b)

	assert a.len == 1
	assert b.len == 2

}
fn test_imdb_index_and_remove_from_indexes(){
	println('----------------------------------------' + @MOD + '..' + @FN)
	println('file: ' + @FILE + ':' + @LINE + ' | fn: ' + @MOD + '..' + @FN)
	mut db:=create_db("_test_data/vspace")
	index_by_box:=fn(str string)![]string{
		record:=record_from_json(str)!
		box:=record.cast[Box]()!
		return box.all_slices(20).map( fn (slice Box) string {
			return "${slice.anchor.x},${slice.anchor.y}@20"
		})
	}
	db.index_by("box",index_by_box)
	boxes:=[
		'{"id":"werwer","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}'
		'{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":10,"y":10}}'
		'{"id":"xcvxc","anchor":{"x":15,"y":10},"size":{"x":40,"y":40}}'
		'{"id":"tyuty","anchor":{"x":20,"y":90},"size":{"x":20,"y":20}}'
		'{"id":"acpi","anchor":{"x":80,"y":20},"size":{"x":20,"y":40}}'
	]
	println(boxes)
	for i,bx in boxes {
		println("indexing $bx ----------------------------------------------------------------")
		db.add(bx)!
		bx_index_values:=index_by_box(bx)!
		println("after add $bx bx_index_values ---------------------------")
		println(bx_index_values)
		println("after add $bx db.indexes ---------------------------")
		println(db.indexes)
		mut ids:=map[string]string{}
		for ix, ida in db.indexes["box"].values(){
			assert ida.len==1
			ids[ida[0]]=ida[0]
		}
		assert ids.keys().len == 1
		assert ids.keys()[0] == record_from_json(bx)!.id
		db.remove(bx)!
		println("after delete $bx db.indexes[box].values() ---------------------------")
		println(db.indexes)

		ids=map[string]string{}
		for ix, ida in db.indexes["box"].values(){
			assert ida.len==0
		}
		println(ids)
		println(ids.keys())
		assert ids.keys().len == 0
	}

	// println('file: ' + @FILE + ':' + @LINE + ' | fn: ' + @MOD + '.' + @FN)

	assert 1==1

}
fn test_imdb_events(){
	println('----------------------------------------' + @MOD + '..' + @FN)
	println('file: ' + @FILE + ':' + @LINE + ' | fn: ' + @MOD + '..' + @FN)
	mut db:=create_db("_test_data/vspace")
	mut events:=[]string{}
	mut ev:=&events
	db.index_by("box",fn(str string)![]string{
		record:=record_from_json(str)!
		box:=record.cast[Box]()!
		return box.all_slices(20).map( fn (slice Box) string {
			return "${slice.anchor.x},${slice.anchor.y}@20"
		})
	})
	db.on('add',fn [mut ev](event_data string)!{
		op:=('{"operation":"added","event_data":$event_data}')
		ev<<op
	})
	db.on('remove',fn [mut ev](event_data string)!{
		op:=('{"operation":"removed","event_data":$event_data}')
		ev<<op
	})
	db.on('update',fn [mut ev](event_data string)!{
		op:=('{"operation":"updated","event_data":$event_data}')
		ev<<op
	})

	db.add('{"id":"werwer","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}')!
	db.add('{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":10,"y":10}}')!
	db.add('{"id":"xcvxc","anchor":{"x":15,"y":10},"size":{"x":40,"y":40}}')!
	db.add('{"id":"tyuty","anchor":{"x":20,"y":90},"size":{"x":20,"y":20}}')!
	db.add('{"id":"acpi","anchor":{"x":80,"y":20},"size":{"x":20,"y":40}}')!

	db.update("werwer",fn(a string)string { return '{"id":"werwer","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}'})!
	db.update("asdf",fn(a string)string { return '{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":10,"y":10}}'})!
	db.update("xcvxc",fn(a string)string { return '{"id":"xcvxc","anchor":{"x":15,"y":10},"size":{"x":40,"y":40}}'})!
	db.update("tyuty",fn(a string)string { return '{"id":"tyuty","anchor":{"x":20,"y":90},"size":{"x":20,"y":20}}'})!
	db.update("acpi",fn(a string)string { return '{"id":"acpi","anchor":{"x":80,"y":20},"size":{"x":20,"y":40}}'})!


	db.remove('{"id":"werwer","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}')!
	db.remove('{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":10,"y":10}}')!
	db.remove('{"id":"xcvxc","anchor":{"x":15,"y":10},"size":{"x":40,"y":40}}')!
	db.remove('{"id":"tyuty","anchor":{"x":20,"y":90},"size":{"x":20,"y":20}}')!
	db.remove('{"id":"acpi","anchor":{"x":80,"y":20},"size":{"x":20,"y":40}}')!

	println(db)
	for evt in events {
		println(evt)
	}
	expected:=[
		'{"operation":"added","event_data":{"id":"werwer","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}}'
		'{"operation":"added","event_data":{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":10,"y":10}}}'
		'{"operation":"added","event_data":{"id":"xcvxc","anchor":{"x":15,"y":10},"size":{"x":40,"y":40}}}'
		'{"operation":"added","event_data":{"id":"tyuty","anchor":{"x":20,"y":90},"size":{"x":20,"y":20}}}'
		'{"operation":"added","event_data":{"id":"acpi","anchor":{"x":80,"y":20},"size":{"x":20,"y":40}}}'
		'{"operation":"updated","event_data":{"id":"werwer","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}}'
		'{"operation":"updated","event_data":{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":10,"y":10}}}'
		'{"operation":"updated","event_data":{"id":"xcvxc","anchor":{"x":15,"y":10},"size":{"x":40,"y":40}}}'
		'{"operation":"updated","event_data":{"id":"tyuty","anchor":{"x":20,"y":90},"size":{"x":20,"y":20}}}'
		'{"operation":"updated","event_data":{"id":"acpi","anchor":{"x":80,"y":20},"size":{"x":20,"y":40}}}'
		'{"operation":"removed","event_data":{"id":"werwer","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}}'
		'{"operation":"removed","event_data":{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":10,"y":10}}}'
		'{"operation":"removed","event_data":{"id":"xcvxc","anchor":{"x":15,"y":10},"size":{"x":40,"y":40}}}'
		'{"operation":"removed","event_data":{"id":"tyuty","anchor":{"x":20,"y":90},"size":{"x":20,"y":20}}}'
		'{"operation":"removed","event_data":{"id":"acpi","anchor":{"x":80,"y":20},"size":{"x":20,"y":40}}}'
	]
	assert events.len==15
	assert expected==events
}
