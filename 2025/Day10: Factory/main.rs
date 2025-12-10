use std::io::{self, BufRead};

const RB: u8 = ']' as u8;
const ON: u8 = '#' as u8;
const LC: u8 = '{' as u8;

fn main() {
    let mut machines: Vec<i32> = Vec::new();
    let mut all_buttons: Vec<Vec<i32>> = Vec::new();
    for line in io::stdin().lock().lines() {
        let mut line = line.unwrap();
        line.remove(0);
        let mut machine = 0;
        let mut pos = 0;
        loop {
            let b = line.as_bytes()[0];
            if b == RB { break; }
            else if b == ON {
                machine |= 1 << pos;
            }
            line.remove(0);
            pos += 1;
        }
        machines.push(machine);

        line.remove(0);
        line.remove(0);
        let mut buttons: Vec<i32> = Vec::new();
        let mut parts = line.split_whitespace();
        loop {
            let mut part = parts.next().unwrap();
            if part.as_bytes()[0] == LC { break; }
            part = &part[1..(part.len()-1)];
            let mut wires = part.split(',');
            let mut button = 0;
            loop {
                let n = wires.next();
                if !n.is_some() { break; }
                let wire: i32 = n.unwrap().parse().unwrap();
                button |= 1 << wire;
            }
            buttons.push(button);
        }
        all_buttons.push(buttons);
    }

    let silver: i32 = (0..machines.len())
        .into_iter()
        .map(|i| solve(&all_buttons[i], 0, machines[i], 0))
        .sum();
    println!("{silver}");
}

fn solve(buttons: &Vec<i32>, i: usize, num: i32, steps: i32) -> i32 {
    if num == 0 { return steps; }
    if i >= buttons.len() { return i32::MAX; }
    let a = solve(buttons, i+1, num, steps);
    let b = solve(buttons, i+1, num^buttons[i], steps+1);
    return a.min(b);
}
