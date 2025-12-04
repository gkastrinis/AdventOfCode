use std::io::{self, BufRead};

const EMPTY: u8 = '.' as u8;

fn main() {
    let stdin = io::stdin();
    let mut grid: Vec<Vec<u8>> = Vec::new();
    let mut rows = 0;
    for line in stdin.lock().lines() {
        rows += 1;
        grid.push(line.unwrap().as_bytes().to_vec());
    }
    let silver = get_silver(rows, grid[0].len(), &grid);
    let gold = get_gold(rows, grid[0].len(), grid);
    println!("{silver}\n{gold}");
}

fn get_silver(rows: usize, cols: usize, grid: &Vec<Vec<u8>>) -> i32 {
    let mut amount = 0;
    for i in 0..rows {
        for j in 0..cols {
            if grid[i][j] == EMPTY { continue; }
            if count_free(i, j, rows, cols, &grid) > 4 { amount += 1; }
        }
    }
    return amount;
}

fn get_gold(rows: usize, cols: usize, mut grid: Vec<Vec<u8>>) -> i32 {
    let mut amount = 0;
    loop {
        let mut progress = false;
        for i in 0..rows {
            for j in 0..cols {
                if grid[i][j] == EMPTY { continue; }
                if count_free(i, j, rows, cols, &grid) > 4 { 
                    amount += 1;
                    grid[i][j] = EMPTY;
                    progress = true;
                }
            }
        }
        if !progress { break; }
    }
    return amount;
}

fn count_free(i: usize, j: usize, rows: usize, cols: usize, grid: &Vec<Vec<u8>>) -> i32 {
    let mut free = 0;
    if i == 0      || j == 0      || grid[i-1][j-1] == EMPTY { free += 1; }
    if i == 0                     || grid[i-1][j]   == EMPTY { free += 1; }
    if i == 0      || j == cols-1 || grid[i-1][j+1] == EMPTY { free += 1; }
    if j == cols-1                || grid[i][j+1]   == EMPTY { free += 1; }
    if i == rows-1 || j == cols-1 || grid[i+1][j+1] == EMPTY { free += 1; }
    if i == rows-1                || grid[i+1][j]   == EMPTY { free += 1; }
    if i == rows-1 || j == 0      || grid[i+1][j-1] == EMPTY { free += 1; }
    if j == 0                     || grid[i][j-1]   == EMPTY { free += 1; }
    return free;
}
