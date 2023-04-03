module json_decode_maps_test
import json

fn test_json_map_map(){
	mut mm:=map[string][]u64
	mm["odd"]=[u64(1),3,5,7,9]
	mm["even"]=[u64(2),4,6,8,10]
	mm["three"]=[u64(0),3,6,9,12,15,18,21]
	mm["five"]=[u64(0),5,10,15,20,25,30]
	s:=json.encode(mm)
	println(s)
	d:=json.decode(map[string][]u64,s) or {
		panic("dude !")
	}
	println(d)
	assert mm == d
	assert 1==1
}