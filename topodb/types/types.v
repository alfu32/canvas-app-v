module types
import json
import rand

pub const exports=[
	"RowMapper"
	"TypedRecord"
	"Record"
	"EventType"
	"Indexer"
	"Subscription"
	"MapOfStrings"
	"MapOfMapOfStrings"
	"Updater"
]

pub interface RowMapper[T]{
	map_from_string fn (row string) T
}
pub struct JsonRowMapper[T]{
	map_from_string fn (row string) T
}
pub struct TypedRecord[T]{
	pub mut:
	id string
	data T
}
pub fn typed_record_from_json[T](s string) !TypedRecord[T]{
	r:=record_from_json(s)!
	tr:=TypedRecord[T]{
		id:r.id
		data:r.cast[T]()!
	}
	return tr
}
pub struct Record{
	pub mut:
	id string
	data string
}
pub fn record_from_json(s string) !Record{
	mut r:=json.decode(Record,s)!
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
pub fn (r Record) cast[T]() !T{
	d:=json.decode(T,r.data)!
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
pub type Indexer =  fn (e string) ![]string
pub type Subscription =  fn (record string) !
pub type MapOfStrings = map[string][]string
pub type MapOfMapOfStrings = map[string]MapOfStrings
pub type Updater =  fn (e string) string
