/* 
== VERTEX DATABASE ==
VERSION: 2.0
AUTHOR: MORGAN REILLY -- G00303598
*/

/* -- CREATE DATABASE -- */
DROP DATABASE IF EXISTS vertex_db;
create database vertex_db default CHARACTER SET = utf8 default COLLATE = utf8_general_ci;
use vertex_db;

#########################################################################################
/* -- USER SCHEMA -- */
-- ?:? with member
CREATE TABLE user
(
    id INTEGER(4) unsigned NOT NULL auto_increment,
    name VARCHAR(32) NOT NULL,
    password VARCHAR(255) NOT NULL,

    PRIMARY KEY(id),
    UNIQUE KEY (name)
) ENGINE = INNODB;
ALTER TABLE user AUTO_INCREMENT=100;

/* ~ BEGIN CRUD TEST ~ */
-- CRUD: CREATE ussr
INSERT INTO user (name, password) VALUES
    ('Bob', '$2y$12$fRe5UcrDaabLe3thSAu1HOQLBo0Nko6yX0yEHveYfLZuN4dw/TlYG'),    --  Password123%%    
    ('Alice', '$2y$12$oTM2Oia6UBBAy4uZIwCYlexn5eYg2buQIzNWzvq165sR.ulWBdXfi'),  --  Password123££
    ('John', '$2y$12$tW7YFaRVEc0sMQxfu.OKn./CNPwJK.db1k7nsy4eW.4asDRilEX82');   --  Password123()
SELECT * FROM user;
-- CRUD: READ user
SELECT id AS 'ID', name AS 'USER NAME', password AS PASSWORD FROM user WHERE id = 101;
-- CRUD: UPDATE user
UPDATE user SET name = 'Claire' WHERE id = 101;
SELECT * FROM user;
-- CRUD: DELETE user
DELETE FROM user WHERE id = 101;
SELECT * FROM user;
-- CRUD: RESET VALUES
DROP TABLE IF EXISTS user;
/* ~ END CRUD TEST ~ */

