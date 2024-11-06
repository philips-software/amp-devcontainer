#include <ranges>
#include <thread>
#include <vector>

int main()
{
    std::vector<std::jthread> threads;
    int counter = 0;

    for (auto i : std::ranges::iota_view(0, 10))
        threads.emplace_back(std::jthread([&counter] {
            for (auto j : std::ranges::iota_view(0, 1000))
                ++counter;
        }));

    return counter;
}
