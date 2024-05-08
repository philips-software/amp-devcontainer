fn factorial(number: i128) -> i128 {
    let mut factorial: i128 = 1;

    for i in 1..(number + 1) {
        factorial *= i;
    }

    return factorial;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_negative() {
        assert_eq!(factorial(-1), 1);
    }

    #[test]
    fn test_zero() {
        assert_eq!(factorial(0), 1);
    }
}
