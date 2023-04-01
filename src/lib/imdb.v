module imdb
import uuid {v0}
import json

pub struct Record{
	id string
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
pub fn (mut db InMemDb) update(id string, updateFn fn(json string) string) {}
pub fn (db InMemDb) find_by_indexes(indexNames []string, indexValue string) {}
pub fn (db InMemDb) find_by_index(indexName string, indexValue string) {}

pub fn (mut db InMemDb) index(record string) {
	ids:=db.indexers["id"](record)
	id:=ids[0]
	for k,v in db.indexers {
		println("$k => $v")
		if !(k in db.indexes.keys()) {
			db.indexes[k]=map[string][]string{}
		}
		for val in v(record){
			db.indexes[k][val]<<id
		}
	}
}
pub fn (mut db InMemDb) remove_from_indexes(record string) {

	ids:=db.indexers["id"](record)
	id:=ids[0]
	for k,v in db.indexes {
		println("$k => $v")
		if !(k in db.indexes.keys()) {
			db.indexes[k]=map[string][]string{}
		}
		for val in v(record){
			db.indexes[k][val]=db.indexes[k][val].filter( fn[id](cid){return cid!=id})
		}
	}
}

pub fn (db InMemDb) broadcast_event(eventType string, eventData string) {}