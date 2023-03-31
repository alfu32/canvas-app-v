module box_test
import geometry {Point,Transformer,Box,BoxIterator}
import math { sqrt,atan2 }

fn test_box_create(){
	b := Box{Point{10,20},Point{100,75}}
	println(b.string())
	assert b.anchor.x==10
	assert b.anchor.y == 20
}
fn test_box_clone(){
	b := Box{Point{10,20},Point{100,75}}
	mut g:=b.clone()
	println(b.string())
	println(g.string())
	assert b.anchor.x == g.anchor.x
	assert b.anchor.y == g.anchor.y
}
fn test_box_for_each_slice(){
	b := Box{Point{10,20},Point{100,75}}
	println(b.string())
	mut count:=0

	for value in b.slices(10) {
		println("iter[]=[${value}]")
		count++
	}

	println(count)

	assert count==108
}
fn test_box_iterator(){
	bi := BoxIterator{start:Point{10,20},end:Point{100,75},step:Point{10,10}}
	mut count:=0

	for value in bi {
		println("iter[]=[${value}]")
		count++
	}

	println(count)

	assert count==89
}