#########################################################################################
/* -- CHANNELS SCHEMA - */
-- ?:? with MEMBERS
-- ?:? with MESSAGES
CREATE TABLE channel
(
    id INTEGER(4) unsigned NOT NULL auto_increment,
    name VARCHAR(32) NOT NULL,
    creator_id INTEGER(4) unsigned NOT NULL, --  User ID of channel creator
    type ENUM ('TEXT', 'VOICE') NOT NULL,

    PRIMARY KEY(id),
    UNIQUE KEY (name, creator_id, type), -- avoid duplicate entries
    FOREIGN KEY(creator_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = INNODB;
ALTER TABLE channel AUTO_INCREMENT=200;

/* ~ BEGIN CRUD TEST ~ */
-- CRUD: CREATE channel
INSERT INTO channel (name, creator_id, type) VALUES
    ('Study Chat', 100, 'TEXT'),
    ('Work Group', 102, 'TEXT'),
    ('Gaming Sessions', 100, 'VOICE');
SELECT * FROM channel;
-- CRUD: READ channel
SELECT id AS 'ID', name AS 'CHANNEL NAME', creator_id AS 'CHANNEL CREATOR', type AS 'CHANNEL TYPE' FROM channel ORDER BY id;
-- CRUD: UPDATE channel
UPDATE channel SET name = 'Gaming Group' WHERE id = '202';
SELECT * FROM channel;
-- CRUD: DELETE channel
DELETE FROM channel WHERE id = '202';
SELECT * FROM channel;
-- CRUD: RESET VALUES
DROP TABLE IF EXISTS channel;
/* ~ END CRUD TEST ~ */

#########################################################################################
/* -- MESSAGE SCHEMA -- */
-- ?:? Relationship with Channel
CREATE TABLE message
(
    id INTEGER(4) unsigned NOT NULL auto_increment,
    channel INTEGER(4) unsigned NOT NULL,
    author INTEGER(4) unsigned NOT NULL,
    content VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY(id),
    FOREIGN KEY(channel) REFERENCES channel(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(author) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = INNODB;
ALTER TABLE message AUTO_INCREMENT=300;

/* ~ BEGIN CRUD TEST ~ */
-- CRUD: CREATE message
INSERT INTO message (channel, author, content) VALUES
    (200, 100, 'Hey did our professor release the exam timetable yet?'),
    (201, 102, 'Alice the meeting is re-scheduled to mid-day.'),
    (202, 100, 'Will we play another round?');
SELECT * FROM message;
-- CRUD: READ message
SELECT id AS 'ID', channel AS 'CHANNEL ID', author AS 'AUTHOR ID', content AS 'MESSAGE CONTENT', timestamp AS TIMESTAMP FROM message ORDER BY timestamp DESC;
-- CRUD: UPDATE message -- Not included
-- CRUD: DELETE message
DELETE FROM message WHERE id = '302';
SELECT * FROM message;
-- CRUD: RESET VALUES
DROP TABLE IF EXISTS message;
/* ~ END CRUD TEST ~ */

#########################################################################################
/* -- SESSION SCHEMA -- */
-- ?:? with user
CREATE TABLE session
(
    id VARCHAR(255) NOT NULL, -- UUID
    user INTEGER(4) unsigned NOT NULL,
    expire_after INT(8) NOT NULL, -- Unix epoch time store

    PRIMARY KEY(id),
    FOREIGN KEY(user) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = INNODB;

/* ~ BEGIN CRUD TEST ~ */
-- CRUD: CREATE session
INSERT INTO session (id, user, expire_after) VALUES
    ('e26195ee-72a1-11ea-bc55-0242ac130003', 100, 5),
    ('e261980a-72a1-11ea-bc55-0242ac130003', 101, 10),
    ('e2619904-72a1-11ea-bc55-0242ac130003', 102, 15);
SELECT * FROM session;
-- CRUD: READ sessoion
SELECT id AS 'SESSION ID', user AS 'USER ID', expire_after AS 'EXPIRE AFTER' FROM session;
-- CRUD: UPDATE session -- Not included due to a session only having 2 states
-- CRUD: DELETE session
DELETE FROM session WHERE id = 'e2619904-72a1-11ea-bc55-0242ac130003';
SELECT * FROM session;
-- CRUD: RESET VALUES
DROP TABLE IF EXISTS session;
/* ~ END CRUD TEST ~ */
#########################################################################################

/* -- MEMBER SCHEMA - */
CREATE TABLE member
(
    channel INTEGER(4) unsigned NOT NULL,
    user INTEGER(4) unsigned NOT NULL,

    UNIQUE KEY (channel, user), -- avoid duplicate entries
    FOREIGN KEY(channel) REFERENCES channel(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(user) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = INNODB;

/* ~ BEGIN CRUD TEST ~ */
-- CRUD: CREATE member
INSERT INTO member (channel, user) VALUES
    (200, 100),
    (200, 101),
    (200, 102),
    (201, 101),
    (201, 102),
    (202, 100),
    (202, 102);
SELECT * FROM member;
-- CRUD: READ session
SELECT channel AS 'CHANNEL ID ', user AS 'USER ID' FROM member;
-- CRUD: UPDATE session
UPDATE member SET name = 'Gaming Group' WHERE id = '202';
SELECT * FROM channel;
-- CRUD: DELETE session
DELETE FROM channel WHERE id = '202';
SELECT * FROM channel;
-- CRUD: RESET VALUES
DROP TABLE IF EXISTS member;
/* ~ END CRUD TEST ~ */
#########################################################################################

/* TRANSACTIONS */

-- Table Read Lock
-- Demonstrated with user
START TRANSACTION;
LOCK TABLES user READ;
-- SHOW FULL PROCESSLIST;
    SELECT id, name FROM user;
    -- update user set user_id = 100 where user_name = 'mreilly'; -- Will Fail
    COMMIT;
    -- select * from message; -- Will Fail
    SHOW OPEN TABLES WHERE In_Use>0;
UNLOCK TABLES;

-- Table Write Lock
-- Demonstrated with message
START TRANSACTION;
LOCK TABLES user WRITE;
-- SHOW FULL PROCESSLIST;
    SELECT id, name FROM user;
    UPDATE user SET name = "Mike" where id = 102; -- Pass
    COMMIT;
    SHOW OPEN TABLES WHERE In_Use>0;
UNLOCK TABLES;

-- Table Read Write Lock
-- Demonstrated with channel, message
START TRANSACTION;
LOCK TABLES channel WRITE, user READ;
    SELECT id, name FROM channel;

    UPDATE channel SET name = 'Work Chat' WHERE id = 201;

    SELECT * FROM user;

    COMMIT;
    SHOW Open TABLES IN vertex_db_v2 WHERE In_Use>0;
    SHOW OPEN TABLES WHERE  `database` LIKE 'vertex_db_v2' AND In_use > 0;
UNLOCK TABLES;
#########################################################################################