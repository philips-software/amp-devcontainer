#include <array>

int main()
{
    std::array<int, 10> a = { 0 };
    const int* p = a.data();
    return p[10];
}
