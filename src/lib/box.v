module geometry
import geometry {Point,Transformer}
import range {RangeIterator} 

[heap]
pub struct BoxIterator {
	mut:
	index u64
	current Point
	pub:
	start Point
	end Point
	step Point
}
pub fn (mut iter BoxIterator) next() ?Box {
	if iter.current.x > iter.end.x {
		if iter.current.y > iter.end.y  {
			return none
		}else{
			iter.current=Point{x:iter.start.x,y:iter.current.y+iter.step.y}
		}
	}else{
		if iter.current.y > iter.end.y  {
			return none
		}else{
			iter.current=Point{x:iter.current.x+iter.step.x,y:iter.current.y}
		}
	}
	iter.index++
	return Box{
				anchor:iter.current.clone(),
				size:iter.step.clone()
			}
}

[heap]
pub struct Box {
	pub:
	anchor Point
	size Point
}

pub fn (b Box) clone() Box{
	return Box{
		b.anchor.clone()
		b.size.clone()
	}
}

pub fn (b Box) corner() Point{
	return b.anchor.add(b.size)
}
pub fn (b Box) contains_point(p Point) bool{
	a:=b.anchor
	c:=b.corner()
	return a.x<=p.x && p.x<=c.x && a.y<=p.y && p.y<=c.y
}
pub fn (b Box) corners() []Point {
	a:=b.anchor
	c:=b.corner()
	mut r:=[a.clone()]
	r<<Point{a.x,c.y}
	r<<c.clone()
	r<<Point{c.x,a.y}
	return r
}
pub fn (b Box) contains_box(o Box) bool{
	mut a:=true
	for corner in o.corners(){
		a=a && b.contains_point(corner)
	}
	return a
}
pub fn (b Box) intersects_box(o Box) bool{
	mut a:=false
	for corner in o.corners(){
		a=a || b.contains_point(corner)
	}
	mut z:=false
	for corner in b.corners(){
		z=z || o.contains_point(corner)
	}
	return a || z
}

pub fn (b Box) bounding_box(scale f64) Box{
	a0:=b.anchor.floor(scale)
	a1:=b.corner().ceil(scale)
	sz:=a1.sub(a0)
	return Box{a0,sz}
}

pub fn (bx Box) slices(scale f64) BoxIterator{
	a:=bx.anchor.floor(scale)
	b:=bx.corner().ceil(scale)
	return BoxIterator{
		index:0
		current:a.clone(),
		start:a.clone(),
		end:b.clone(),
		step:Point{scale,scale}
	}
}

pub fn (b Box) string() string{
	return "Box{${b.anchor.string()},${b.size.string()}}"
}
