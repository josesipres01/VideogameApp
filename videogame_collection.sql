/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.4.4-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: videogame_collection
-- ------------------------------------------------------
-- Server version	11.4.4-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `game_collection`
--

DROP TABLE IF EXISTS `game_collection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `game_collection` (
  `collection_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `game_id` int(11) NOT NULL,
  `date_added` datetime DEFAULT current_timestamp(),
  `rating` int(11) DEFAULT NULL CHECK (`rating` >= 1 and `rating` <= 10),
  `active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`collection_id`),
  UNIQUE KEY `unique_user_game` (`user_id`,`game_id`),
  KEY `game_id` (`game_id`),
  CONSTRAINT `game_collection_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `game_collection_ibfk_2` FOREIGN KEY (`game_id`) REFERENCES `games` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_game_collection_insert
AFTER INSERT ON game_collection
FOR EACH ROW
BEGIN
    DECLARE sql_instruction TEXT;
    DECLARE logged_user INT DEFAULT NULL;

    SELECT @logged_user_id INTO logged_user;

    SET sql_instruction = CONCAT(
        'INSERT INTO game_collection (collection_id, user_id, game_id, date_added, rating, active) VALUES (',
        COALESCE(NEW.collection_id, 'NULL'), ', ',
        NEW.user_id, ', ',
        NEW.game_id, ', ',
        IFNULL(QUOTE(NEW.date_added), 'NULL'), ', ',
        IFNULL(NEW.rating, 'NULL'), ', ',
        IFNULL(NEW.active, '1'), ')'
    );

    INSERT INTO log (user_id, action_type, table_name, record_id, sql_instruction)
    VALUES (logged_user, 'INSERT', 'game_collection', NEW.collection_id, sql_instruction);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_game_collection_update
AFTER UPDATE ON game_collection
FOR EACH ROW
BEGIN
    DECLARE sql_instruction TEXT;
    DECLARE action_type VARCHAR(50);
    DECLARE logged_user INT DEFAULT NULL;

    SELECT @logged_user_id INTO logged_user;

    SET action_type = 'UPDATE';
    SET sql_instruction = CONCAT('UPDATE game_collection SET ',
                                IF(OLD.user_id <> NEW.user_id, CONCAT('user_id = ', NEW.user_id, ', '), ''),
                                IF(OLD.game_id <> NEW.game_id, CONCAT('game_id = ', NEW.game_id, ', '), ''),
                                IF(OLD.rating <> NEW.rating, CONCAT('rating = ', IFNULL(NEW.rating, 'NULL'), ', '), ''),
                                IF(OLD.active <> NEW.active, CONCAT('active = ', IFNULL(NEW.active, '1'), ', '), ''),
                                'WHERE collection_id = ', OLD.collection_id);
    SET sql_instruction = TRIM(TRAILING ', ' FROM sql_instruction);

    
    IF OLD.active = 1 AND NEW.active = 0 THEN
        SET action_type = 'LOGICAL DELETE';
    END IF;

    INSERT INTO log (user_id, action_type, table_name, record_id, sql_instruction)
    VALUES (logged_user, action_type, 'game_collection', OLD.collection_id, sql_instruction);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_game_collection_delete
