#include <thread>
#include <vector>

int main()
{
    std::vector<std::jthread> threads;
    int counter = 0;

    for (int i = 0; i < 10; ++i)
        threads.emplace_back(std::jthread([&counter] {
            for (int j = 0; j < 1000; ++j)
                ++counter;
        }));

    return counter;
}
