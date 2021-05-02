#pragma once
#include <array>
#include <bitset>

constexpr size_t Length = 8;
constexpr size_t Area = Length * Length;

enum class Square {
  Empty = 0,
  Player = 1,
  Opponent = 2,
};

using Line = std::array<Square, Length>;
using Board = std::array<Line, Length>;

std::bitset<Area> flip(const Board& board, size_t pos);
std::bitset<Length> flip(const std::array<Square, Length>& line, size_t pos);
std::bitset<Length> to_bit(const Line& line, const Square s);
std::bitset<Area> to_bit(const Board& board, const Square s);
int score(const Board& board);
int solve(const Board& board);
bool is_gameover(const Board& board);
