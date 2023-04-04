module std

pub fn (arr []T) reduce[A,T] (reducer fn(mut acc A,val T,index u64) A,mut initial A) A{
	mut agg:=initial
	for ix,val in arr {
		agg=reducer(agg,val,ix)
	}
	return agg
}
