module imdb
import uuid {v0}
import json

pub struct TypedRecord[T]{
	pub mut:
	id string
	data T
}
pub fn typed_record_from_json[T](s string) TypedRecord[T]{
	r:=record_from_json(s)
	tr:=TypedRecord[T]{
		id:r.id
		data:r.cast[T]()
	}
	return tr
}
pub struct Record{
	pub mut:
	id string
	data string
}
pub fn record_from_json(s string) Record{
	mut r:=json.decode(Record,s) or {
		panic("no json for $s")
	}
	r.data=s
	if r.id == '' {
		r.id=v0()
		r.data=json.encode(r)
	}
	return r
}
pub fn (r Record) id() string{
	return r.id
}
pub fn (r Record) cast[T]() T{
	d:=json.decode(T,r.data) or {
		panic("no json for ${r.data}")
	}
	return d
}

pub struct Event{
	event_type EventType
	id string
	record string
}

pub enum EventType{
	event_add
	event_remove
	event_update
	event_index
	event_remove_from_index
}
pub struct InMemDb{
	pub mut:
	indexes map[string]map[string][]string
	indexers map[string]fn (e string) []string
	subscribers map[string][]fn (e string)
	data map[string]string
	name string
}
pub fn indexer_on_field[T](val fn(r T) []string) fn (e string) []string{
	return fn [val] [T](e string) []string{

		r:=json.decode(T,e) or {
			panic("no json for ${e}")
		}
		mut values:=[]string{}
		values<<val(r)
		return values
	}
}
pub fn create_db(name string) InMemDb {
	mut db:=InMemDb{
		name: name
		indexes:map[string]map[string][]string{}
		indexers:map[string]fn (e string) []string{}
		subscribers:map[string][]fn (e string)
	}
	db.index_by("id",indexer_on_field[Record](fn (r Record) []string{
	 	mut ids:=[]string{}
		ids<<r.id
		return ids
	}))
	/// db.index_by("id",fn (e string) []string{
	/// 	r:=json.decode(Record,e) or {
	/// 		panic("no json for ${e}")
	/// 	}
	/// 	mut ids:=[]string{}
	/// 	ids<<r.id
	/// 	return ids
	/// })
	return db
}

pub fn (db InMemDb) string() string{
	return "
	InMemDb{
		indexes ${db.indexes}
		indexers ${db.indexers}
		subscribers ${db.subscribers} 
		name ${db.name} 
		data ${db.data} 
	}
	"
}
pub fn (mut db InMemDb) index_by(index_name string,index_fn fn(record string) []string ){
	db.indexers[index_name]=(index_fn)
}
pub fn (mut db InMemDb) on(eventType string, callback fn (json string)) {
	if !(eventType in db.subscribers.keys()) {
		db.subscribers[eventType]=[]fn (e string){}
	}
	db.subscribers[eventType]<<(callback)
}

pub fn (mut db InMemDb) add(record string) {
	  ids:=db.indexers["id"](record)
      db.data[ids[0]] = record
      db.index(record)
      db.broadcast_event("add", record)
}
pub fn (mut db InMemDb) remove(record string) {
	ids:=db.indexers["id"](record)
	id:=ids[0]
	db.data.delete(id)
	db.remove_from_indexes(record)
    db.broadcast_event("remove", record)
}
pub fn (mut db InMemDb) update(id string, update_fn fn(json string) string) {

      record := db.data[id]
      db.data.delete(id)
      db.remove_from_indexes(record)

      updated_record_string := update_fn(record)
	  updated_record:=record_from_json(updated_record_string)
      db.data[updated_record.id] = updated_record_string
      db.index(updated_record_string)

      db.broadcast_event('update', updated_record_string)
}
pub fn (db InMemDb) find_by_indexes(index_names []string, index_value string) {
	//TODO
}
pub fn (db InMemDb) find_by_index(index_name string, index_value string) []string{
	// index_value:=db.indexers[index_name]
	return db.indexes[index_name][index_value].map( fn[db](id string) string{
		return db.data[id]
	})
}

pub fn (mut db InMemDb) index(record string) {
	ids:=db.indexers["id"](record)
	id:=ids[0]
	for index_name,index_fn in db.indexers {
		println("$index_name => $index_fn")
		if !(index_name in db.indexes.keys()) {
			db.indexes[index_name]=map[string][]string{}
		}
		for index_value in index_fn(record){
			db.indexes[index_name][index_value]<<id
		}
	}
}
pub fn (mut db InMemDb) remove_from_indexes(record string) {

	ids:=db.indexers["id"](record)
	id:=ids[0]
	for index_name,index_map in db.indexes {
		for index_value,id_list in index_map {
			db.indexes[index_name][index_value]=id_list.filter( fn[id](cid string) bool{return cid!=id})
		}
	}
}

pub fn (db InMemDb) broadcast_event(eventType string, eventData string) {}