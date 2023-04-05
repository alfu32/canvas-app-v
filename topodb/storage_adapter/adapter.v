module storage_adapter
import os
import json
import topodb.types{Record,record_from_json}
import time
import arrays

	pub const exports=[
	"StorageAdapterError"
	"FileStorageBackend"
]
pub struct StorageAdapterError{
	Error
	msg string
	code int
	cause ?IError
}
pub fn from_ierror(err IError) StorageAdapterError{
	return StorageAdapterError{msg:err.msg(),code:err.code(),cause:err}
}
pub fn from_string(str string) StorageAdapterError{
	return StorageAdapterError{msg:str,code:-1,cause:none}
}
pub fn (sae StorageAdapterError) msg()string{
	return sae.msg
}
pub fn (sae StorageAdapterError) code()int{
	return sae.code
}
pub struct FileIndex{
	pos u64
	len u64
	timestamp i64 = time.now().unix_time_milli()
}
enum IndexingStrategy{
	history=1
	last
}
pub interface StorageBackend{
	indexing_strategy IndexingStrategy
	dispose() !int
	add_to_index(rec Record)
	rebuild_index() !
	push(rec Record) !
	push_all(all []Record) !
	fetch(id string) ![]string
	fetch_all(ids []string) ![]string
}
pub struct FileStorageBackend{
	mut:
	indexing_strategy IndexingStrategy=IndexingStrategy.history
	name string
	index_filename string
	data_filename string
	index map[string][]FileIndex
	last u64
}
pub fn init_create(name string,indexing_strategy IndexingStrategy) !FileStorageBackend {

	mut fsb:=FileStorageBackend{indexing_strategy:indexing_strategy,name:name}
	fsb.index_filename="${fsb.name}.db.index.json"
	fsb.data_filename="${fsb.name}.db.json"
	fsb.index=map[string][]FileIndex{}
	mut index_file:=open_or_create(fsb.index_filename,"{}")!
	index_file.close()
	mut data_file:=open_or_create(fsb.data_filename,"")!
	data_file.close()
	fsb.index=read_and_decode(fsb.index_filename)!
	return fsb
}
pub fn init_open(name string,indexing_strategy IndexingStrategy) !FileStorageBackend{

	mut fsb:=FileStorageBackend{
		indexing_strategy:indexing_strategy,
		name:name,
		index_filename:"${name}.db.index.json",
		data_filename:"${name}.db.json",
		index:map[string][]FileIndex{}
	}

	mut index_file:=os.open(fsb.index_filename)!
	index_file.close()
	mut data_file:=os.open(fsb.data_filename)!
	data_file.close()
	fsb.last=0
	fsb.index=read_and_decode(fsb.index_filename)!
	return fsb
}
pub fn (mut fsb FileStorageBackend) dispose() !int {
	mut inx:=os.create(fsb.index_filename)!
	inx.write_string(json.encode_pretty(fsb.index))!
	inx.close()
	return -1
}
pub fn (mut fsb FileStorageBackend) add_to_index(rec Record) {
	match fsb.indexing_strategy{
		.history {
			fsb.index[rec.id]<<FileIndex{pos:fsb.last,len:u64(rec.data.len)}
		}
		.last {
			fsb.index[rec.id]=[FileIndex{pos:fsb.last,len:u64(rec.data.len)}]
		}
	}
	fsb.last=fsb.last+u64(rec.data.len)+1
}
pub fn (mut fsb FileStorageBackend) rebuild_index() ! {
	fsb.index=map[string][]FileIndex{}
	for line in os.read_lines(fsb.data_filename)! {
		r:=record_from_json(line)!
		fsb.add_to_index(r)
	}
}
pub fn (mut fsb FileStorageBackend) push_all(all []Record) ! {
	mut d:=os.open_append(fsb.data_filename)!
	for rec in all {
		d.writeln(rec.data)!
		fsb.add_to_index(rec)
	}
	d.close()
}
pub fn (mut fsb FileStorageBackend) fetch_history_all(ids []string) ![]string {
	mut dat:=open_or_create(fsb.data_filename,"")!
	dat.seek(0,os.SeekMode.start)!

	indexes:=fsb.index
	.keys()
	.filter(fn[ids](k string) bool{return k in ids})
	.map(fn[fsb](id string) []FileIndex {
		return fsb.index[id]
	})
	list:=arrays.flat_map[[]FileIndex, FileIndex](
		indexes,
		fn(items []FileIndex) []FileIndex {return items}
	).map(fn[dat](fi FileIndex) string{
		return dat.read_bytes_at(int(fi.len),fi.pos).bytestr()
	})
	dat.close()
	return list
}
pub fn (mut fsb FileStorageBackend) fetch_all(ids []string) ![]string {
	mut dat:=open_or_create(fsb.data_filename,"")!
	defer{
		dat.close()
	}
	mut list:=[]string{}
	for id in ids {
		fp:=fsb.index[id].last()
		list<<dat.read_bytes_at(int(fp.len),fp.pos).str()
	}
	return list
}

pub fn open_or_create(path string,default_contents string) !os.File {
	exists:=os.exists(path)
	mut fl:=os.File{}
	if !exists {
		fl= os.create(path)!
		os.write_file(path,default_contents)!
	} else {
		fl = os.open_append(path)!
	}
	return fl
}
pub fn read_and_decode(path string) !map[string][]FileIndex {
	data_string:=os.read_file(path)!
	return json.decode(map[string][]FileIndex,data_string)!
}
fn get_last_pos(path string) !i64{
	// ll:=os.execute('find ./$path -type f -exec wc -lc {} +')
	// return ll.output.trim(' ').split(' ')[0].u64()
	mut file:=os.open(path)!
	defer {
		file.close()
	}
	file.seek(0, os.SeekMode.end)!
	pos:=file.tell()!
	return pos

}
pub fn read_all_map[T](filename string,mapper fn (row string) !T) ![]T{
	mut strings:= os.read_lines(filename)!
	mut lines:=[]T{}
	for s in strings {
		lines<<mapper(s)!
	}
	return(lines)
}

fn append_all[T](fname string,list []T) ! {

	mut f := os.open_append(fname)!
	defer{
		f.close()
	}
	for item in list {
		f.writeln(item)!
		println("added $item")
	}
}

fn write_all[T](fname string,list []T) ! {

	mut f := os.create(fname)!
	defer{
		f.close()
	}
	for item in list {
		f.writeln(item)!
		println("added $item")
	}
}
fn read_all(fname string) ![]Record{
	mut strings:= os.read_lines(fname)!
	mut lines:=[]Record{}
	for s in strings {
		lines<<record_from_json(s)!
	}
	return(lines)
}
