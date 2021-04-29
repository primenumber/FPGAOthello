#include <array>
#include <bitset>
#include <iostream>
#include <random>
#include <vector>

constexpr size_t Length = 8;
constexpr size_t Area = Length * Length;

enum class Square {
  Empty = 0,
  Player = 1,
  Opponent = 2,
};

using Line = std::array<Square, Length>;
using Board = std::array<Line, Length>;

std::bitset<Area> flip(const Board& board, size_t pos) {
  std::bitset<Area> result;
  const ptrdiff_t i = pos / Length;
  const ptrdiff_t j = pos % Length;
  if (board.at(i).at(j) != Square::Empty) return result;
  const ptrdiff_t di[] = {0, 1, 1, 1, 0, -1, -1, -1, 0, 1};
  for (size_t k = 0; k < 8; ++k) {
    for (size_t l = 1; l < Length; ++l) {
      const auto ni = i + di[k] * l;
      const auto nj = j + di[k+2] * l;
      if (ni < 0 || ni >= Length || nj < 0 || nj >= Length) break;
      auto sq = board.at(ni).at(nj);
      if (sq == Square::Opponent) continue;
      if (sq == Square::Empty) break;
      for (size_t l2 = 1; l2 < l; ++l2) {
        const auto mi = i + di[k] * l2;
        const auto mj = j + di[k+2] * l2;
        result.set(mi * Length + mj);
      }
      break;
    }
  }
  return result;
}

std::bitset<Length> to_bit(const Line& line, const Square s) {
  std::bitset<Length> result;
  for (size_t i = 0; i < Length; ++i) {
    if (line.at(i) == s) result.set(i);
  }
  return result;
}

std::bitset<Area> to_bit(const Board& board, const Square s) {
  std::bitset<Area> result;
  for (size_t i = 0; i < Length; ++i) {
    result |= to_bit(board.at(i), s).to_ulong() << (i * 8);
  }
  return result;
}

int main() {
  constexpr size_t count = 5000;
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

