module uuid_test
import uuid {v0,v1}
import encoding.hex {encode}
import range {RangeIterator}

fn test_uuid(){
	mut prev:=""
	mut ri:=RangeIterator{start:0,end:1000,step:1}
	for v,i in ri {
		a:=v0()
		println(a)
		assert prev!=a
		prev=a
	}
}