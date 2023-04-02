module std

pub fn [A,T] (arr []T) reduce(reducer fn(mut acc A,val T,index u64) A,mut initial A){
	mut agg:=initial
	for ix,val in arr {
		agg:=reducer(agg,val,ix)
	}
	return agg
}