% RUN_TOURNAMENT Official Master Script for CUAS Villach Battleship Cup.
clear; clc;
addpath('engine', 'bots');
if ~exist('replays', 'dir'), mkdir('replays'); end

bot_files = dir('bots/bot_*.m');
N = length(bot_files);
if N < 2
    error('Need at least 2 bots in the /bots folder to run the tournament!');
end

bots = cell(N, 1);
names = strings(N, 1);
category = strings(N, 1);

for i = 1:N
    [~, fname, ~] = fileparts(bot_files(i).name);
    bots{i} = str2func(fname);
    names(i) = string(fname);
    if endsWith(fname, "_ai", 'IgnoreCase', true)
        category(i) = "AI";
    else
        category(i) = "HUMAN";
    end
end

%% PHASE 1: ROUND-ROBIN LEADERBOARD (Positions 1 to N)
games_per_pair = 30;
wins = zeros(N, 1);
games_played = zeros(N, 1);
total_shots_InWins = zeros(N, 1);

fprintf('======================================================\n');
fprintf('  PHASE 1: CUAS VILLACH LEAGUE (%d BOTS, ROUND-ROBIN) \n', N);
fprintf('======================================================\n');

for i = 1:N
    for j = 1:N
        if i == j, continue; end
        for g = 1:games_per_pair
            res = play_match(bots{i}, bots{j});
            games_played(i) = games_played(i) + 1;
            games_played(j) = games_played(j) + 1;
            if res.winner == 1
                wins(i) = wins(i) + 1;
                total_shots_InWins(i) = total_shots_InWins(i) + res.turns;
            else
                wins(j) = wins(j) + 1;
                total_shots_InWins(j) = total_shots_InWins(j) + res.turns;
            end
        end
    end
end

win_rate = (wins ./ games_played) * 100;
avg_turns = total_shots_InWins ./ max(1, wins);

[~, sort_idx] = sortrows([-win_rate, avg_turns]);

fprintf('\n%-5s | %-25s | %-7s | %-10s | %-10s\n', 'RANK', 'BOT NAME', 'DIV', 'WIN RATE', 'AVG TURNS');
fprintf('----------------------------------------------------------------------\n');
for rank = 1:N
    idx = sort_idx(rank);
    fprintf('#%-4d | %-25s | %-7s | %8.1f%%  | %8.1f\n', ...
            rank, names(idx), category(idx), win_rate(idx), avg_turns(idx));
end

%% PHASE 2: "MUNDIALITO" KNOCKOUT STAGE (Best of 21 per match)
fprintf('\n======================================================\n');
fprintf('  PHASE 2: KNOCKOUT WORLD CUP STAGE (MUNDIALITO)      \n');
fprintf('======================================================\n');

if N >= 8
    bracket_idx = sort_idx([1, 8, 4, 5, 2, 7, 3, 6]);
    round_names = ["Quarterfinals", "Semifinals", "GRAND_FINAL"];
elseif N >= 4
    bracket_idx = sort_idx([1, 4, 2, 3]);
    round_names = ["Semifinals", "GRAND_FINAL"];
else
    bracket_idx = sort_idx([1, 2]);
    round_names = ["GRAND_FINAL"];
end

current_contenders = bracket_idx;
for r = 1:length(round_names)
    r_name = round_names(r);
    fprintf('\n--- %s ---\n', upper(r_name));
    next_contenders = [];
    num_matches = length(current_contenders) / 2;
    
    for m = 1:num_matches
        idxA = current_contenders(2*m - 1);
        idxB = current_contenders(2*m);
        winsA = 0; winsB = 0;
        
        while winsA < 11 && winsB < 11
            res = play_match(bots{idxA}, bots{idxB});
            if res.winner == 1
                winsA = winsA + 1;
                last_win_A = res;
            else
                winsB = winsB + 1;
                last_win_B = res;
            end
        end
        
        if winsA > winsB
            winner_idx = idxA;
            decisive_match = last_win_A;
        else
            winner_idx = idxB;
            decisive_match = last_win_B;
        end
        next_contenders(end+1) = winner_idx; %#ok<AGROW>
        
        fprintf('Match %d: %s (%d) vs %s (%d) --> WINNER: %s\n', ...
                m, names(idxA), winsA, names(idxB), winsB, names(winner_idx));
        
        replay_filename = sprintf('replays/%s_Match%d_%s_vs_%s.html', ...
                                  r_name, m, names(idxA), names(idxB));
        export_replay_html(decisive_match, replay_filename);
    end
    current_contenders = next_contenders;
end

fprintf('\n=== TOURNAMENT CHAMPION: %s ===\n', names(current_contenders(1)));
