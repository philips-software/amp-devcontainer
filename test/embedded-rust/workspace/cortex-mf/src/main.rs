#![no_std]
#![no_main]

use panic_halt as _;

use cortex_m::asm;
use cortex_m_rt::entry;

#[entry]
fn main() -> ! {
    asm::nop();

    loop {
    }
}
