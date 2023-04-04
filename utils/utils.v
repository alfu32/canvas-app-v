module utils

import rand


pub fn toast(message string) string{
	n:=rand.u32()
	return "$message ($n)"
}


