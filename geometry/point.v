module geometry
import math

pub type Transformer = fn(f64) f64
[heap]
pub struct Transformer2D {
	pub:
	x Transformer
	y Transformer
}

[heap]
pub struct Point {
	pub:
	x f64
	y f64
}
pub fn point_new(x f64,y f64) Point{
	return Point{
		x
		y
	}
}
pub fn (p Point) clone() Point{
	mut q:=Point{
		x:p.x
		y:p.y
	}
	return q
}
pub fn (p Point) morph(v Transformer2D) Point{
	mut q:=Point{
		x:v.x(p.x)
		y:v.y(p.y)
	}
	return q
}
pub fn (p Point) isomorph(f fn(x f64) f64) Point{
	return p.morph(Transformer2D{f,f})
}
pub fn (p Point) add(o Point) Point{
	mut q:=Point{
		x:p.x+o.x
		y:p.y+o.y
	}
	return q
}
pub fn (p Point) sub(o Point) Point{
	mut q:=Point{
		x:p.x-o.x
		y:p.y-o.y
	}
	return q
}
pub fn (p Point) scale(o Point) Point{
	mut q:=Point{
		x:p.x*o.x
		y:p.y*o.y
	}
	return q
}
pub fn (p Point) mul(n f64) Point{
	mut q:=Point{
		x:p.x*n
		y:p.y*n
	}
	return q
}
pub fn (p Point) dot(o Point) f64{
	return p.x*o.x+p.y*o.y
}
pub fn (p Point) len2() f64{
	return p.dot(p)
}
pub fn (p Point) len() f64{
	return math.sqrt(p.len2())
}
pub fn (p Point) norm() Point{
	r := p.len()
	return p.mul(1/r)
}
pub fn (p Point) rad() f64{
	a := math.atan2(p.y,p.x)
	if a>0 {
		return a
	} else {
		return 2*math.pi+a
	}
}
pub fn (p Point) deg() f64{
	return math.degrees(p.rad())
}
pub fn (p Point) to_polar() Point{
	a := p.rad()
	r := p.len()
	return Point{r,a}
}
pub fn (p Point) to_orthogonal() Point{
	x := p.x*math.cos(p.y)
	y := p.x*math.sin(p.y)
	return Point{x,y}
}
pub fn (p Point) round(scale f64) Point{
	return p.isomorph(fn [scale](x f64) f64 { return math.round(x/scale)*scale})
}
pub fn (p Point) floor(scale f64) Point{
	return p.isomorph(fn [scale](x f64) f64 { return math.floor(x/scale)*scale})
}
pub fn (p Point) ceil(scale f64) Point{
	return p.isomorph(fn [scale](x f64) f64 { return math.ceil(x/scale)*scale})
}
pub fn (p Point) string() string{
	return "Point{${p.x},${p.y}}"
}

