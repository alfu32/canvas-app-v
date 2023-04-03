module imdb_storage
import imdb
import os
import json

pub struct FileIndex{
	pos u64
	len u64
}

pub struct FileStorageBackend{
	name string
	index_filename string
	data_filename string
	mut:
	index map[string][]FileIndex
	index_file os.File
	data_file os.File
	last u64
}
pub fn create_file_storage_backend(name string) FileStorageBackend{
	
	mut fsb:=FileStorageBackend{
		name:name,
		index_filename:"${name}.db.index.json",
		data_filename:"${name}.db.json",
		index:map[string][]FileIndex{}
		last:0
	}

	fsb.index_file=os.create(fsb.index_filename) or {
		panic("ERRCREATE file $fsb.index_filename could not be created")
	}
	fsb.data_file=os.create(fsb.data_filename) or {
		panic("ERRCREATE file $fsb.data_filename could not be created")
	}
	mut index_string_json:= os.read_file(fsb.index_filename) or {
		panic("ERROPEN file $fsb.index_filename")
	}
	fsb.index=json.decode(map[string][]FileIndex,index_string_json) or {
		panic("ERRJSON file $fsb.index_filename is not valid json")
	}
	return fsb
}

pub fn open_file_storage_backend(name string) FileStorageBackend{
	
	mut fsb:=FileStorageBackend{
		name:name,
		index_filename:"${name}.db.index.json",
		data_filename:"${name}.db.json",
		index:map[string][]FileIndex{}
	}

	fsb.index_file=os.open(fsb.index_filename) or {
		panic("ERROPEN file $fsb.index_filename could not be opened")
	}
	fsb.data_file=os.open(fsb.data_filename) or {
		panic("ERROPEN file $fsb.data_filename could not be opened")
	}
	fsb.last=0
	mut index_string_json:= os.read_file(fsb.index_filename) or {
		panic("ERROPEN file $fsb.index_filename")
	}
	fsb.index=json.decode(map[string][]FileIndex,index_string_json) or {
		panic("ERRJSON file $fsb.index_filename is not valid json")
	}
	return fsb
}
pub fn (mut fsb FileStorageBackend) free(){
	fsb.index_file.close()
	fsb.data_file.close()
}

pub fn (mut fsb FileStorageBackend) push(rec imdb.Record){
	fsb.index[rec.id]<<FileIndex{pos:u64(rec.data.len)+1+fsb.last,len:u64(rec.data.len)}
	fsb.data_file.writeln(rec.data) or {
		panic("could not write $rec to $fsb.data_filename")
	}
	fsb.last=fsb.last+u64(rec.data.len)+1
}
pub fn (mut fsb FileStorageBackend) push_all(all []imdb.Record){
	for j in all {
		fsb.push(j)
	}
}
pub fn (mut fsb FileStorageBackend) fetch(id string) []string {
	idx:=fsb.index[id]
	mut list:=[]string{}
	for fp in idx {
		list<<fsb.data_file.read_bytes_at(int(fp.len),fp.pos).str()
	}
	return list
}
pub fn (mut fsb FileStorageBackend) fetch_all(ids []string) []string {
	mut list:=[]string{}
	for id in ids {
		list<<fsb.fetch(id)
	}
	return list
}


fn get_line_nmbr(path string) u64{
	ll:=os.execute('find ./$path -type f -exec wc -lc {} +')
	return ll.output.trim(' ').split(' ')[0].u64()
}

pub fn read_all_map[T](filename string,mapper fn (row string) T) []T{
	mut strings:= os.read_lines(filename) or {
		panic("ERROPEN file $filename")
	}
	mut lines:=[]T{}
	for s in strings {
		lines<<mapper(s)
	}
	return(lines)
}

fn append_all[T](fname string,list []T){

	mut f := os.open_append(fname) or {
		panic("ERROPEN file $fname")
	}
	for item in list {
		f.writeln(item)or {
			panic("couldn't write $item to $fname")
		}
		println("added $item")
	}
	f.close()
}

fn write_all[T](fname string,list []T){

	mut f := os.create(fname) or {
		panic("ERROPEN file $fname")
	}
	for item in list {
		f.writeln(item)or {
			panic("couldn't write $item to $fname")
		}
		println("added $item")
	}
	f.close()
}
fn read_all(fname string) []imdb.Record{
	mut strings:= os.read_lines(fname) or {
		panic("ERROPEN file $fname")
	}
	mut lines:=[]imdb.Record{}
	for s in strings {
		lines<<imdb.record_from_json(s)
	}
	return(lines)
}
