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

pub fn (b Box) bounding_box(scale f64) Box{
	a0:=b.anchor.floor(scale)
	a1:=b.corner().ceil(scale)
	sz:=a1.sub(a0)
	return Box{a0,sz}
}

pub fn (bx Box) slices(scale f64) BoxIterator{
	a:=bx.anchor.floor(scale)
	b:=bx.corner().ceil(scale)
	sz:=point_new(scale,scale)
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
