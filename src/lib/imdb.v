module imdb
import uuid {v0}

pub enum EventType{
	event_add
	event_remove
	event_update
	event_index
	event_remove_from_index
}
pub struct InMemDb{
	mut:
	indexes map[string][]string
	indexers map[string]fn (e string) []string
	subscribers map[string][]fn (e string)
	pub:
	name string
}

pub fn create_db(name string) InMemDb {
	db:=InMemDb{
		name: name
		indexes:map[string][]string{}
		indexers:map[string]fn (e string) []string{}
		subscribers:map[string][]fn (e string)
	}
	return db
}

pub fn (db InMemDb) string() string{
	return "
	InMemDb{
		mut:
		${db.indexes} map[string][]string
		${db.indexers} map[string]fn (e string) []string
		pub:
		${db.name} string
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

pub fn (mut db InMemDb) add(record string) {}
pub fn (mut db InMemDb) remove(record string) {}
pub fn (mut db InMemDb) update(id string, updateFn fn(json string) string) {}
pub fn (db InMemDb) find_by_indexes(indexNames []string, indexValue string) {}
pub fn (db InMemDb) find_by_index(indexName string, indexValue string) {}

pub fn (mut db InMemDb) index(record string) {}
pub fn (mut db InMemDb) remove_from_indexes(record string) {}

pub fn (db InMemDb) broadcast_event(eventType EventType, eventData string) {}