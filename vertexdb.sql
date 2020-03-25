/* 
== VERTEX DATABASE ==
AUTHOR: MORGAN REILLY -- G00303598
*/

/* -- CREATE DATABASE -- */
DROP DATABASE IF EXISTS vertex_db;
create database vertex_db default CHARACTER SET = utf8 default COLLATE = utf8_general_ci;
use vertex_db;

/* -- USER SCHEMA -- */
-- 1:M with Channel
CREATE TABLE user
(
    user_id INTEGER(4) unsigned NOT NULL auto_increment,
    user_name VARCHAR(32) NOT NULL,
    password VARCHAR(255) NOT NULL,
    display_name VARCHAR(32) NOT NULL,

    PRIMARY KEY(user_id),
    UNIQUE KEY (user_name)
) ENGINE = INNODB;

/* -- CHANNEL SCHEMA -- */
-- M:1 Relationship with User
-- 1:M Relationship with Message
CREATE TABLE channel
(
    channel_id INTEGER(4) unsigned NOT NULL auto_increment,
    channel_name VARCHAR(32) NOT NULL,
    user_id INTEGER(4) unsigned NOT NULL,
    channel_capacity INTEGER(4) NOT NULL,
    channel_type ENUM ('TEXT', 'VOICE', 'DM') NOT NULL,
    channel_position INTEGER(4) NOT NULL,

    PRIMARY KEY(channel_id),
    UNIQUE KEY (channel_name, user_id, channel_type), -- avoid duplicate entries
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = INNODB;

/* -- MESSAGE SCHEMA -- */
-- M:1 Relationship with Channel
-- 1:1 Relationship with Attachment
-- drop table if EXISTS message;
CREATE TABLE message
(
    message_id INTEGER(4) unsigned NOT NULL auto_increment,
    channel_id INTEGER(4) unsigned NOT NULL,
    user_id INTEGER(4) unsigned NOT NULL,
    message_content VARCHAR(255) NOT NULL,
    message_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY(message_id),
    FOREIGN KEY(channel_id) REFERENCES channel(channel_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(user_id) REFERENCES channel(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = INNODB;

/* -- ATTACHMENT SCHEMA -- */
-- NO LONGER RELEVANT
-- 1:1 Relationship with Message
drop table if EXISTS attachment;
CREATE TABLE attachment
(
    attachment_id INTEGER(4) unsigned NOT NULL auto_increment,
    file_name VARCHAR(32) NOT NULL,
    message_id INTEGER(4) unsigned NOT NULL,
    file_size INTEGER(64) NOT NULL,
    file_url VARCHAR(255) NOT NULL,

    PRIMARY KEY (attachment_id),
    UNIQUE KEY (message_id),
    FOREIGN KEY(message_id) REFERENCES message(message_id) ON DELETE RESTRICT ON UPDATE RESTRICT -- forbids Updates and Deletes to PK in parent
) ENGINE = INNODB;
#################################################################################################
/* REFERENTIAL INTEGRITY */
-- Some tests on each table to verify it's working

-- USER
-- Inserts
insert into user(user_name, password, display_name)
    values ('mreilly', 'foo1bar2', 'mreilly');
insert into user(user_name, password, display_name)
    values ('cbutler', 'foo1bar2', 'cbutler');
insert into user(user_name, password, display_name)
    values ('dneilan', 'foo1bar2', 'dneilan');
select * from user;

-- Insert User: Deplicate User check --> Should fail
insert into user(user_name, password, display_name)
    values ('mreilly', 'foo1bar2', 'mreilly');
select * from user;

-- Delete User
delete from user where user_id = 1;
select * from user;

-- Re-insert User
insert into user(user_name, password, display_name)
    values ('mreilly', 'foo1bar2', 'mreilly');
select * from user;

-- Update User
update user set user_id = 1 where user_name = 'mreilly';
select * from user;

-- CHANNEL
-- Insertions
insert into channel(channel_name, user_id, channel_capacity, channel_type, channel_position)
    values ('Development', 1, 20, 'TEXT', 1);
insert into channel(channel_name, user_id, channel_capacity, channel_type, channel_position)
    values ('Development', 2, 20, 'TEXT', 1);
insert into channel(channel_name, user_id, channel_capacity, channel_type, channel_position)
    values ('Development', 3, 20, 'TEXT', 1);
select * from user;
select * from channel;

-- Inserts: Check for duplicate user entries in channel
insert into channel(channel_name, user_id, channel_capacity, channel_type, channel_position)
    values ('Development', 1, 20, 'TEXT', 2);
select * from channel;

-- Inserts: Verify new entry works with existing user
insert into channel(channel_name, user_id, channel_capacity, channel_type, channel_position)
    values ('Gaming', 1, 20, 'VOICE', 1);
select * from channel;

-- Inserts: Verify new entry works with existing user, channel, but new type
insert into channel(channel_name, user_id, channel_capacity, channel_type, channel_position)
    values ('Development', 1, 20, 'VOICE', 1);
select * from channel;

-- View tables
select * from user;
select * from channel;

-- Deletes
delete from channel where channel_id = 1;
select * from channel;

-- Re-insert channel
insert into channel(channel_name, user_id, channel_capacity, channel_type, channel_position)
    values ('Development', 1, 20, 'TEXT', 2);
select * from channel;

-- Update newly inserted channel
update channel set channel_id = 1 where channel_id = 7;
select * from channel;

-- Delete User
delete from user where user_id = 1;
select * from user;
select * from channel;

-- Re-insert User
insert into user(user_name, password, display_name)
    values ('mreilly', 'foo1bar2', 'mreilly');
select * from user;
select * from channel;

-- Update User
update user set user_id = 1 where user_name = 'mreilly';
select * from user;
select * from channel;

-- View tables
select * from user;
select * from channel;

-- MESSAGE
-- Inserts
insert into message(channel_id, user_id, message_content) 
    values (3, 3, 'Hello, world');
insert into message(channel_id, user_id, message_content) 
    values (3, 3, 'A second message');
insert into message(channel_id, user_id, message_content) 
    values (3, 3, 'A third message');
select * from message;

-- Deletes
delete from message where message_id = 1;
select * from message;

-- Re-insert message
insert into message(channel_id, user_id, message_content) 
    values (2, 2, 'Hello, world');
select * from message;

-- Updates: Update message --updated timestamp should change
update message set message_content = 'Output to world' where message_id = 4;
select * from message;

-- Deletes: Remove user 2 --> All messages should be gone with no issues
delete from user where user_id = 2;

-- Deletes: Remove channel 2 --> All messages should be gone with no issues
delete from channel where channel_id = 2;

-- View tables
select * from user;
select * from channel;
select * from message;

-- ATTACHMENT
-- View tables
select * from user;
select * from channel;
select * from message;

-- Inserts
insert into attachment(file_name, message_id, file_size, file_url)
    values ('Example_file.jpg', 3, 1064, './home/pictures');
select * from attachment;

-- Insert should fail --> Duplicate entry
insert into attachment(file_name, message_id, file_size, file_url)
    values ('Example_file2.jpg', 3, 1064, './home/pictures');
select * from attachment;

-- Deletes
delete from attachment where attachment_id = 3;
select * from attachment;

-- Updates
update attachment set file_name = 'updatedFile.png' where attachment_id = 3;

-- View tables
select * from user;
select * from channel;
select * from message;
select * from attachment;

#################################################################################################
/* TRANSACTIONS */

-- Table Read Lock
-- Demonstrated with user
START TRANSACTION;
LOCK TABLES user READ;
-- SHOW FULL PROCESSLIST;
    select user_id, user_name from user;
    -- update user set user_id = 100 where user_name = 'mreilly'; -- Will Fail
    commit;
    -- select * from message; -- Will Fail
    show OPEN tables WHERE In_Use>0;
UNLOCK TABLES;

-- Table Write Lock
-- Demonstrated with message
START TRANSACTION;
LOCK TABLES user WRITE;
-- SHOW FULL PROCESSLIST;
    select user_id, user_name from user;
    update user set user_id = 100 where user_name = 'mreilly'; -- Pass
    commit;
    show OPEN tables WHERE In_Use>0;
UNLOCK TABLES;

-- Table Read Write Lock
-- Demonstrated with channel, message
START TRANSACTION;
LOCK TABLES channel Write, user READ;
    select channel_id, channel_name from channel;

    update channel set channel_id = 100 where channel_name = 'Development';

    select * from user;

    commit;
    Show Open Tables IN SD_DB3 Where In_Use>0;
    SHOW OPEN TABLES WHERE `Table` LIKE '%T%' AND `Database` LIKE 'USER' AND In_use > 0;
    SHOW OPEN TABLES WHERE  `Database` LIKE 'VERTEX_DB' AND In_use > 0;
UNLOCK TABLES;


#################################################################################################
-- Outdated tests -- Still work but above are better 
/* Create user */
select * from user;
insert into user(user_name, password, display_name)
    values ('mreilly', 'foo1bar2', 'mreilly');
insert into user(user_name, password, display_name)
    values ('cbutler', 'foo1bar2', 'cbutler');
insert into user(user_name, password, display_name)
    values ('dneilan', 'foo1bar2', 'dneilan');
insert into user(user_name, password, display_name)
    values ('user1', 'foo1bar2', 'exampleUser');
select * from user;

/* Update user */
select * from user;
update user set user_name = 'morganreilly' where user_id = 1;
update user set password = 'aFc334bb4hsg3' where user_id = 1;
update user set display_name = 'annie-hash' where user_id = 1;
select * from user;

/* Delete user */
select * from user;
delete from user where user_id = 4;
select * from user;

/* Read user by id */
select * from user where user_id = 2;

/* Create channel input */
select * from channel;
insert into channel(channel_name, user_id, channel_capacity, channel_type, channel_position)
    values ('Development', 0001, 20, 'TEXT', 1);
insert into channel(channel_name, user_id, channel_capacity, channel_type, channel_position)
    values ('Development', 0002, 20, 'TEXT', 1);
insert into channel(channel_name, user_id, channel_capacity, channel_type, channel_position)
    values ('Development', 3, 20, 'TEXT', 1);

insert into channel(channel_name, user_id, channel_capacity, channel_type, channel_position)
    values ('Gaming', 1, 20, 'VOICE', 1);
insert into channel(channel_name, user_id, channel_capacity, channel_type, channel_position)
    values ('Gaming', 2, 20, 'VOICE', 1);
insert into channel(channel_name, user_id, channel_capacity, channel_type, channel_position)
    values ('Gaming', 3, 20, 'VOICE', 1);
select * from channel;

/* Create message input */
select * from message;
insert into message(channel_id, user_id, message_content) 
    values (3, 1, 'Hello, world');
insert into message(channel_id, user_id, message_content) 
    values (3, 2, 'Hello, world');
insert into message(channel_id, user_id, message_content) 
    values (1, 3, 'Hello, world');
select * from message;


/* Create attachment input 
Note -- This probably may change to allow for file inputs
*/
select * from attachment;
insert into attachment(file_name, message_id, file_size, file_url)
    values ('Example_file.jpg', 3, 1064, './home/pictures');
insert into attachment(file_name, message_id, file_size, file_url)
    values ('Example_file2.jpg', 6, 10641064, './home/pictures');
insert into attachment(file_name, message_id, file_size, file_url)
    values ('Example_file2.jpg', 1, 10641064, './home/pictures');
select * from attachment;

/* Case 1:
Display user name, display name, associated channels and types for all users
*/
select usr.user_name, usr.display_name, chnl.channel_name, chnl.channel_type from user usr inner join channel chnl on usr.user_id = chnl.user_id;  

/* Case 1.1:
Display user name, display name, associated voice channels and types for all users
*/
select usr.user_name, usr.display_name, chnl.channel_name, chnl.channel_type from user usr inner join channel chnl on usr.user_id = chnl.user_id where chnl.channel_type = 'VOICE';  

/* Case 1.2:
Display user name, display name, associated channels for specific user
*/
select usr.user_name, usr.display_name, chnl.channel_name, chnl.channel_type from user usr inner join channel chnl on usr.user_id = chnl.user_id where usr.user_id = 1;  

/* Case 2.1:
Display all messages by all users by display name along with time sent for a all channels
*/
select usr.display_name, chnl.channel_name, chnl.channel_type, msg.message_content, msg.message_timestamp from user usr inner join channel chnl on usr.user_id = chnl.user_id inner join message msg on chnl.user_id = msg.user_id;

/* Case 2.2:
Display all messages for specific user by display name along with time sent for a all channels
*/
select usr.display_name, chnl.channel_name, msg.message_content, msg.message_timestamp from user usr inner join channel chnl on usr.user_id = chnl.user_id inner join message msg on chnl.user_id = msg.user_id where usr.user_id = 1;

/* Case 2.3:
Display all messages for specific user by display name along with time sent for a specific channel
*/
select usr.display_name, chnl.channel_name, msg.message_content, msg.message_timestamp from user usr inner join channel chnl on usr.user_id = chnl.user_id inner join message msg on chnl.user_id = msg.user_id where usr.user_id = 1 and chnl.channel_name = 'Development';

/* Case 3:
Display all files sent by all users in all channels
*/
select usr.user_name, chnl.channel_name, att.file_name from user usr inner join channel chnl on usr.user_id = chnl.user_id inner join message msg on chnl.user_id = msg.user_id inner join attachment att on msg.message_id = att.message_id;

/* Case 3.1:
Display all files sent by specific user in all channels
*/
select usr.user_name, chnl.channel_name, att.file_name from user usr inner join channel chnl on usr.user_id = chnl.user_id inner join message msg on chnl.user_id = msg.user_id inner join attachment att on msg.message_id = att.message_id where usr.user_id = 1;
