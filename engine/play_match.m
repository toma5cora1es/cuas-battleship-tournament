function result = play_match(bot1_func, bot2_func)
% PLAY_MATCH Runs a single 10x10 Battleship game between two bots.
% Returns a struct with winner, turns, and full shot-by-shot history.

    fleet_sizes = [5, 4, 3, 3, 2]; % Standard Battleship fleet (sum = 17)
    max_turns = 100;               % Max possible shots on a 10x10 grid

    % 1. Setup Phase (with anti-cheat validation)
    board1 = get_valid_board(bot1_func, fleet_sizes);
    board2 = get_valid_board(bot2_func, fleet_sizes);

    % Public view matrices (what the shooter sees of the opponent)
    % 0 = Unknown, -1 = Miss, 1 = Hit, 2 = Sunk
    view1 = zeros(10, 10);
    view2 = zeros(10, 10);

    history = struct('turn', {}, 'player', {}, 'row', {}, 'col', {}, ...
                     'outcome', {}, 'sunk_id', {}, 'hp1', {}, 'hp2', {});

    hp1 = sum(fleet_sizes);
    hp2 = sum(fleet_sizes);
    winner = 0;

    % 2. Combat Phase
    for turn = 1:max_turns
        % --- PLAYER 1 TURN ---
        [r1, c1] = get_valid_shot(bot1_func, view1);
        [view1, outcome1, sunk1, hp2] = process_shot(board2, view1, r1, c1, fleet_sizes, hp2);
        
        history(end+1) = struct('turn', turn, 'player', 1, 'row', r1, 'col', c1, ...
                                'outcome', outcome1, 'sunk_id', sunk1, 'hp1', hp1, 'hp2', hp2); %#ok<AGROW>
        if hp2 == 0
            winner = 1;
            break;
        end

        % --- PLAYER 2 TURN ---
        [r2, c2] = get_valid_shot(bot2_func, view2);
        [view2, outcome2, sunk2, hp1] = process_shot(board1, view2, r2, c2, fleet_sizes, hp1);
        
        history(end+1) = struct('turn', turn, 'player', 2, 'row', r2, 'col', c2, ...
                                'outcome', outcome2, 'sunk_id', sunk2, 'hp1', hp1, 'hp2', hp2); %#ok<AGROW>
        if hp1 == 0
            winner = 2;
            break;
        end
    end

    % Tie-breaker if 100 turns reached
    if winner == 0
        if hp2 < hp1, winner = 1; else, winner = 2; end
    end

    result.bot1_name = func2str(bot1_func);
    result.bot2_name = func2str(bot2_func);
    result.winner = winner;
    result.turns = turn;
    result.board1 = board1;
    result.board2 = board2;
    result.history = history;
end

%% --- HELPER FUNCTIONS ---

function board = get_valid_board(bot_func, fleet_sizes)
    try
        board = bot_func("setup", zeros(10,10));
        if ~is_valid_fleet(board, fleet_sizes)
            warning('Bot %s returned an invalid board. Using random fallback.', func2str(bot_func));
            board = generate_random_board(fleet_sizes);
        end
    catch
        warning('Bot %s crashed during setup. Using random fallback.', func2str(bot_func));
        board = generate_random_board(fleet_sizes);
    end
end

function valid = is_valid_fleet(board, fleet_sizes)
    valid = false;
    if ~isequal(size(board), [10, 10]) || ~isnumeric(board), return; end
    for id = 1:length(fleet_sizes)
        L = fleet_sizes(id);
        [r, c] = find(board == id);
        if length(r) ~= L, return; end
        if ~(all(r == r(1)) && (max(c) - min(c) == L - 1)) && ...
           ~(all(c == c(1)) && (max(r) - min(r) == L - 1))
            return;
        end
    end
    if sum(board(:) > 0) ~= sum(fleet_sizes), return; end
    valid = true;
end

function board = generate_random_board(fleet_sizes)
    board = zeros(10, 10);
    for id = 1:length(fleet_sizes)
        L = fleet_sizes(id);
        placed = false;
        while ~placed
            horiz = randi([0, 1]);
            if horiz
                r = randi([1, 10]);
                c = randi([1, 10 - L + 1]);
                if all(board(r, c:c+L-1) == 0)
                    board(r, c:c+L-1) = id;
                    placed = true;
                end
            else
                r = randi([1, 10 - L + 1]);
                c = randi([1, 10]);
                if all(board(r:r+L-1, c) == 0)
                    board(r:r+L-1, c) = id;
                    placed = true;
                end
            end
        end
    end
end

function [r, c] = get_valid_shot(bot_func, view_board)
    try
        shot = bot_func("shoot", view_board);
        r = round(shot(1)); c = round(shot(2));
        if r < 1 || r > 10 || c < 1 || c > 10 || view_board(r, c) ~= 0
            [r, c] = random_unshot_cell(view_board);
        end
    catch
        [r, c] = random_unshot_cell(view_board);
    end
end

function [r, c] = random_unshot_cell(view_board)
    [rows, cols] = find(view_board == 0);
    if isempty(rows)
        r = 1; c = 1;
    else
        idx = randi(length(rows));
        r = rows(idx); c = cols(idx);
    end
end

function [view_board, outcome, sunk_id, enemy_hp] = process_shot(true_board, view_board, r, c, fleet_sizes, enemy_hp)
    sunk_id = 0;
    if view_board(r, c) ~= 0
        outcome = "WASTED";
        return;
    end
    ship_id = true_board(r, c);
    if ship_id == 0
        view_board(r, c) = -1;
        outcome = "MISS";
    else
        view_board(r, c) = 1;
        enemy_hp = enemy_hp - 1;
        outcome = "HIT";
        ship_mask = (true_board == ship_id);
        if sum(view_board(ship_mask) >= 1) == fleet_sizes(ship_id)
            view_board(ship_mask) = 2;
            outcome = "SUNK";
            sunk_id = ship_id;
        end
    end
end