module imdb_storage
import imdb
import os

pub struct FileIndex{
	object string
	object_id string
	line u64
}

pub struct FileStorageBackend{
	name string
	index map[string][]string
}


fn get_line_nmbr(path string) u64{
	ll:=os.execute('find ./$path -type f -exec wc -lc {} +')
	return ll.output.trim(' ').split(' ')[0].u64()
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

pub fn (fsb FileStorageBackend) store(id string,data string){
	storage_fname:="${fsb.name}.json"
	index_fname:="${fsb.name}.index.json"
	ll:=get_line_nmbr(storage_fname)
	pp:=FileIndex{
		data,
		id,
		ll+1,
	}
	println(index_fname)
	println(pp)
	mut f := os.open_append(storage_fname) or {
		panic("ERROPEN file $storage_fname")
	}
	f.writeln(data)or {
		panic("couldn't write $data to $storage_fname")
	}
	println("added $data")
	f.close()

} 
