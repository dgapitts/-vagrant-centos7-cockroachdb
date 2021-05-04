CREATE TABLE users (id INT PRIMARY KEY,
                    last_name STRING NOT NULL,
                    first_name STRING NOT NULL,
                    country STRING,
                    city STRING);
INSERT INTO users (id, last_name, first_name, country, city)
     VALUES (1, 'Cross', 'William', 'USA', 'Jersey City'),
            (2, 'Seldess', 'Jesse', 'USA', 'New York'),
            (3, 'Hirata', 'Lauren', 'USA', 'New York'),
            (4, 'Cross', 'Zachary', 'USA', 'Seattle'),
            (5, 'Shakespeare', 'William', 'UK', 'Stratford-upon-Avon');

EXPLAIN SELECT * FROM users;

SHOW INDEXES FROM users;
SELECT * FROM users WHERE id = 1;
EXPLAIN SELECT * FROM users WHERE id = 1;

EXPLAIN SELECT * FROM users WHERE last_name = 'Cross' AND first_name = 'William';

CREATE INDEX my_index ON users (last_name, first_name);
SHOW INDEXES FROM users;
EXPLAIN SELECT * FROM users WHERE last_name = 'Cross' AND first_name = 'William';
