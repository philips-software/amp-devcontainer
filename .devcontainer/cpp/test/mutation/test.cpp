#include <gmock/gmock.h>

int Factorial(int n)
{
  int result = 1;
  for (int i = 1; i <= n; i++)
    result *= i;

  return result;
}

TEST(FactorialTest, Negative)
{
    EXPECT_EQ(1, Factorial(-1));
}

TEST(FactorialTest, Zero)
{
    EXPECT_EQ(1, Factorial(0));
}
