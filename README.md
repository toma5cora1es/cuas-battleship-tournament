# 🚢 CUAS Villach — MATLAB Battleship AI Tournament 🏆

![MATLAB](https://img.shields.io/badge/Made%20with-MATLAB-orange?style=for-the-badge&logo=mathworks)
![University](https://img.shields.io/badge/CUAS-Villach-005596?style=for-the-badge)
![Status](https://img.shields.io/badge/Registration-OPEN-success?style=for-the-badge)

Welcome to the official repository for the **CUAS Villach Battleship AI Cup**! 

In this class competition, your goal is to design and program an autonomous MATLAB algorithm capable of placing a naval fleet and hunting down enemy ships on a `10x10` grid faster than your classmates' algorithms.

All matches are pre-calculated by the official tournament engine and broadcast using our **Interactive HTML5 Replay Viewer**.

---

## 🧠 Two Categories: Human vs. AI (Submit up to 2 Bots!)

Every student can submit **up to two algorithms** to compete in the arena:

1. **🛠️ Human Division (`bot_<LastName>_human.m`)**
   * **Rule:** Written **100% by you** without AI code generation. 
   * Show off your own logic, heuristics, checkerboard parity, or state machines!
2. **🤖 AI / Cyborg Division (`bot_<LastName>_ai.m`)**
   * **Rule:** Built with the help of Large Language Models (ChatGPT, Claude, Gemini, Copilot, etc.).
   * Push prompt engineering and advanced math (Probability Density Heatmaps, Monte Carlo simulations) to the absolute limit!

*Note: Both divisions compete together in the main arena so we can see which humans can outsmart the AI bots, plus we will crown a champion for each division!*

---

## 🏟️ Tournament Format

Because Battleship involves randomness in ship placement, a single game isn't enough to determine the best algorithm. The tournament is divided into **two official phases**:

| Phase | Format | Match Structure | Goal |
| :--- | :--- | :--- | :--- |
| **Phase 1: The League** | Full Round-Robin (Everyone vs. Everyone) | **30 Games** per matchup (Home & Away) | Eliminates luck and produces the **Official Class Leaderboard (Rank #1 to #24)** based on *Win Rate (%)* and *Average Turns to Win*. |
| **Phase 2: The "Mundialito"** | Top 8 Knockout Bracket (Quarterfinals, Semifinals, Final) | **Best of 21 Games** (First to 11 wins) | The decisive game of each knockout series is exported to our **HTML Replay Viewer** and watched live on the classroom projector! |

---

## ⚓ Game Rules & Fleet Specification

The game is played on a standard **`10x10` matrix**. Each player controls a fleet of **5 ships** (totaling **17 hit points**):

| Ship ID (Matrix Value) | Ship Name | Length (Cells) |
| :---: | :--- | :---: |
| **`1`** | Carrier | 5 |
| **`2`** | Battleship | 4 |
| **`3`** | Cruiser | 3 |
| **`4`** | Submarine | 3 |
| **`5`** | Destroyer | 2 |

### Placement Rules:
* Ships must be placed strictly **horizontally** or **vertically** (no diagonal ships).
* Ships must stay within the `1..10` rows and `1..10` columns.
* Ships **cannot overlap** each other.
* **Anti-Cheat Fallback:** If your bot returns an invalid board, crashes during setup, or tries to omit ships, the engine will automatically issue a warning and assign you a random valid board for that game.

---

## 💻 How to Code Your Bot (API Specification)

Your entire bot must live inside a **single MATLAB function file** located in the `bots/` directory. 

Your function will be called by the game engine in two modes: `"setup"` (at the start of a game) and `"shoot"` (on every turn).

### Function Signature:
```matlab
function output = bot_LastName_human(mode, board_view)
```

### 1. Mode `"setup"` (Placing Your Fleet)
When `mode == "setup"`, your function must return a `10x10` numeric matrix where:
* `0` = Empty water.
* `1, 2, 3, 4, 5` = The coordinates of each ship according to its **Ship ID**.

> **💡 Pro Tip:** Don't use the exact same static board every game! If an opponent notices you always place your ships in the same corners, they can hardcode shots there. Add randomness to your setup!

### 2. Mode `"shoot"` (Firing at the Enemy)
When `mode == "shoot"`, the engine passes `board_view`—a `10x10` matrix showing everything you currently know about your opponent's board:

| `board_view(r, c)` Value | Meaning |
| :---: | :--- |
| **`0`** | **Unknown / Unshot** (Valid target for your next shot) |
| **`-1`** | **Miss** (Water — you already shot here and missed) |
| **`1`** | **Hit!** (You hit an enemy ship here, and it is **not** sunk yet) |
| **`2`** | **Sunk!** (All cells belonging to a destroyed ship automatically turn from `1` to `2`!) |

Your function must return a `1x2` vector **`[row, col]`** with integers between `1` and `10` indicating where you want to fire next.

---

## 🚀 Quick Start: Test Your Bot Locally!

### Step 1: Clone the Repository
```bash
git clone [https://github.com/toma5cora1es/cuas-battleship-tournament.git](https://github.com/toma5cora1es/cuas-battleship-tournament.git)
cd cuas-battleship-tournament
```

### Step 2: Create Your Bot
1. Go to the `bots/` folder and make a copy of `bot_Template_human.m`.
2. Rename both the **file** and the **function name** inside it to match your last name:
   * `bots/bot_LastName_human.m`
   * `bots/bot_LastName_ai.m` *(optional second bot)*

### Step 3: Run the Sandbox Arena & Watch the Replay
Open MATLAB in the root folder of the project, open `sandbox_test.m`, set `my_bot` to your function handle, and press **Run**:

```matlab
my_bot    = @bot_LastName_human;
enemy_bot = @bot_Hunter_ai;
```

---

## 📤 How to Submit Your Bot

1. **File Naming Convention:**
   * Human Bot: `bots/bot_<LastName>_human.m`
   * AI Bot: `bots/bot_<LastName>_ai.m`
2. **Self-Contained Code:** Your entire logic (including any helper sub-functions) must be inside your `.m` file.
3. **Fair Play Rules:**
   * ❌ No inspecting the caller workspace (`evalin`, `assignin`, `dbstack`).
   * ❌ No clearing variables (`clear all`, `close all`, `clc`).
   * ✅ `persistent` variables are allowed if reset properly when `mode == "setup"` is called.
4. **Submit via Pull Request:**
   * Fork this repo (or create a branch `submission-<LastName>`), add **only** your `.m` file(s) inside `bots/`, and open a **Pull Request**!
