use std::io::{self, BufRead};

fn main() {
    let stdin = io::stdin();
    let mut pos = 50;
    let mut password1 = 0;
    let mut password2 = 0;
    for line in stdin.lock().lines() {
        let mut line = line.unwrap();
        let dir = line.chars().nth(0).unwrap();
        line.remove(0);
        let mut amount: i32 = line.parse().unwrap();
        if dir == 'L' { amount = -amount }

        password2 += amount.abs() / 100;
        amount %= 100;

        let old_pos = pos;
        pos = (pos + amount) % 100;
        if pos < 0 { pos = 100 + pos; }

        if pos == 0 {
            password1 += 1;
            password2 += 1;
        }
        else if old_pos != 0 && ((amount < 0 && pos > old_pos) || (amount > 0 && pos < old_pos)) {
            password2 += 1;
        }
    }
    println!("{password1}\n{password2}");
}
