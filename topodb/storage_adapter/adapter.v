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
	is_valid bool=true
	name string
	index_filename string
	data_filename string
	mut:
	index map[string][]FileIndex
	index_file os.File
	data_file os.File
	last u64
}
pub fn open_or_create(path string,default_contents string) !os.File {
	exists:=os.exists(path)
	mut fl:=os.File{}
	if !exists {
		fl= os.create(path) or {
			panic("ECREATE ${err.msg()}")
			// from_ierror(err)
		}
		os.write_file(path,default_contents)or{
			panic("EWRITE ${err.msg()}")
		}
	} else {
		fl = os.open_append(path) or {
			panic("EAPPEND ${err.msg()}")
			// from_ierror(err)
		}
	}
	return fl
}
pub fn read_and_decode(path string) !map[string][]FileIndex {
	data_string:=os.read_file(path) or {
		println("ERR1 read_and_decode ${err.code()} ${err.msg()}")
		// from_ierror(err)
		"{}"
	}
	return json.decode(map[string][]FileIndex,data_string) or {
		println("ERR2 read_and_decode ${err.code()} ${err.msg()}")
		// from_ierror(err)
		map[string][]FileIndex{}
	}
}
pub fn create_file_storage_backend(name string) !FileStorageBackend{
	mut index_filename:="${name}.db.index.json"
	mut data_filename:="${name}.db.json"
	mut index_file:=os.File{}
	mut data_file:=os.File{}
	mut is_valid:=true
	mut index:=map[string][]FileIndex{}
	index_file=open_or_create(index_filename,"{}") or {
		is_valid=false
		// from_ierror(err)
		os.File{}
	}
	data_file=open_or_create(data_filename,"") or {
		is_valid=false
		// from_ierror(err)
		os.File{}
	}
	if is_valid {
		index=read_and_decode(index_filename) or {
			is_valid=false
			// from_ierror(err)
			map[string][]FileIndex{}
		}
	}
	if is_valid {
		return FileStorageBackend{
			is_valid
			name
			index_filename
			data_filename
			index
			index_file
			data_file
			0
		}
	}else{
		return IError(StorageAdapterError{code:1,msg:"could not create the storage backend",cause:none})
	}

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
pub fn (mut fsb FileStorageBackend) push(rec Record){
	fsb.index[rec.id]<<FileIndex{pos:u64(rec.data.len)+1+fsb.last,len:u64(rec.data.len)}
	fsb.data_file.writeln(rec.data) or {
		panic("could not write $rec to $fsb.data_filename")
	}
	fsb.last=fsb.last+u64(rec.data.len)+1
}
pub fn (mut fsb FileStorageBackend) push_all(all []Record){
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
fn (mut fsb FileStorageBackend) get_last_pos(path string) i64{
	// ll:=os.execute('find ./$path -type f -exec wc -lc {} +')
	// return ll.output.trim(' ').split(' ')[0].u64()
	fsb.data_file.seek(0, os.SeekMode.end) or{
		panic("couldn't seek on file ${fsb.data_filename}")
	}
	pos:=fsb.data_file.tell() or{
		panic("couldn't tell on file ${fsb.data_filename}")
	}
	return pos
}

fn get_last_pos(path string) i64{
	// ll:=os.execute('find ./$path -type f -exec wc -lc {} +')
	// return ll.output.trim(' ').split(' ')[0].u64()
	mut file:=os.open(path) or { panic("could not open $path as file ") }
	defer {
		file.close()
	}
	file.seek(0, os.SeekMode.end) or{
		panic("couldn't seek on file $path")
	}
	pos:=file.tell() or {
		panic("couldn't tell on file $path")
	}
	return pos

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
fn read_all(fname string) []Record{
	mut strings:= os.read_lines(fname) or {
		panic("ERROPEN file $fname")
	}
	mut lines:=[]Record{}
	for s in strings {
		lines<<record_from_json(s)
	}
	return(lines)
}
