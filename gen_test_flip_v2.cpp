#include <array>
#include <bitset>
#include <iostream>
#include <random>
#include <vector>
#include <iostream>
#include <random>
#include "reversi.hpp"

int main() {
  constexpr size_t count = 100000;
  std::random_device rd;
  std::mt19937 mt(rd());
  std::uniform_int_distribution<int> dis(1, 2);
  for (size_t i = 0; i < count; ++i) {
    std::bernoulli_distribution dis_e(i / double(count));
    Board board;
    std::vector<size_t> empties;
    for (size_t j = 0; j < Length; ++j) {
      for (size_t k = 0; k < Length; ++k) {
        if (dis_e(mt)) {
          board[j][k] = static_cast<Square>(dis(mt));
        } else {
          board[j][k] = Square::Empty;
          empties.push_back(j * Length + k);
        }
      }
    }
    if (empties.empty()) {
      --i;
      continue;
    }
    std::uniform_int_distribution<size_t> dis_pos(0, std::size(empties) - 1);
    size_t pos = empties.at(dis_pos(mt));
    auto res = flip(board, pos);
    std::cout << to_bit(board, Square::Player).to_ulong() << " "
      << to_bit(board, Square::Opponent).to_ulong() << " "
      << pos << " "
      << res.to_ulong() << "\n";
  }
  return 0;
}

