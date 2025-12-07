use std::io::{self, BufRead};

const START: i64 = ('S' as u8) as i64;
const SPACE: i64 = ('.' as u8) as i64;
const SPLIT: i64 = ('^' as u8) as i64;

fn main() {
    let mut lines: Vec<Vec<i64>> = io::stdin()
        .lock()
        .lines()
        .map(|l| l
            .unwrap()
            .chars()
            .map(|c| (c as u8) as i64)
            .collect()
        )
        .collect();

    let mut silver = 0;
    let mut started = false;
    for i in 0..lines.len()-1 {
        for j in 0..lines[i].len() {
            if !started && lines[i][j] == START {
                lines[i+1][j] = -1;
                started = true;
                continue;
            }
            if started && lines[i][j] == SPACE || lines[i][j] == SPLIT {
                continue;
            }

            if lines[i+1][j] == SPACE {
                lines[i+1][j] = lines[i][j];
            }
            else if lines[i+1][j] == SPLIT {
                let mut prev: i64;
                prev = if lines[i+1][j-1] != SPACE { lines[i+1][j-1] } else { 0 };
                lines[i+1][j-1] = lines[i][j] + prev;

                prev = if j < lines[i].len()-1 && lines[i][j+1] != SPACE { lines[i][j+1] } else { 0 };
                lines[i+1][j+1] = lines[i][j] + prev;
                silver += 1;
            }
        }
    }
    // print(&lines);
    let gold: i64 = lines
        .last()
        .unwrap()
        .iter()
        .map(|x| if *x == SPACE || *x == SPLIT { 0 } else { -*x })
        .sum::<i64>();
    println!("{silver}\n{gold}");
}

fn print(lines: &Vec<Vec<i64>>) {
    for line in lines.iter() {
        for c in line.iter() {
            if *c == SPACE || *c == SPLIT || *c == START { print!(" {}", (*c as u8) as char); } 
            else { print!(" {}", -c); }
        }
        println!("");
    }
    println!("");
}
