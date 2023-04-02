module imdb
import json

pub struct IndexedJsonStore{
	pub mut:
	indexes map[string]map[string][]string
	indexers map[string]Indexer
	subscriptions map[string][]Subscription
	data map[string]string
	name string
}
pub fn typed_indexer[T](val fn(r T) []string) Indexer{
	return fn [val] [T](e string) []string{

		r:=json.decode(T,e) or {
			panic("no json for ${e}")
		}
		mut values:=[]string{}
		values<<val(r)
		return values
	}
}
pub fn create_db(name string) IndexedJsonStore {
	mut db:=IndexedJsonStore{
		name: name
		indexes:map[string]map[string][]string{}
		indexers:map[string]Indexer{}
		subscriptions:map[string][]Subscription{}
	}
	db.index_by("id",typed_indexer[Record](fn (r Record) []string{
	 	mut ids:=[]string{}
		ids<<r.id
		return ids
	}))
	/// db.index_by("id",Indexer{
	/// 	r:=json.decode(Record,e) or {
	/// 		panic("no json for ${e}")
	/// 	}
	/// 	mut ids:=[]string{}
	/// 	ids<<r.id
	/// 	return ids
	/// })
	return db
}

pub fn (db IndexedJsonStore) string() string{
	return "
	IndexedJsonStore{
		indexes ${db.indexes}
		indexers ${db.indexers}
		subscriptions ${db.subscriptions} 
		name ${db.name} 
		data ${db.data} 
	}
	"
}
pub fn (mut db IndexedJsonStore) index_by(index_name string,index_fn Indexer ){
	db.indexers[index_name]=(index_fn)
}
pub fn (mut db IndexedJsonStore) on(eventType string, callback fn (json string)) {
	if !(eventType in db.subscriptions.keys()) {
		db.subscriptions[eventType]=[]Subscription{}
	}
	db.subscriptions[eventType]<<(callback)
}

pub fn (mut db IndexedJsonStore) add(record string) {
	  ids:=db.indexers["id"](record)
      db.data[ids[0]] = record
      db.index(record)
      db.broadcast_event("add", record)
}
pub fn (mut db IndexedJsonStore) remove(record string) {
	ids:=db.indexers["id"](record)
	id:=ids[0]
	db.data.delete(id)
	db.remove_from_indexes(record)
    db.broadcast_event("remove", record)
}
pub fn (mut db IndexedJsonStore) update(id string, update_fn Updater) {

      record := db.data[id]
      db.data.delete(id)
      db.remove_from_indexes(record)

      updated_record_string := update_fn(record)
	  updated_record:=record_from_json(updated_record_string)
      db.data[updated_record.id] = updated_record_string
      db.index(updated_record_string)

      db.broadcast_event('update', updated_record_string)
}
pub fn (db IndexedJsonStore) filter(ff fn (id string,ent string) bool) []string {
	mut results:=[]string{}
	for id,data in db.data {
		if ff(id,data) {
			results<<data
		}
	}
	return results
}
pub fn (db IndexedJsonStore) find_by_indexes(index_names []string, index_value string) []string {
	mut results:=[]string{}
	for index_name in index_names {
		results<<db.find_by_index(index_name,index_value)
	}
	return results
}
pub fn (db IndexedJsonStore) find_by_index(index_name string, index_value string) []string{
	// index_value:=db.indexers[index_name]
	return db.indexes[index_name][index_value].map( fn[db](id string) string{
		return db.data[id]
	})
}

pub fn (mut db IndexedJsonStore) index(record string) {
	ids:=db.indexers["id"](record)
	id:=ids[0]
	for index_name,index_fn in db.indexers {
		// println("$index_name => $index_fn")
		if !(index_name in db.indexes.keys()) {
			db.indexes[index_name]=map[string][]string{}
		}
		for index_value in index_fn(record){
			db.indexes[index_name][index_value]<<id
		}
	}
}
pub fn (mut db IndexedJsonStore) remove_from_indexes(record string) {

	ids:=db.indexers["id"](record)
	id:=ids[0]
	for index_name,index_map in db.indexes {
		for index_value,id_list in index_map {
			new_index_array:=id_list.filter( fn[id](cid string) bool{return cid!=id})
			if new_index_array.len == 0 {
				db.indexes[index_name].delete(index_value)
			}else {
				db.indexes[index_name][index_value]=new_index_array
			}
		}
	}
}

pub fn (db IndexedJsonStore) broadcast_event(eventType string, eventData string) {}