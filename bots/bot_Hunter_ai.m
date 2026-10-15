function output = bot_Hunter_ai(mode, board_view)
% BOT_HUNTER_AI Benchmark AI using Checkerboard Parity + Target Adjacency.

    if strcmp(mode, 'setup')
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

    elseif strcmp(mode, 'shoot')
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
