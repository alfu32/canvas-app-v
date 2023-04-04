module storage_adapter
import geometry
import rand
import os

import topodb.imdb{create_db}

import topodb.types{Record,record_from_json}


fn gen_some(n u8) []string{
	mut list:=[]string{}
	for i in 0..10 {
		list<<('{"id":"${rand.uuid_v4()}","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}')
	}
	return list
}
fn test_create_storage_backend_happy(){
	mut fsb:=create_file_storage_backend("zaz")!
	println(fsb)
		fsb.free()
	println(fsb)
	mut fsb2:=create_file_storage_backend("zaz")!
	println(fsb2)
		fsb2.free()
	println(fsb2)
	assert 1==1
}
fn test_create_storage_backend_bad_access(){
	mut fsb1:=create_file_storage_backend("/zaz")or{
		FileStorageBackend{
			is_valid: false
			name: ''
			index_filename: ''
			data_filename: ''
			index: {}
			index_file: os.File{}
			data_file: os.File{}
			last: 0
		}
	}
	println(fsb1)
	fsb1.free()
	println(fsb1)
	mut fsb2:=create_file_storage_backend("/zaz")or{
			FileStorageBackend{
			is_valid: false
			name: ''
			index_filename: ''
			data_filename: ''
			index: {}
			index_file: os.File{}
			data_file: os.File{}
			last: 0
		}
	}
	println(fsb2)
	fsb2.free()
	println(fsb2)
	expresult:="storage_adapter.FileStorageBackend{
    name: 'ERROPEN file /zaz.db.index.json could not be opened because Permission denied'
    index_filename: 'topodb.storage_adapter.StorageAdapterError: ERROPEN file /zaz.db.index.json could not be opened because Permission denied'
    data_filename: 'topodb.storage_adapter.StorageAdapterError: ERROPEN file /zaz.db.index.json could not be opened because Permission denied'
    index: {}
    index_file: os.File{
        cfile: 0
        fd: 0
        is_opened: false
    }
    data_file: os.File{
        cfile: 0
        fd: 0
        is_opened: false
    }
    last: 1
}"
	assert fsb1.str()==expresult
	assert fsb2.str()==expresult
}



pub fn test_read_all_map(){
	fname:="test_read_all.db.json"
	list:=gen_some(10)
	write_all(fname,list)
	mm:=read_all_map[geometry.Box](fname,fn(s string) geometry.Box {
		return record_from_json(s).cast[geometry.Box]()
	})
	println(mm)
	assert mm.len==10

}

pub fn test_write_all(){
	fname:="test_write_all.db.json"
	list:=gen_some(10)
	write_all(fname,list)
	assert 1==1

}
pub fn test_read_all(){
	fname:="test_read_all.db.json"
	list:=gen_some(10)
	write_all(fname,list)
	gen:=list.map(record_from_json(it))
	data:=read_all(fname)
	for i,v in gen {
		assert v == data[i]
	}
}
fn test_imdb_events_with_file_io(){
	println('----------------------------------------' + @MOD + '..' + @FN)
	println('file: ' + @FILE + ':' + @LINE + ' | fn: ' + @MOD + '..' + @FN)
	mut db:=create_db("vspace")
	db.index_by("box",fn(str string)[]string{
		record:=record_from_json(str)
		box:=record.cast[geometry.Box]()
		return box.all_slices(20).map( fn (slice geometry.Box) string {
			return "${slice.anchor.x},${slice.anchor.y}@20"
		})
	})
	file_index:=[]int{}

	// >> do something with file; file is locked <<

	db.on('add',fn [db](event_data string){
		fname:="${db.name}.db.json"
		mut f := os.open_append(fname) or {
			panic("ERROPEN file $fname")
		}
		r:=record_from_json(event_data)
		f.writeln(event_data)or {
			panic("couldn't write $event_data to $fname")
		}
		println("added $event_data")
		f.close()
	})
	db.on('remove',fn (event_data string){
		println("removed $event_data")
	})
	db.on('update',fn (event_data string){
		println("updated $event_data")
	})

	db.add('{"id":"werwer","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}')
	db.add('{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":10,"y":10}}')
	db.add('{"id":"xcvxc","anchor":{"x":15,"y":10},"size":{"x":40,"y":40}}')
	db.add('{"id":"tyuty","anchor":{"x":20,"y":90},"size":{"x":20,"y":20}}')
	db.add('{"id":"acpi","anchor":{"x":80,"y":20},"size":{"x":20,"y":40}}')

	db.update("werwer",fn(a string)string { return '{"id":"werwer","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}'})
	db.update("asdf",fn(a string)string { return '{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":10,"y":10}}'})
	db.update("xcvxc",fn(a string)string { return '{"id":"xcvxc","anchor":{"x":15,"y":10},"size":{"x":40,"y":40}}'})
	db.update("tyuty",fn(a string)string { return '{"id":"tyuty","anchor":{"x":20,"y":90},"size":{"x":20,"y":20}}'})
	db.update("acpi",fn(a string)string { return '{"id":"acpi","anchor":{"x":80,"y":20},"size":{"x":20,"y":40}}'})


	db.remove('{"id":"werwer","anchor":{"x":55,"y":80},"size":{"x":20,"y":40}}')
	db.remove('{"id":"asdf","anchor":{"x":10,"y":20},"size":{"x":10,"y":10}}')
	db.remove('{"id":"xcvxc","anchor":{"x":15,"y":10},"size":{"x":40,"y":40}}')
	db.remove('{"id":"tyuty","anchor":{"x":20,"y":90},"size":{"x":20,"y":20}}')
	db.remove('{"id":"acpi","anchor":{"x":80,"y":20},"size":{"x":20,"y":40}}')

	println(db)
	assert 1==1
}
