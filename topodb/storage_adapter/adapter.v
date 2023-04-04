module storage_adapter
import os
import json
import topodb.types{Record,record_from_json}

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
}

pub struct FileStorageBackend{
	name string
	index_filename string
	data_filename string
	mut:
	index map[string][]FileIndex
	last u64
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
pub fn create_file_storage_backend(name string) !FileStorageBackend{
	mut index_filename:="${name}.db.index.json"
	mut data_filename:="${name}.db.json"
	mut index:=map[string][]FileIndex{}
	mut index_file:=open_or_create(index_filename,"{}")!
	index_file.close()
	mut data_file:=open_or_create(data_filename,"")!
	data_file.close()
	index=read_and_decode(index_filename)!
	return FileStorageBackend{
		name
		index_filename
		data_filename
		index
		0
	}

}

pub fn open_file_storage_backend(name string) !FileStorageBackend{

	mut fsb:=FileStorageBackend{
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
pub fn (mut fsb FileStorageBackend) push(rec Record) ! {
	fsb.index[rec.id]<<FileIndex{pos:u64(rec.data.len)+1+fsb.last,len:u64(rec.data.len)}
	mut dat:=open_or_create(fsb.data_filename,"")!
	dat.seek(0,os.SeekMode.end)!
	dat.writeln(rec.data)!
	fsb.last=fsb.last+u64(rec.data.len)+1
}
pub fn (mut fsb FileStorageBackend) push_all(all []Record) ! {
	for j in all {
		fsb.push(j)!
	}
}
pub fn (mut fsb FileStorageBackend) fetch(id string) ![]string {
	mut dat:=open_or_create(fsb.data_filename,"")!
	defer{
		dat.close()
	}
	idx:=fsb.index[id]
	mut list:=[]string{}
	for fp in idx {
		list<<dat.read_bytes_at(int(fp.len),fp.pos).str()
	}
	return list
}
pub fn (mut fsb FileStorageBackend) fetch_all(ids []string) ![]string {
	mut list:=[]string{}
	for id in ids {
		list<<fsb.fetch(id)!
	}
	return list
}
fn (mut fsb FileStorageBackend) get_last_pos(path string) !i64{
	mut dat:=os.open(fsb.data_filename)!
	defer{
		dat.close()
	}
	dat.seek(0, os.SeekMode.end)!
	pos:=dat.tell()!
	return pos
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
