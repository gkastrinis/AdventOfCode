use std::io::{self, BufRead};

#[derive(Debug)]
struct Point(i32,i32);

const EMPTY: u8 = 0;
const GREEN: u8 = 4;
const RED: u8 = 5;

fn area(points: &Vec<Point>, i: usize, j: usize) -> i64 {
    let p1 = &points[i];
    let p2 = &points[j];
    let x = ((p1.0 - p2.0).abs() + 1) as i64;
    let y = ((p1.1 - p2.1).abs() + 1) as i64;
    return x * y;
}

fn valid(grid: &mut Vec<Vec<u8>>, min_row: i32, min_col: i32, points: &Vec<Point>, i: usize, j: usize) -> bool {
    let p1 = &points[i];
    let p2 = &points[j];
    if p1.0 == p2.0 || p1.1 == p2.1 { return true; }

    let col_start = (p1.0).min(p2.0);
    let col_end = (p1.0).max(p2.0);
    let row_start = (p1.1).min(p2.1);
    let row_end = (p1.1).max(p2.1);
    for i in row_start..=row_end {
        for j in col_start..=col_end {
            if grid[(i-min_row) as usize][(j-min_col) as usize] != GREEN { return false; }
        }
    }
    return true;
}

fn dec(val: &mut u8) {
    if *val == 0 || *val == GREEN || *val == RED { return; }
    *val -= 1;
}

fn inc(val: &mut u8) {
    if *val == GREEN || *val == RED { return; }
    *val += 1;
}

fn main() {
    let mut points: Vec<Point> = Vec::new();
    let mut min_col = i32::MAX;
    let mut max_col = 0;
    let mut min_row = i32::MAX;
    let mut max_row = 0;
    for line in io::stdin().lock().lines() {
        let line = line.unwrap();
        let mut parts = line.split(",");
        let p = Point(
            parts.next().unwrap().parse().unwrap(),
            parts.next().unwrap().parse().unwrap(),
        );
        min_col = min_col.min(p.0);
        max_col = max_col.max(p.0);
        min_row = min_row.min(p.1);
        max_row = max_row.max(p.1);
        points.push(p);
    }

    let rows = (max_row - min_row + 1) as usize;
    let cols = (max_col - min_col + 1) as usize;
    let mut grid: Vec<Vec<u8>> = vec![vec![EMPTY; cols]; rows];
    let mut prev = points.last().unwrap();
    for i in 0..points.len() {
        let p = &points[i];
        let row = (p.1 - min_row) as usize;
        let col = (p.0 - min_col) as usize;
        grid[row][col] = RED;
        if prev.0 == p.0 {
            // println!("prev {:?} {:?}", prev, p);
            // up
            if prev.1 > p.1 {
                for j in p.1..=prev.1 {
                    let curr_row = (j - min_row) as usize;
                    grid[curr_row][col] = GREEN;

                    for k in min_col..p.0 {
                        // println!("dec1 {} {}", curr_row, k - min_col);
                        dec(&mut grid[curr_row][(k - min_col) as usize]); }
                    for k in (p.0+1)..max_col {
                        // println!("inc1 {} {}", curr_row, k - min_col);
                        inc(&mut grid[curr_row][(k - min_col) as usize]); }
                }
            // down
            } else {
                for j in prev.1..=p.1 {
                    let curr_row = (j - min_row) as usize;
                    grid[curr_row][col] = GREEN;

                    for k in min_col..p.0 {
                        // println!("inc2 {} {}", curr_row, k - min_col);
                        inc(&mut grid[curr_row][(k - min_col) as usize]); }
                    for k in (p.0+1)..max_col {
                        // println!("dec2 {} {}", curr_row, k - min_col);
                        dec(&mut grid[curr_row][(k - min_col) as usize]); }
                }
            }
        } else {
            assert!(prev.1 == p.1);
            // left
            if prev.0 > p.0 {
                for j in p.0..=prev.0 {
                    let curr_col = (j - min_col) as usize;
                    grid[row][curr_col] = GREEN;

                    for k in min_row..p.1 {
                        // println!("inc3 {} {}", k - min_row, curr_col);
                        inc(&mut grid[(k - min_row) as usize][curr_col]); }
                    for k in (p.1+1)..max_row {
                        // println!("dec3 {} {}", k - min_row, curr_col);
                        dec(&mut grid[(k - min_row) as usize][curr_col]); }
                }
            // right
            } else {
                for j in prev.0..=p.0 {
                    let curr_col = (j - min_col) as usize;
                    grid[row][curr_col] = GREEN;

                    for k in min_row..p.1 {
                        // println!("dec4 {} {}", k - min_row, curr_col);
                        dec(&mut grid[(k - min_row) as usize][curr_col]); }
                    for k in (p.1+1)..max_row {
                        // println!("inc4 {} {}", k - min_row, curr_col);
                        inc(&mut grid[(k - min_row) as usize][curr_col]); }
                }
            }
        }
        prev = p;
    }

    points.sort_by_key(|x| (x.0, x.1));

    // for row in &grid {
    //     for col in row {
    //         let c = if *col == EMPTY { '.' }
    //                 else if *col == RED { '#' } 
    //                 else if *col == GREEN { 'X' }
    //                 else if *col == 1 { '1' }
    //                 else if *col == 2 { '2' }
    //                 else if *col == 3 { '3' }
    //                 else { '?' };
    //         print!("{c}");
    //     }
    //     println!("");
    // }
    println!("done generating grid");

    let mut silver = 0;
    let mut gold = 0;
    for i in 0..points.len() {
        for j in (i+1)..points.len() {
            let a = area(&points, i, j);
            silver = silver.max(a);
            let p1 = &points[i];
            let p2 = &points[j];
            // println!("{:?} {:?}", p1, p2);
            if valid(&mut grid, min_row, min_col, &points, i, j) {
                gold = gold.max(a);
                // println!("T");
            }
            else {
            // println!("F");
            }
        }
    }
    println!("{silver}\n{gold}");
}
// 4602673662 high
