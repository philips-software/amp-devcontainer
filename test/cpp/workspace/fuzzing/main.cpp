#include <cstdint>

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, std::size_t size)
{
    if (size > 0 && data[0] == 'H')
        if (size > 1 && data[1] == 'I')
            __builtin_trap();

    return 0;
}
