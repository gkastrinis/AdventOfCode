use std::env;
use std::io::{self, BufRead};

#[derive(Debug)]
struct Point(i32,i32,i32);

struct Dist(i64,usize,usize);

fn dist(p1_idx: usize, p1: &Point, p2_idx: usize, p2: &Point) -> Dist {
    let a = (p1.0 - p2.0) as i64;
    let b = (p1.1 - p2.1) as i64;
    let c = (p1.2 - p2.2) as i64;
    return Dist(a*a + b*b + c*c, p1_idx, p2_idx);
}

struct UnionFind {
    representative: Vec<usize>,
    tree_sizes: Vec<usize>,
    max_size: usize,
}

impl UnionFind {
    fn new(amount: usize) -> Self {
        UnionFind {
            representative: (0..amount).collect(),
            tree_sizes: vec![1; amount],
            max_size: 1,
        }
    }

    fn find(&mut self, idx: usize) -> usize {
        let p_idx = self.representative[idx];
        return if p_idx != idx { return self.find(p_idx) } else { idx };
    }

    fn merge(&mut self, a_idx: usize, b_idx: usize) {
        let a_representative = self.find(a_idx);
        let b_representative = self.find(b_idx);
        if a_representative == b_representative { return; }
        let a_sz = self.find_size(a_representative);
        let b_sz = self.find_size(b_representative);
        let sz = a_sz + b_sz;
        self.tree_sizes[a_representative] = sz;
        self.tree_sizes[b_representative] = sz;
        self.max_size = self.max_size.max(sz);
        if a_sz < b_sz {
            self.representative[b_representative] = a_representative;
        }
        else {
            self.representative[a_representative] = b_representative;
        }
    }

    fn find_size(&mut self, idx: usize) -> usize {
        return self.tree_sizes[idx];
    }

    fn all_connected(&self) -> bool {
        return self.max_size == self.representative.len();
    }
}

fn main() {
    let silver_iterations: usize = env::args().collect::<Vec<String>>()[1].parse().unwrap();

    let mut points: Vec<Point> = Vec::new();
    for line in io::stdin().lock().lines() {
        let line = line.unwrap();
        let mut parts = line.split(",");
        let p = Point(
            parts.next().unwrap().parse().unwrap(),
            parts.next().unwrap().parse().unwrap(),
            parts.next().unwrap().parse().unwrap()
        );
        points.push(p);
    }

    let mut all_dists: Vec<Dist> = Vec::new();
    for i in 0..points.len() {
        for j in (i+1)..points.len() {
            all_dists.push(dist(i, &points[i], j, &points[j]));
        }
    }
    all_dists.sort_by_key(|p| p.0);
    let mut uf = UnionFind::new(points.len());

    for i in 0..silver_iterations {
        let d = &all_dists[i];
        uf.merge(d.1, d.2);
    }
    // collection of cluster representative and cluster size
    let mut clusters: Vec<(usize,usize)> = Vec::new();
    for d in &all_dists {
        let a = uf.find(d.1);
        let b = uf.find(d.2);
        let a_sz = uf.find_size(a);
        clusters.push((a, a_sz));
        if a == b {
            assert!(uf.find_size(b) == a_sz);
        }
        else {
            clusters.push((b, uf.find_size(b)));
        }
    }
    // sort by descending cluster size
    clusters.sort_by(|x,y| y.1.cmp(&x.1));
    clusters.dedup();
    println!("{}", clusters[0].1 * clusters[1].1 * clusters[2].1);

    for i in silver_iterations..all_dists.len() {
        let d = &all_dists[i];
        uf.merge(d.1, d.2);
        if uf.all_connected() {
            println!("{}", points[d.1].0 * points[d.2].0);
            break;
        }
    }
}
