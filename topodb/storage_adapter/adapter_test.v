module storage_adapter
import geometry
import os

import topodb.imdb{create_db}

import topodb.types{Record,record_from_json}
import time
import json

fn gen_some(n u64) ![]Record{
	mut list:=[]Record{}
	for i in 0..n {
		list<<record_from_json('{"id":"${i+1}","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}')!
	}
	return list
}
fn test_create_instance(){
	fsb:=FileStorageBackend{}
	println(fsb)
}

pub fn sleep(millis f64) {
	now := time.linux_now()
	end := now.microsecond+millis*1000
	mut crt:=time.linux_now().microsecond
	for crt < end{
		crt=time.linux_now().microsecond
	}
}
fn test_sleep(){
	println("hello ${time.linux_now().str()}")
	time.sleep(1_000_000_000)
	println("world ${time.linux_now().str()}")
}
fn test_create_storage_backend_happy(){
	println("hello ${time.linux_now().str()}")
	os.rm("./_test_data/zaz.db.json") or {}
	os.rm("./_test_data/zaz.db.index.json") or {}
	assert !os.exists("./_test_data/zaz.db.json")
	assert !os.exists("./_test_data/zaz.db.index.json")
	mut fsb:=init_create("./_test_data/zaz",IndexingStrategy.history)!
	println(fsb)
	fsb.dispose()!
	assert os.exists("./_test_data/zaz.db.json")
	assert os.exists("./_test_data/zaz.db.index.json")
	println(fsb)
	os.rm("./_test_data/zaz.db.json") or {}
	os.rm("./_test_data/zaz.db.index.json") or {}
	assert !os.exists("./_test_data/zaz.db.json")
	assert !os.exists("./_test_data/zaz.db.index.json")
	println("bye ${time.linux_now().str()}")
}
fn test_create_storage_backend_bad_access() ! {
	mut fsb1:=init_create("./_test_data/zaz/zaz",IndexingStrategy.history) or {
		println("${err.code()}  ${err.msg()}")
		FileStorageBackend{}
	}
	println("fsb1:before ${fsb1}")
	fsb1.dispose() or {
		println("${err.code()}  ${err.msg()}")
	}
	println("fsb1:after ${fsb1}")
	expresult:=FileStorageBackend{}
	println(expresult)
	// assert fsb1.str()==expresult
}
fn test_create_storage_backend_with_data(){
	mut fsb:=init_open("./_test_data/with_data",IndexingStrategy.history)!
	println(fsb)
	fsb.dispose()!
	println(fsb)
	assert fsb.index.keys().len==10
}
fn test_store_index_history_bulk(){
	os.rm("./_test_data/test_data.db.json") or {}
	os.rm("./_test_data/test_data.db.index.json") or {}
	t0:=time.now().unix_time_milli()
	mut record_count:=0
	mut fsb:=init_create("./_test_data/test_data",IndexingStrategy.history)!
	//fsb.rebuild_index()!
	recs:=gen_some(20_000)!
	fsb.push_all(recs)!
	t1:=time.now().unix_time_milli() - t0
	fsb.dispose()!

	println("created ${recs.len} in $t1 millis @ ${recs.len*1000/t1} records/s by strategy ${fsb.indexing_strategy}")
	// assert fsb.index.keys().len==13
}
fn test_store_index_last_bulk(){
	os.rm("./_test_data/test_data.db.json") or {}
	os.rm("./_test_data/test_data.db.index.json") or {}
	t0:=time.now().unix_time_milli()
	mut fsb:=init_create("./_test_data/test_data",IndexingStrategy.last)!
	recs:=gen_some(20_000)!
	fsb.push_all(recs)!
	t1:=time.now().unix_time_milli() - t0
	fsb.dispose()!

	println("created ${recs.len} in $t1 millis @ ${recs.len*1000/t1} records/s by strategy ${fsb.indexing_strategy}")
	// assert fsb.index.keys().len==13
}
fn test_fetch_history_all(){

	//os.rm("./_test_data/test_data.db.json") or {}
	//os.rm("./_test_data/test_data.db.index.json") or {}
	t0:=time.now().unix_time_milli()
	mut fsb:=init_create("./_test_data/test_data",IndexingStrategy.last)!
	recs:=gen_some(100)!
	fsb.push_all(recs)!
	fsb.dispose()!

	fsb=init_open("./_test_data/test_data",IndexingStrategy.last)!
	t1:=time.now().unix_time_milli() - t0
	println(fsb)
	indexes:=fsb.index
		.keys()
		.filter(fn(k string) bool{return k in ['2','10']})
		.map(fn[fsb](id string) FileIndex {
			return fsb.index[id].last()
		})
	println(indexes)
	mut fl:=os.open(fsb.data_filename)!
	records:=indexes.map(fn[fl](fi FileIndex) string {
		b:=fl.read_bytes_at(int(fi.pos),fi.len).bytestr()
		return b
	})
	fl.close()
	println(records)
	println("created ${recs.len} in $t1 millis @ ${recs.len*1000/t1} records/s by strategy ${fsb.indexing_strategy}")
	fr:=fsb.fetch_history_all(['2','10'])!
	println(fr)
	fsb.dispose()!
}



pub fn test_read_all_map(){
	fname:="_test_data/test_read_all.db.json"
	list:=gen_some(10)!
	write_all(fname,list.map(fn (r Record) string{return json.encode(r)}))!
	mm:=read_all_map[geometry.Box](fname,fn(s string) !geometry.Box {
		return record_from_json(s)!.cast[geometry.Box]()!
	})!
	println(mm)
	assert mm.len==10

}

pub fn test_write_all(){
	fname:="_test_data/test_write_all.db.json"
	list:=gen_some(10)!
	write_all(fname,list.map(fn (r Record) string{return json.encode(r)}))!
	assert 1==1

}
pub fn test_read_all(){
	fname:="_test_data/test_read_all.db.json"
	gen:=gen_some(10)!
	write_all(fname,gen.map(fn (r Record) string{return json.encode(r)}))!
	data:=read_all(fname)!
	for i,v in gen {
		assert v == data[i]
	}
}
fn test_imdb_events_with_file_io(){
	println('----------------------------------------' + @MOD + '..' + @FN)
	println('file: ' + @FILE + ':' + @LINE + ' | fn: ' + @MOD + '..' + @FN)
	mut db:=create_db("_test_data/vspace")
	db.index_by("box",fn(str string)![]string{
		record:=record_from_json(str)!
		box:=record.cast[geometry.Box]()!
		return box.all_slices(20).map( fn (slice geometry.Box) string {
			return "${slice.anchor.x},${slice.anchor.y}@20"
		})
	})

	// >> do something with file; file is locked <<

	db.on('add',fn [db](event_data string) ! {
		fname:="${db.name}.db.json"
		mut f := os.open_append(fname)!
		r:=record_from_json(event_data)!
		f.writeln(event_data)!
		println("added $event_data")
		f.close()
	})
	db.on('remove',fn (event_data string) ! {
		println("removed $event_data")
	})
	db.on('update',fn (event_data string) ! {
		println("updated $event_data")
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
	assert 1==1
}
