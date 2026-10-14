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
