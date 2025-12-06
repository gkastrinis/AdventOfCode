use std::io::{self, BufRead};

fn main() {
    print_silver(io::stdin());
    // print_gold(io::stdin());
}

fn compute(prev: &mut i64, op: char, next: i64) {
    *prev = if op == '+' { *prev + next } else { *prev * next };
}

fn print_silver(stdin: io::Stdin) {
    let mut lines: Vec<Vec<String>> = stdin
        .lock()
        .lines()
        .map(|l| l
            .unwrap()
            .split_whitespace()
            .map(|x| x.to_string())
            .collect()
        )
        .collect();
    let ops: Vec<String> = lines.pop().unwrap();
    let mut results: Vec<i64> = Vec::with_capacity(ops.len());
    for (i, line) in lines.iter().enumerate() {
        for (j, op) in ops.iter().enumerate() {
            let num: i64 = line[j].parse().unwrap();
            if i == 0 { results.push(num); }
            else { compute(&mut results[j], op.chars().next().unwrap(), num); }
        }
    }
    println!("{}", results.iter().sum::<i64>());
}

const BASE: u8 = '0' as u8;

fn print_gold(stdin: io::Stdin) {
    let mut lines: Vec<Vec<char>> = stdin
        .lock()
        .lines()
        .map(|l| l
            .unwrap()
            .chars()
            .collect()
        )
        .collect();
    let ops: Vec<char> = lines.pop().unwrap();
    let mut op = ' ';
    let mut amount: i64 = 0;
    let mut group_amount: i64 = 0;
    for i in 0..lines[0].len() {
        let mut num: i64 = 0;
        for line in &lines {
            if line[i] == ' ' { continue; }
            num = 10 * num + (line[i] as u8 - BASE) as i64;
        }
        if num == 0 {
            continue;
        }
        else if ops[i] == ' ' {
            compute(&mut group_amount, op, num);
        }
        else if ops[i] == '*' || ops[i] == '+' {
            amount += group_amount;
            group_amount = num;
            op = ops[i]
        }
    }
    amount += group_amount;
    println!("{amount}");
}
