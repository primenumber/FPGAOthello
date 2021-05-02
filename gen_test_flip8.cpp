#include <iostream>
#include <random>
#include "reversi.hpp"

int main() {
  size_t count = 1;
  for (size_t i = 0; i < Length; ++i) count *= 3;
  for (size_t i = 0; i < count; ++i) {
    std::array<Square, Length> line;
    auto tmp = i;
    for (size_t j = 0; j < Length; ++j) {
      line[j] = static_cast<Square>(tmp % 3);
      tmp /= 3;
    }
    for (size_t j = 0; j < Length; ++j) {
      if (line.at(j) == Square::Empty) {
        auto res = flip(line, j);
        std::cout << to_bit(line, Square::Player).to_ulong() << " "
          << to_bit(line, Square::Opponent).to_ulong() << " "
          << j << " "
          << res.to_ulong() << "\n";
      }
    }
  }
  return 0;
}
