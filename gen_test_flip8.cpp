#include <array>
#include <bitset>
#include <iostream>

constexpr size_t Length = 8;

enum class Square {
  Empty = 0,
  Player = 1,
  Opponent = 2,
};

std::bitset<Length> flip(const std::array<Square, Length>& line, size_t pos) {
  std::bitset<Length> result;
  if (line.at(pos) != Square::Empty) return result;
  for (ptrdiff_t i = pos+1; i < Length; ++i) {
    if (line.at(i) == Square::Opponent) continue;
    if (line.at(i) == Square::Empty) break;
    // Player
    for (ptrdiff_t j = pos+1; j < i; ++j) {
      result.set(j);
    }
    break;
  }
  for (ptrdiff_t i = pos-1; i >= 0; --i) {
    if (line.at(i) == Square::Opponent) continue;
    if (line.at(i) == Square::Empty) break;
    // Player
    for (ptrdiff_t j = pos-1; j > i; --j) {
      result.set(j);
    }
    break;
  }
  return result;
}

std::bitset<Length> to_bit(const std::array<Square, Length>& line, const Square s) {
  std::bitset<Length> result;
  for (size_t i = 0; i < Length; ++i) {
    if (line.at(i) == s) result.set(i);
  }
  return result;
}

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
