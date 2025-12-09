use std::io::{self, BufRead};

#[derive(Debug)]
struct Point(i32,i32);

fn area(points: &Vec<Point>, i: usize, j: usize) -> i64 {
    let p1 = &points[i];
    let p2 = &points[j];
    let x = ((p1.0 - p2.0).abs() + 1) as i64;
    let y = ((p1.1 - p2.1).abs() + 1) as i64;
    return x * y;
}

fn main() {
    let mut points: Vec<Point> = Vec::new();
    for line in io::stdin().lock().lines() {
        let line = line.unwrap();
        let mut parts = line.split(",");
        let p = Point(
            parts.next().unwrap().parse().unwrap(),
            parts.next().unwrap().parse().unwrap(),
        );
        points.push(p);
    }
    points.sort_by_key(|x| (x.0, x.1));

    let mut silver = 0;
    for i in 0..points.len() {
        for j in (i+1)..points.len() {
            silver = silver.max(area(&points, i, j));
        }
    }
    println!("{silver}");
}
