use std::io::{self, BufRead};

const BASE: u8 = '0' as u8;

fn main() {
    let stdin = io::stdin();
    let mut silver: i32 = 0;
    let mut gold: i64 = 0;
    for line in stdin.lock().lines() {
        let line = line.unwrap();
        let bytes = line.as_bytes();
        silver += get_silver(bytes);
        gold += get_gold(bytes);
    }
    println!("{silver}\n{gold}");
}

fn get_silver(bytes: &[u8]) -> i32 {
    let mut x: u8 = bytes[0] - BASE;
    let mut y: u8 = bytes[1] - BASE;
    for i in 2..bytes.len() {
        let z = bytes[i] - BASE;
        // there are three alternatives:
        // * yz is the best pair - y > x
        //   e.g., 57 and ? -> 7?
        // * xz is the best pair - y < x and z > y
        //   e.g., 83 and 4 -> 84
        // * xy is the best pair - y < x and z < y
        //   e.g., 83 and 1 -> 83
        if y > x {
            x = y;
            y = z;
        }
        else if z > y {
            y = z;
        }
    }
    return (y as i32) + 10*(x as i32);
}

fn get_gold(bytes: &[u8]) -> i64 {
    let mut arr: [u8; 13] = [0,0,0,0,0,0,0,0,0,0,0,0,0];
    for i in 0..12 {
        arr[i] = bytes[i] - BASE;
    }
    for i in 12..bytes.len() {
        arr[12] = bytes[i] - BASE;
        for j in 0..12 {
            if arr[j+1] > arr[j] {
                for k in j..12 {
                    arr[k] = arr[k+1];
                }
                break;
            }
        }
    }
    return (arr[11] as i64) +
            10*(arr[10] as i64) +
            100*(arr[9] as i64) +
            1000*(arr[8] as i64) +
            10000*(arr[7] as i64) +
            100000*(arr[6] as i64) +
            1000000*(arr[5] as i64) +
            10000000*(arr[4] as i64) +
            100000000*(arr[3] as i64) +
            1000000000*(arr[2] as i64) +
            10000000000*(arr[1] as i64) +
            100000000000*(arr[0] as i64);
}
