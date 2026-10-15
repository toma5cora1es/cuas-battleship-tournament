function output = bot_Template_human(mode, board_view)
% BOT_TEMPLATE_HUMAN Starter template for CUAS Villach Battleship Tournament.
%
% Modes:
%   "setup" -> Return a 10x10 matrix with ships placed:
%              ID 1 (size 5), ID 2 (size 4), ID 3 (size 3), ID 4 (size 3), ID 5 (size 2).
%   "shoot" -> Receive 'board_view' (10x10):
%              0 = Unknown, -1 = Miss, 1 = Hit (unsunk), 2 = Sunk ship.
%              Return [row, col] for your next shot.

if mode == "setup"
    board = zeros(10, 10);
    board(1, 1:5) = 1;   % Carrier (5)
    board(3, 2:5) = 2;   % Battleship (4)
    board(5, 4:6) = 3;   % Cruiser (3)
    board(7, 7:9) = 4;   % Submarine (3)
    board(10, 9:10) = 5; % Destroyer (2)
    output = board;

elseif mode == "shoot"
    [rows, cols] = find(board_view == 0);
    idx = randi(length(rows));
    output = [rows(idx), cols(idx)];
end
end
EOF

# 7. Crear bots/bot_Hunter_ai.m
cat << 'EOF' > bots/bot_Hunter_ai.m
function output = bot_Hunter_ai(mode, board_view)
% BOT_HUNTER_AI Benchmark AI using Checkerboard Parity + Target Adjacency.

if mode == "setup"
    fleet = [5, 4, 3, 3, 2];
    board = zeros(10, 10);
    for id = 1:length(fleet)
        L = fleet(id); placed = false;
        while ~placed
            if randi([0, 1])
                r = randi([1, 10]); c = randi([1, 10 - L + 1]);
                if all(board(r, c:c+L-1) == 0)
                    board(r, c:c+L-1) = id; placed = true;
                end
            else
                r = randi([1, 10 - L + 1]); c = randi([1, 10]);
                if all(board(r:r+L-1, c) == 0)
                    board(r:r+L-1, c) = id; placed = true;
                end
            end
        end
    end
    output = board;

elseif mode == "shoot"
    [hit_r, hit_c] = find(board_view == 1);
    if ~isempty(hit_r)
        dirs = [-1, 0; 1, 0; 0, -1; 0, 1];
        candidates = [];
        for k = 1:length(hit_r)
            for d = 1:4
                nr = hit_r(k) + dirs(d, 1);
                nc = hit_c(k) + dirs(d, 2);
                if nr >= 1 && nr <= 10 && nc >= 1 && nc <= 10 && board_view(nr, nc) == 0
                    candidates = [candidates; nr, nc]; %#ok<AGROW>
                end
            end
        end
        if ~isempty(candidates)
            idx = randi(size(candidates, 1));
            output = candidates(idx, :);
            return;
        end
    end

    [rows, cols] = find(board_view == 0);
    parity_mask = mod(rows + cols, 2) == 0;
    if any(parity_mask)
        p_rows = rows(parity_mask);
        p_cols = cols(parity_mask);
        idx = randi(length(p_rows));
        output = [p_rows(idx), p_cols(idx)];
    else
        idx = randi(length(rows));
        output = [rows(idx), cols(idx)];
    end
end
end