use std::io::{self, Read};

fn main() {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).unwrap();
    input = input.trim().to_string();
    let mut silver = 0;
    let mut gold = 0;
    for range in input.split(',') {
        let mut ints = range.split('-');
        let a: i64 = ints.next().unwrap().parse::<i64>().expect("failed to parse");
        let b: i64 = ints.next().unwrap().parse::<i64>().expect("failed to parse");
        for i in a..=b {
            let digits = count_digits(i);
            if is_silver_invalid(digits, i) { silver += i; }
            if is_gold_invalid(digits, i) { gold += i; }
        }
    }
    println!("{silver}\n{gold}");
}

fn count_digits(num: i64) -> i32 {
    let mut digits = 0;
    let mut i = num;
    while i > 0 {
        digits += 1;
        i /= 10;
    }
    return digits;
}

fn check(reps: i32, digits: i32, num: i64) -> bool {
    if digits % reps != 0 { return false; }
    let mut width = digits / reps;
    let mut i = num;
    let mut pattern = 0;
    let mut tens = 1;
    while width > 0 {
        width -= 1;
        pattern += (i % 10) * tens;
        tens *= 10;
        i /= 10;
    }
    // e.g., num is 123123123, digits is 9, reps is 3, width is 3,
    // i is 123123, pattern is 123, tens is 1000
    for _ in 1..reps {
        if (i % tens) != pattern { break; }
        i /= tens;
    }
    return i == 0;
}

fn is_silver_invalid(digits: i32, num: i64) -> bool {
    return check(2, digits, num);
}

fn is_gold_invalid(digits: i32, num: i64) -> bool {
    for reps in 2..=digits {
        if check(reps, digits, num) { return true; }
    }
    return false;
}
