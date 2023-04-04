module types

import rand
import range


fn test_example_uuid(){
	mut prev:=""
	mut ri:=range.RangeIterator{start:0,end:1000,step:1}
	for v,i in ri {
		uuid_v := rand.uuid_v4()
		println(uuid_v)
		assert prev!=uuid_v
		prev=uuid_v
	}
}
