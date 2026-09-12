#include <array>

int main()
{
    std::array<int, 10> a = { 0 };
    const int* p = a.data();
    // Volatile prevents optimizing builds from folding away the out-of-bounds read.
    volatile int index = 10;
    return p[index];
}
