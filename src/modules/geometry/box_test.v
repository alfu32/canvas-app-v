module box_test
import geometry {Point,Transformer2D,Box,BoxIterator}
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
fn test_box_corner(){
	b := Box{Point{10,20},Point{100,75}}
	c:=b.corner()
	println(b.string())
	println(c.string())
	assert b.anchor.x+b.size.x == c.x
	assert b.anchor.y+b.size.y == c.y
}
fn test_box_contains_point(){
	b := Box{Point{10,20},Point{100,75}}
	a:=b.anchor
	c:=b.corner()
	pin:=Point{11,21}
	pout:=Point{9,19}
	assert b.contains_point(a)
	assert b.contains_point(c)
	assert b.contains_point(pin)
	assert !b.contains_point(pout)
}
fn test_box_contains_box(){
	b := Box{Point{10,20},Point{100,75}}
	b2 := Box{Point{20,20},Point{10,10}}
	assert b.contains_box(b2)
}
fn test_box_intersects_box(){
	b := Box{Point{10,20},Point{100,75}}
	b2 := Box{Point{20,20},Point{10,10}}
	b3 := Box{Point{0,0},Point{40,50}}
	assert b.intersects_box(b2)
	assert b.intersects_box(b3)
}
fn test_box_corners(){
	b := Box{Point{10,20},Point{100,75}}
	c:=b.corners()
	assert c.len == 4
	println(c[0].string())
	println(c[1].string())
	println(c[2].string())
	println(c[3].string())
	assert c[0]==b.anchor
	assert c[1]==Point{10,95}
	assert c[2]==b.corner()
	assert c[3]==Point{110,20}
}
fn test_box_for_each_slice(){
	b := Box{Point{10,20},Point{100,75}}
	println(b.string())
	mut count:=0

	for value in b.slices(20) {
		println("iter[]=[${value}]")
		count++
	}

	println(count)

	assert count==40
}
fn test_box_all_slices(){
	bx := Box{Point{10,20},Point{100,75}}
	println(bx.string())
	slices:=bx.all_slices(20)

	println(slices)

	assert slices.len==40
}
fn test_box_iterator(){
	bi := BoxIterator{start:Point{10,20},end:Point{100,75},step:Point{20,20}}
	mut count:=0

	for value in bi {
		// println("iter[]=[${value}]")
		count++
	}

	println(count)

	assert count==25
}