#include "reversi.hpp"
#include <algorithm>
#include <iostream>
#include <random>
#include <string>

int main(int argc, char** argv) {
  if (argc < 2) {
    std::cerr << "Usage: " << argv[0] << " NUM_DATA" << std::endl;
    return EXIT_FAILURE;
  }
  size_t count = std::stoi(argv[1]);
  int empty_max = 7;
  std::random_device rd;
  std::mt19937 mt(rd());
  std::uniform_int_distribution<int> empty_dis(1, empty_max);
  for (size_t i = 0; i < count; ++i) {
    Board board;
    std::bernoulli_distribution dis_sq;
    for (size_t j = 0; j < Length; ++j) {
      for (size_t k = 0; k < Length; ++k) {
        if (dis_sq(mt)) {
          board[j][k] = Square::Player;
        } else {
          board[j][k] = Square::Opponent;
        }
      }
    }
    std::vector<size_t> empties_candi(Area);
    std::iota(std::begin(empties_candi), std::end(empties_candi), 0);
    std::vector<size_t> empties;
    std::sample(std::begin(empties_candi), std::end(empties_candi), std::back_inserter(empties),
        empty_dis(mt), mt);
    for (auto&& pos : empties) {
      board[pos / Length][pos % Length] = Square::Empty;
    }
    if (is_gameover(board)) {
      --i;
      continue;
    }
    auto res = solve(board);
    std::cout << to_bit(board, Square::Player).to_ulong() << " "
      << to_bit(board, Square::Opponent).to_ulong() << " "
      << res << "\n";
  }
  return 0;
}

