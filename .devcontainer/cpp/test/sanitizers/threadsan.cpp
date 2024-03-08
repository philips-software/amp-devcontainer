#include <thread>

int main()
{
    int i = 0;

    std::thread t([&] { i = 10; });
    i = 20;
    t.join();

    return i;
}
