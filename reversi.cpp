#include "reversi.hpp"

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

int score(const Board& board) {
  int pcnt = 0, ocnt = 0;
  for (auto&& line : board) {
    for (auto&& sq : line) {
      if (sq == Square::Player) ++pcnt;
      else if (sq == Square::Opponent) ++ocnt;
    }
  }
  if (pcnt > ocnt) {
    return Area - 2 * ocnt;
  } else if (pcnt < ocnt) {
    return -Area + 2 * pcnt;
  } else {
    return 0;
  }
}
Board pass_board(Board board) {
  for (size_t i = 0; i < Length; ++i) {
    for (size_t j = 0; j < Length; ++j) {
      auto& sq = board.at(i).at(j);
      if (sq == Square::Player) {
        sq = Square::Opponent;
      } else if (sq == Square::Opponent) {
        sq = Square::Player;
      }
    }
  }
  return board;
}

int solve(const Board& board, int alpha, int beta, bool prev_passed = false) {
  int result = -static_cast<int>(Area);
  bool pass = true;
  for (size_t i = 0; i < Length; ++i) {
    for (size_t j = 0; j < Length; ++j) {
      if (board.at(i).at(j) == Square::Empty) {
        auto flips = flip(board, i * Length + j);
        if (flips.none()) continue;
        pass = false;
        auto next_board = board;
        for (size_t i2 = 0; i2 < Length; ++i2) {
          for (size_t j2 = 0; j2 < Length; ++j2) {
            auto& sq = next_board.at(i2).at(j2);
            switch (sq) {
              case Square::Empty:
                if (i2 == i && j2 == j) {
                  sq = Square::Opponent;
                }
                break;
              case Square::Player:
                if (!flips[i2 * Length + j2]) {
                  sq = Square::Opponent;
                }
                break;
              case Square::Opponent:
                if (!flips[i2 * Length + j2]) {
                  sq = Square::Player;
                }
                break;
            }
          }
        }
        auto tmp = -solve(next_board, -beta, -alpha);
        result = std::max(result, tmp);
        alpha = std::max(alpha, tmp);
        if (alpha >= beta) {
          return alpha;
        }
      }
    }
  }
  if (pass) {
    if (prev_passed) {
      return score(board);
    } else {
      return -solve(pass_board(board), -beta, -alpha, true);
    }
  }
  return result;
}

int solve(const Board& board) {
  return solve(board, -static_cast<int>(Area), Area);
}

bool is_gameover(const Board& board) {
  for (size_t i = 0; i < Length; ++i) {
    for (size_t j = 0; j < Length; ++j) {
      if (board.at(i).at(j) == Square::Empty) {
        auto flips = flip(board, i * Length + j);
        if (flips.any()) return false;
      }
    }
  }
  auto passed_board = pass_board(board);
  for (size_t i = 0; i < Length; ++i) {
    for (size_t j = 0; j < Length; ++j) {
      if (passed_board.at(i).at(j) == Square::Empty) {
        auto flips = flip(passed_board, i * Length + j);
        if (flips.any()) return false;
      }
    }
  }
  return true;
}
