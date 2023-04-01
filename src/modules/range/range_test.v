module range_test
import range

fn test_range_create(){
	mut ri := range.RangeIterator{
		start:1
		end:100
		step: 10
	}
	println(ri.string())

	assert ri.start == 1
}
fn test_range_iterate(){
	mut ri := range.RangeIterator{
		start:1
		end:100
		step: 10
	}
	println(ri.string())
	mut count:=0

	for value,index in ri {
		println("iter[$index]=[${value},${index}]")
		count++
	}

	println(count)

	assert count == 11
}