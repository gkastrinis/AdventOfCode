use std::io::{self, BufRead};

fn main() {
    let stdin = io::stdin();
    // end, start
    let mut ranges: Vec<(i64,i64)> = Vec::new();
    for line in stdin.lock().lines() {
        let line = line.unwrap();
        if line.is_empty() { break; }
        let mut iter = line.split("-");
        let start: i64 = iter.next().unwrap().parse().unwrap();
        let end: i64 = iter.next().unwrap().parse().unwrap();
        insert(&mut ranges, start, end);
    }
    let mut silver = 0;
    for line in stdin.lock().lines() {
        let id: i64 = line.unwrap().parse().unwrap();
        if is_fresh(&mut ranges, id) { silver += 1; }
    }
    let mut gold = 0;
    for (end, start) in ranges {
        gold += end - start + 1;
    }
    println!("{silver}\n{gold}");
}

fn insert(ranges: &mut Vec<(i64,i64)>, start: i64, end: i64) {
    for (i, pair) in ranges.iter_mut().enumerate() {
        let curr_start = pair.1;
        let curr_end = pair.0;
        if curr_start <= end && curr_end >= start {
            let new_start = start.min(curr_start);
            let new_end = end.max(curr_end);
            ranges.remove(i);
            return insert(ranges, new_start, new_end);
        }
    }
    ranges.push((end, start));
}

fn is_fresh(ranges: &mut Vec<(i64,i64)>, id: i64) -> bool {
    for (end, start) in ranges {
        if *start <= id && id <= *end { return true; }
    }
    return false;
}
