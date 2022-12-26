#[macro_export]
macro_rules! scope {
    ($detail:expr, $print_str:expr, $( $arg:expr ),*) => {
        format!("[[ {} ]] {}", $detail, format!($print_str, $( $arg ),*))
    }
}

#[macro_export]
macro_rules! pscope {
    ($detail:expr, $print_str:expr, $( $arg:expr ),*) => {
        println!("{}", scope!($detail, $print_str, $( $arg ),*))
    }
}