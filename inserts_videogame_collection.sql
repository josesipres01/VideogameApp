-- Populate the platform table
INSERT INTO platform (platform_name) VALUES
('PS1'),
('PS2'),
('PS3'),
('PS4'),
('PS5'),
('Nintendo Switch'),
('Nintendo 3DS'),
('Nintendo DS'),
('GameCube'),
('Nintendo 64'),
('SNES'),
('NES'),
('Xbox'),
('Xbox 360'),
('Xbox One'),
('Xbox Series X'),
('Atari 2600'),
('PC');

-- Populate the users table
INSERT INTO users (username, password, email, preferred_platform_id, access_type) VALUES
('gamer1', 'hashed_password_1', 'gamer1@example.com', (SELECT platform_id FROM platform WHERE platform_name = 'PS5'), 'user'),
('admin_user', 'hashed_password_admin', 'admin@example.com', (SELECT platform_id FROM platform WHERE platform_name = 'PC'), 'admin'),
('retro_fan', 'hashed_password_retro', 'retro@example.com', (SELECT platform_id FROM platform WHERE platform_name = 'SNES'), 'user');

-- Populate the games table
INSERT INTO games (game_name, platform_id, year_released, image_url) VALUES
('The Legend of Zelda: Ocarina of Time', (SELECT platform_id FROM platform WHERE platform_name = 'Nintendo 64'), 1998, 'https://m.media-amazon.com/images/I/61I2uQ3ittL._AC_SX679_.jpg'),
('Grand Theft Auto V', (SELECT platform_id FROM platform WHERE platform_name = 'PS4'), 2013, 'https://m.media-amazon.com/images/I/71zKWd-QmCL.__AC_SX300_SY300_QL70_ML2_.jpg'),
('Grand Theft Auto V', (SELECT platform_id FROM platform WHERE platform_name = 'PC'), 2015, 'https://m.media-amazon.com/images/I/91T0XQv8gEL.__AC_SX300_SY300_QL70_ML2_.jpg'),
('Super Mario World', (SELECT platform_id FROM platform WHERE platform_name = 'SNES'), 1990, 'https://m.media-amazon.com/images/I/71pvhqM3u4L._AC_SX679_.jpg'),
('Elden Ring', (SELECT platform_id FROM platform WHERE platform_name = 'PS5'), 2022, 'https://m.media-amazon.com/images/I/81h2WhI4dtL._AC_SX679_.jpg'),
('Elden Ring', (SELECT platform_id FROM platform WHERE platform_name = 'Xbox Series X'), 2022, 'https://m.media-amazon.com/images/I/718Psopj65L._AC_SX679_.jpg');

-- Populate the game_collection table
INSERT INTO game_collection (user_id, game_id, rating) VALUES
((SELECT user_id FROM users WHERE username = 'gamer1'), (SELECT game_id FROM games WHERE game_name = 'Elden Ring' AND platform_id = (SELECT platform_id FROM platform WHERE platform_name = 'PS5')), 9),
((SELECT user_id FROM users WHERE username = 'gamer1'), (SELECT game_id FROM games WHERE game_name = 'Grand Theft Auto V' AND platform_id = (SELECT platform_id FROM platform WHERE platform_name = 'PS4')), 8),
((SELECT user_id FROM users WHERE username = 'retro_fan'), (SELECT game_id FROM games WHERE game_name = 'Super Mario World' AND platform_id = (SELECT platform_id FROM platform WHERE platform_name = 'SNES')), 10),
((SELECT user_id FROM users WHERE username = 'admin_user'), (SELECT game_id FROM games WHERE game_name = 'Grand Theft Auto V' AND platform_id = (SELECT platform_id FROM platform WHERE platform_name = 'PC')), 7);