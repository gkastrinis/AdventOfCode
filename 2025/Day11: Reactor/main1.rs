use std::io::{self, BufRead};
use std::collections::HashMap;
use std::collections::HashSet;
use std::collections::VecDeque;

fn main() {
    let mut graph: HashMap<String,Vec<String>> = HashMap::new();
    for line in io::stdin().lock().lines() {
        let line = line.unwrap();
        let mut parts = line.split(':');
        let node = parts.next().unwrap();
        let mut outs = parts.next().unwrap().trim().split_whitespace();
        let mut neighbors: Vec<String> = Vec::new();
        loop {
            let out = outs.next();
            if !out.is_some() { break; }
            neighbors.push(out.unwrap().to_string());
        }
        neighbors.sort();
        graph.insert(node.to_string(), neighbors);
    }

    let src = String::from("you");
    let dst = String::from("out");
    let mut visited: HashSet<String> = HashSet::new();
    let mut worklist: VecDeque<String> = VecDeque::new();
    let mut silver = 0;
    worklist.push_back(src);
    while !worklist.is_empty() {
        let curr = worklist.pop_front().unwrap();
        visited.insert(curr.clone());
        let neighbors = graph.get(&curr);
        if !neighbors.is_some() { continue; }
        for n in neighbors.unwrap() {
            if *n == dst { silver += 1; }
            if visited.contains(n) { continue; }
            worklist.push_back(n.clone());
        }
    }
    println!("{silver}");
}
