module range
/// import math

type Numeric = i8|u8|i16|u16|i32|u32|f32|i64|u64|f64
/// pub fn floor(n Numeric,s Numeric) Numeric{
/// 	return math.floor(n/s)*s
/// }
/// pub fn ceil(n Numeric,s Numeric) Numeric{
/// 	return math.ceil(n/s)*s
/// }
/// pub fn each(a Numeric,b Numeric,step Numeric,do fn(v Numeric,i u64)){
/// 	r0 := floor(math.min(a,b),step)
/// 	r1 := ceil(math.max(a,b),step)
/// 	r0=floor
/// }

pub struct RangeIteratorTuple{
	pub:
	value f64
	index u64
}
pub struct RangeIterator{
	mut:
	index u64
	current f64
	pub:
	start f64
	end f64
	step f64
}
pub fn (ri RangeIterator) string() string{
	return "
	RangeIterator{
		mut:
		${ri.index} u64
		${ri.current} f64
		pub:
		${ri.start} f64
		${ri.end} f64
		${ri.step} f64
	}
	"
}
pub fn (mut iter RangeIterator) next() ?f64 {
	if iter.current > iter.end {
		return none
	}
	defer {
		iter.index++
		iter.current+=iter.step
	}
	return iter.current
}