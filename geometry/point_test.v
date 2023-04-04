module geometry
import math

fn test_point_create(){
	p := geometry.Point{
		10,20
	}
	println(p.string())
	assert p.x==10
	assert p.y == 20
}
fn test_point_clone(){
	mut p := geometry.Point{
		10,20
	}
	mut q:=p.clone()

	println(p.string())
	println(q.string())

	assert q.x==p.x
	assert q.y == p.y
	assert p.string() == q.string()
	println(&p)
	println(&q)
}
fn test_point_morph(){
	mut p := geometry.Point{
		10,20
	}
	mut q:=p.morph(geometry.Transformer2D{
		fn (x f64) f64 {return x+1}
		fn (x f64) f64 {return x*x}
	})

	println(p.string())
	println(q.string())

	assert q.x==11
	assert q.y == 400
	assert p.string() != q.string()
	assert &p != &q
}
fn test_point_isomorph(){
	mut p := geometry.Point{
		10,20
	}
	mut q:=p.isomorph(fn (x f64) f64{return x+1})

	println(p.string())
	println(q.string())

	assert q.x==11
	assert q.y == 21
	assert p.string() != q.string()
	assert &p != &q
}
fn test_point_add(){
	mut p := geometry.Point{
		10,20
	}
	mut q:=p.add(p)

	println(p.string())
	println(q.string())

	assert q.x==20
	assert q.y == 40
	assert p.string() != q.string()
	assert &p != &q
}
fn test_point_sub(){
	mut p := geometry.Point{
		10,20
	}
	mut q:=p.sub(p)

	println(p.string())
	println(q.string())

	assert q.x==0
	assert q.y == 0
	assert p.string() != q.string()
	assert &p != &q
}
fn test_point_scale(){
	mut p := geometry.Point{
		10,20
	}
	mut q:=p.scale(p)

	println(p.string())
	println(q.string())

	assert q.x==100
	assert q.y == 400
	assert p.string() != q.string()
	assert &p != &q
}
fn test_point_mul(){
	mut p := geometry.Point{
		10,20
	}
	mut q:=p.mul(2)

	println(p.string())
	println(q.string())

	assert q.x==20
	assert q.y == 40
	assert p.string() != q.string()
	assert &p != &q
}
fn test_point_dot(){
	mut p := geometry.Point{
		3,4
	}
	mut q := geometry.Point{
		5,6
	}
	mut d:=p.dot(q)

	println(p.string())
	println(q.string())
	println(d)

	assert d==39
}
fn test_point_len2(){
	mut p := geometry.Point{
		3,4
	}
	mut q:=p.len2()

	println(p.string())
	println(q)

	assert q==25
}
fn test_point_len(){
	mut p := geometry.Point{
		3,4
	}
	mut q:=p.len()

	println(p.string())
	println(q)

	assert q==5
}
fn test_point_norm(){
	mut p := geometry.Point{
		1,1
	}
	mut q:=p.norm()

	println(p.string())
	println(q.string())

	assert q.x==math.sqrt2/2
	assert q.y==math.sqrt2/2
}
fn test_point_rad(){
	mut p := geometry.Point{
		1,1
	}
	println(p.rad())
	assert p.rad()==math.pi_4
	p = geometry.Point{
		-1,1
	}
	println(p.rad())
	assert p.rad()==math.pi_4*3
	p = geometry.Point{
		-1,-1
	}
	println(p.rad())
	assert p.rad()==math.pi_4*5
	p = geometry.Point{
		1,-1
	}
	println(p.rad())
	assert p.rad()==math.pi_4*7
	p = geometry.Point{
		1,math.sqrt_3
	}
	println(p.rad())
	assert p.rad()==math.pi/3
	p = geometry.Point{
		-1,math.sqrt_3
	}
	println(p.rad())
	println(2*math.pi/3)
	println(math.degrees(p.rad()))
	assert math.tolerance(p.rad(),2*math.pi/3,0.1)
	p = geometry.Point{
		1,-math.sqrt_3
	}
	println(p.rad())
	println(5*math.pi/3)
	assert p.rad()==5*math.pi/3
}
fn test_point_deg(){
	mut p := geometry.Point{
		1,1
	}
	println(p.deg())
	assert p.deg()==45
	p = geometry.Point{
		-1,1
	}
	println(p.deg())
	assert p.deg()==135
	p = geometry.Point{
		-1,-1
	}
	println(p.deg())
	assert p.deg()==225
	p = geometry.Point{
		1,-1
	}
	println(p.deg())
	assert p.deg()==315
	p = geometry.Point{
		1,math.sqrt_3
	}
	println(p.deg())
	assert math.tolerance(p.deg(),60,0.1)
	p = geometry.Point{
		-1,math.sqrt_3
	}
	println(p.deg())
	assert math.tolerance(p.deg(),120,0.1)
	p = geometry.Point{
		1,-math.sqrt_3
	}
	println(p.deg())
	println(5*math.pi/3)
	assert math.tolerance(p.deg(),300,0.1)
}
fn test_point_to_polar(){
	mut p := geometry.Point{
		1,1
	}
	mut q:=p.to_polar()
	a:=math.degrees(q.y)

	println(p.string())
	println(a)

	assert math.tolerance(q.x,1.41,0.1)
	assert a==45
}
fn test_point_to_orthogonal(){
	mut p := geometry.Point{
		1,1
	}
	mut q:=p.to_polar()
	mut u:=q.to_orthogonal()

	println(p.string())
	println(q.string())
	println(u.string())

	assert math.tolerance(p.x,1,0.1)
	assert math.tolerance(p.y,1,0.1)
}
fn test_point_round(){
	mut p := geometry.Point{
		1234,5678
	}
	mut u:=p.round(10)
	mut v:=p.round(100)
	mut w:=p.round(1000)

	println(u.string())
	println(v.string())
	println(w.string())

	assert u.x==1230
	assert v.x==1200
	assert w.x==1000

	assert u.y==5680
	assert v.y==5700
	assert w.y==6000
}
fn test_point_floor(){
	mut p := geometry.Point{
		1234,5678
	}
	mut u:=p.floor(10)
	mut v:=p.floor(100)
	mut w:=p.floor(1000)

	println(u.string())
	println(v.string())
	println(w.string())

	assert u.x==1230
	assert v.x==1200
	assert w.x==1000

	assert u.y==5670
	assert v.y==5600
	assert w.y==5000
}
fn test_point_ceil(){
	mut p := geometry.Point{
		1234,5678
	}
	mut u:=p.ceil(10)
	mut v:=p.ceil(100)
	mut w:=p.ceil(1000)

	println(u.string())
	println(v.string())
	println(w.string())

	assert u.x==1240
	assert v.x==1300
	assert w.x==2000

	assert u.y==5680
	assert v.y==5700
	assert w.y==6000
}
