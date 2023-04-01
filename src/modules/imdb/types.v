module imdb
import json
import rand

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
		r.id=rand.uuid_v4()
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
pub type Indexer =  fn (e string) []string
pub type Subscription =  fn (e string)
pub type MapOfStrings = map[string][]string
pub type MapOfMapOfStrings = map[string]MapOfStrings
pub type Updater =  fn (e string) string