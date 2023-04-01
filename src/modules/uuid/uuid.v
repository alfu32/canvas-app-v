module uuid
import rand
import rand.buffer {PRNGBuffer}
import rand.sys  {SysRNG}
import rand.seed  {time_seed_64,time_seed_32}
// Import the module of the generator you want to use
import rand.pcg32

import encoding.hex {encode}
import encoding.binary

fn convert_u64_to_bytes(u u64) []u8 {
    mut b := []u8{len: 8, init: 0}
    binary.little_endian_put_u64(mut b, u)
    return b
}
fn convert_u32_to_bytes(u u32) []u8 {
    mut b := []u8{len: 4, init: 0}
    binary.little_endian_put_u32(mut b, u)
    return b
}
fn convert_u16_to_bytes(u u16) []u8 {
    mut b := []u8{len: 2, init: 0}
    binary.little_endian_put_u16(mut b, u)
    return b
}


pub fn v0() string{
	ts:=time_seed_32()
	//mut rng:=SysRNG{PRNGBuffer{bytes_left:64},ts}
	mut rng := &rand.PRNG(pcg32.PCG32RNG{})

	// Optionally seed the generator
	rng.seed(seed.time_seed_array(pcg32.seed_len))
	mut a:=encode(convert_u16_to_bytes(rng.u16()))
	a+="-"
	a+=encode(convert_u32_to_bytes(ts))
	a+="-"
	a+=encode(convert_u64_to_bytes(rng.u64()))
	a+="-"
	a+=encode(convert_u32_to_bytes(rng.u32()))
	rng.free()
	return a
}
pub fn v1() !string{
	// Initialise the generator struct (note the `mut`)
	mut rng := &rand.PRNG(pcg32.PCG32RNG{})

	// Optionally seed the generator
	rng.seed(seed.time_seed_array(pcg32.seed_len))
	// Use functions of your choice
	a:=rng.u32n(100)!
	return encode(convert_u32_to_bytes(a))
}