AFTER DELETE ON game_collection
FOR EACH ROW
BEGIN
    DECLARE logged_user INT DEFAULT NULL;

    SELECT @logged_user_id INTO logged_user;

    INSERT INTO log (user_id, action_type, table_name, record_id, sql_instruction)
    VALUES (logged_user, 'DELETE', 'game_collection', OLD.collection_id, CONCAT('DELETE FROM game_collection WHERE collection_id = ', OLD.collection_id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `games`
--

DROP TABLE IF EXISTS `games`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `games` (
  `game_id` int(11) NOT NULL AUTO_INCREMENT,
  `date_added` datetime DEFAULT current_timestamp(),
  `game_name` varchar(255) NOT NULL,
  `platform_id` int(11) NOT NULL,
  `year_released` year(4) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`game_id`),
  UNIQUE KEY `unique_game_platform` (`game_name`,`platform_id`),
  KEY `platform_id` (`platform_id`),
  CONSTRAINT `games_ibfk_1` FOREIGN KEY (`platform_id`) REFERENCES `platform` (`platform_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_games_insert
AFTER INSERT ON games
FOR EACH ROW
BEGIN
    DECLARE sql_instruction TEXT;
    DECLARE logged_user INT DEFAULT NULL;

    SELECT @logged_user_id INTO logged_user;

    SET sql_instruction = CONCAT(
        'INSERT INTO games (game_id, date_added, game_name, platform_id, year_released, image_url, active) VALUES (',
        COALESCE(NEW.game_id, 'NULL'), ', ',
        IFNULL(QUOTE(NEW.date_added), 'NULL'), ', ',
        QUOTE(NEW.game_name), ', ',
        NEW.platform_id, ', ',
        IFNULL(QUOTE(NEW.year_released), 'NULL'), ', ',
        IFNULL(QUOTE(NEW.image_url), 'NULL'), ', ',
        NEW.active, ')'
    );

    INSERT INTO log (user_id, action_type, table_name, record_id, sql_instruction)
    VALUES (logged_user, 'INSERT', 'games', NEW.game_id, sql_instruction);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_games_update
AFTER UPDATE ON games
FOR EACH ROW
BEGIN
    DECLARE sql_instruction TEXT;
    DECLARE action_type VARCHAR(50);
    DECLARE logged_user INT DEFAULT NULL;

    SELECT @logged_user_id INTO logged_user;

    SET action_type = 'UPDATE';
    SET sql_instruction = CONCAT('UPDATE games SET ',
                                IF(OLD.game_name <> NEW.game_name, CONCAT('game_name = ', QUOTE(NEW.game_name), ', '), ''),
                                IF(OLD.platform_id <> NEW.platform_id, CONCAT('platform_id = ', NEW.platform_id, ', '), ''),
                                IF(OLD.year_released <> NEW.year_released, CONCAT('year_released = ', IFNULL(QUOTE(NEW.year_released), 'NULL'), ', '), ''),
                                IF(OLD.image_url <> NEW.image_url, CONCAT('image_url = ', IFNULL(QUOTE(NEW.image_url), 'NULL'), ', '), ''),
                                IF(OLD.active <> NEW.active, CONCAT('active = ', NEW.active, ', '), ''),
                                'WHERE game_id = ', OLD.game_id);
    SET sql_instruction = TRIM(TRAILING ', ' FROM sql_instruction);

    
    IF OLD.active = 1 AND NEW.active = 0 THEN
        SET action_type = 'LOGICAL DELETE';
    END IF;

    INSERT INTO log (user_id, action_type, table_name, record_id, sql_instruction)
    VALUES (logged_user, action_type, 'games', OLD.game_id, sql_instruction);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_games_delete
AFTER DELETE ON games
FOR EACH ROW
BEGIN
    DECLARE logged_user INT DEFAULT NULL;

    SELECT @logged_user_id INTO logged_user;

    INSERT INTO log (user_id, action_type, table_name, record_id, sql_instruction)
    VALUES (logged_user, 'DELETE', 'games', OLD.game_id, CONCAT('DELETE FROM games WHERE game_id = ', OLD.game_id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `log`
--

DROP TABLE IF EXISTS `log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` datetime DEFAULT current_timestamp(),
  `user_id` int(11) DEFAULT NULL,
  `action_type` varchar(50) DEFAULT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `record_id` int(11) DEFAULT NULL,
  `sql_instruction` text DEFAULT NULL,
  PRIMARY KEY (`log_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `platform`
--

DROP TABLE IF EXISTS `platform`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `platform` (
  `platform_id` int(11) NOT NULL AUTO_INCREMENT,
  `date_added` datetime DEFAULT current_timestamp(),
  `platform_name` varchar(255) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`platform_id`),
  UNIQUE KEY `platform_name` (`platform_name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_platform_insert
AFTER INSERT ON platform
FOR EACH ROW
BEGIN
    DECLARE sql_instruction TEXT;
    DECLARE logged_user INT DEFAULT NULL;

    SELECT @logged_user_id INTO logged_user;

    SET sql_instruction = CONCAT(
        'INSERT INTO platform (platform_id, date_added, platform_name, active) VALUES (',
        COALESCE(NEW.platform_id, 'NULL'), ', ',
        IFNULL(QUOTE(NEW.date_added), 'NULL'), ', ',
        QUOTE(NEW.platform_name), ', ',
        NEW.active, ')'
    );

    INSERT INTO log (user_id, action_type, table_name, record_id, sql_instruction)
    VALUES (logged_user, 'INSERT', 'platform', NEW.platform_id, sql_instruction);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_platform_update
AFTER UPDATE ON platform
FOR EACH ROW
BEGIN
    DECLARE sql_instruction TEXT;
    DECLARE action_type VARCHAR(50);
    DECLARE logged_user INT DEFAULT NULL;

    SELECT @logged_user_id INTO logged_user;

    SET action_type = 'UPDATE';
    SET sql_instruction = CONCAT('UPDATE platform SET ',
                                IF(OLD.platform_name <> NEW.platform_name, CONCAT('platform_name = ', QUOTE(NEW.platform_name), ', '), ''),
                                IF(OLD.active <> NEW.active, CONCAT('active = ', NEW.active, ', '), ''),
                                'WHERE platform_id = ', OLD.platform_id);
    SET sql_instruction = TRIM(TRAILING ', ' FROM sql_instruction);

    
    IF OLD.active = 1 AND NEW.active = 0 THEN
        SET action_type = 'LOGICAL DELETE';
    END IF;

    INSERT INTO log (user_id, action_type, table_name, record_id, sql_instruction)
    VALUES (logged_user, action_type, 'platform', OLD.platform_id, sql_instruction);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_platform_delete
AFTER DELETE ON platform
FOR EACH ROW
BEGIN
    DECLARE logged_user INT DEFAULT NULL;

    SELECT @logged_user_id INTO logged_user;

    INSERT INTO log (user_id, action_type, table_name, record_id, sql_instruction)
    VALUES (logged_user, 'DELETE', 'platform', OLD.platform_id, CONCAT('DELETE FROM platform WHERE platform_id = ', OLD.platform_id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `date_added` datetime DEFAULT current_timestamp(),
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `preferred_platform_id` int(11) DEFAULT NULL,
  `access_type` enum('user','admin') DEFAULT 'user',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `preferred_platform_id` (`preferred_platform_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`preferred_platform_id`) REFERENCES `platform` (`platform_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_users_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    DECLARE sql_instruction TEXT;
    DECLARE logged_user INT DEFAULT NULL;

    SELECT @logged_user_id INTO logged_user;

    SET sql_instruction = CONCAT(
        'INSERT INTO users (user_id, date_added, username, password, email, preferred_platform_id, access_type, active) VALUES (',
        COALESCE(NEW.user_id, 'NULL'), ', ',
        IFNULL(QUOTE(NEW.date_added), 'NULL'), ', ',
        QUOTE(NEW.username), ', ',
        QUOTE(NEW.password), ', ',
        IFNULL(QUOTE(NEW.email), 'NULL'), ', ',
        COALESCE(NEW.preferred_platform_id, 'NULL'), ', ',
        QUOTE(NEW.access_type), ', ',
        NEW.active, ')'
    );

    INSERT INTO log (user_id, action_type, table_name, record_id, sql_instruction)
    VALUES (logged_user, 'INSERT', 'users', NEW.user_id, sql_instruction);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_users_update
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
    DECLARE sql_instruction TEXT;
    DECLARE action_type VARCHAR(50);
    DECLARE record_id INT;
    DECLARE logged_user INT DEFAULT NULL;

    SELECT @logged_user_id INTO logged_user;

    SET record_id = OLD.user_id;
    SET action_type = 'UPDATE';
    SET sql_instruction = CONCAT('UPDATE users SET ',
                                IF(OLD.username <> NEW.username, CONCAT('username = ', QUOTE(NEW.username), ', '), ''),
                                IF(OLD.password <> NEW.password, CONCAT('password = ', QUOTE(NEW.password), ', '), ''),
                                IF(OLD.email <> NEW.email, CONCAT('email = ', QUOTE(NEW.email), ', '), ''),
                                IF(OLD.preferred_platform_id <> NEW.preferred_platform_id, CONCAT('preferred_platform_id = ', COALESCE(NEW.preferred_platform_id, 'NULL'), ', '), ''),
                                IF(OLD.access_type <> NEW.access_type, CONCAT('access_type = ', QUOTE(NEW.access_type), ', '), ''),
                                IF(OLD.active <> NEW.active, CONCAT('active = ', NEW.active, ', '), ''),
                                'WHERE user_id = ', OLD.user_id);
    SET sql_instruction = TRIM(TRAILING ', ' FROM sql_instruction);

    
    IF OLD.active = 1 AND NEW.active = 0 THEN
        SET action_type = 'LOGICAL DELETE';
    END IF;

    INSERT INTO log (user_id, action_type, table_name, record_id, sql_instruction)
    VALUES (logged_user, action_type, 'users', record_id, sql_instruction);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_users_delete
AFTER DELETE ON users
FOR EACH ROW
BEGIN
    DECLARE logged_user INT DEFAULT NULL;

    SELECT @logged_user_id INTO logged_user;

    INSERT INTO log (user_id, action_type, table_name, record_id, sql_instruction)
    VALUES (logged_user, 'DELETE', 'users', OLD.user_id, CONCAT('DELETE FROM users WHERE user_id = ', OLD.user_id));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2025-05-12  0:20:14
