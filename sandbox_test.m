% SANDBOX_TEST Local testing arena for CUAS students.
clear; clc;
addpath('engine', 'bots');

my_bot    = @bot_Template_human;
enemy_bot = @bot_Hunter_ai;

num_test_games = 50;
wins = 0;

fprintf('Simulating %d games: %s vs %s...\n', num_test_games, func2str(my_bot), func2str(enemy_bot));

for g = 1:num_test_games
    res = play_match(my_bot, enemy_bot);
    if res.winner == 1
        wins = wins + 1;
    end
end

fprintf('Result: %s won %d/%d games (%.1f%% Win Rate)\n', ...
        func2str(my_bot), wins, num_test_games, (wins/num_test_games)*100);

if ~exist('replays', 'dir'), mkdir('replays'); end
replay_file = fullfile('replays', 'sandbox_replay.html');
export_replay_html(res, replay_file);
web(replay_file, '-browser');
