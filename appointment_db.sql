-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 10, 2026 at 10:25 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `appointment_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `app_date` date NOT NULL,
  `app_time` time NOT NULL,
  `description` text DEFAULT NULL,
  `priority` enum('Low','Medium','High') DEFAULT 'Medium',
  `status` enum('Pending','In Progress','Completed') DEFAULT 'Pending',
  `category` varchar(50) DEFAULT 'General'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`id`, `user_id`, `subject`, `app_date`, `app_time`, `description`, `priority`, `status`, `category`) VALUES
(2, 1001, 'network presentation', '2026-03-10', '13:00:00', 'report and slide', 'Medium', 'Pending', 'General'),
(3, 1001, 'Buy groceries', '2026-04-18', '08:15:00', 'Milk, eggs, and bread', 'Medium', 'Pending', 'General'),
(4, 1001, 'Team meeting', '2026-05-15', '18:45:00', 'Discuss project progress', 'Medium', 'Completed', 'Work'),
(5, 1001, 'Dental checkup', '2026-03-19', '12:00:00', 'Regular checkup at clinic', 'Medium', 'Pending', 'Health'),
(6, 1001, 'Car wash', '2026-05-26', '11:30:00', 'Inside and out', 'Medium', 'In Progress', 'Personal'),
(7, 1001, 'Call Mom', '2026-04-11', '18:15:00', 'Catch up on news', 'Medium', 'Pending', 'Personal'),
(8, 1001, 'Submit report', '2026-02-05', '15:45:00', 'Send to manager', 'High', 'Pending', 'Work'),
(9, 1001, 'Lunch with Sarah', '2026-03-20', '20:45:00', 'Italian restaurant', 'Low', 'In Progress', 'Personal'),
(10, 1001, 'Gym session', '2026-05-17', '13:30:00', 'Leg day', 'High', 'In Progress', 'Health'),
(11, 1001, 'Pay electricity bill', '2026-04-17', '16:30:00', 'Due by 15th', 'Low', 'Pending', 'General'),
(12, 1001, 'Finish homework', '2026-04-02', '13:45:00', 'Math chapter 5', 'Medium', 'Pending', 'Study'),
(13, 1001, 'Book flight', '2026-02-25', '15:45:00', 'Trip to Tokyo', 'High', 'In Progress', 'Personal'),
(14, 1001, 'Grocery shopping', '2026-03-07', '11:00:00', 'Weekly supplies', 'Medium', 'Completed', 'General'),
(15, 1001, 'Haircut', '2026-02-05', '08:15:00', 'Short trim', 'Medium', 'Pending', 'Personal'),
(16, 1001, 'Morning run', '2026-04-19', '15:15:00', '30 minutes at park', 'High', 'Completed', 'Health'),
(17, 1001, 'Read a book', '2026-04-06', '17:15:00', 'Finish chapter 3', 'Low', 'Completed', 'Personal'),
(18, 1001, 'Update resume', '2026-04-28', '09:15:00', 'Add new skills', 'Medium', 'Pending', 'Work'),
(19, 1001, 'Clean the house', '2026-05-13', '12:30:00', 'Living room and kitchen', 'High', 'Completed', 'Personal'),
(20, 1001, 'Fix the sink', '2026-01-21', '17:15:00', 'Check for leaks', 'High', 'In Progress', 'Personal'),
(21, 1001, 'Watering plants', '2026-05-10', '14:15:00', 'Garden maintenance', 'High', 'Pending', 'General'),
(22, 1001, 'Buy birthday gift', '2026-03-01', '19:45:00', 'For dad birthday', 'Low', 'Pending', 'Personal'),
(23, 1001, 'Yoga class', '2026-01-19', '12:15:00', 'Evening session', 'Medium', 'Pending', 'Health'),
(24, 1001, 'Visit grandma', '2026-03-16', '08:00:00', 'Bring some cake', 'High', 'Pending', 'Personal'),
(25, 1001, 'Watch a movie', '2026-02-14', '10:15:00', 'Action movie night', 'High', 'Pending', 'Personal'),
(26, 1001, 'Prepare dinner', '2026-05-18', '15:30:00', 'Spaghetti carbonara', 'High', 'Completed', 'Personal'),
(27, 1001, 'Study for exam', '2026-05-10', '13:15:00', 'Prepare for finals', 'Low', 'Completed', 'Study'),
(28, 1001, 'Check emails', '2026-04-16', '15:30:00', 'Reply to urgent ones', 'High', 'Completed', 'Work'),
(29, 1001, 'Walk the dog', '2026-06-24', '20:00:00', '30-minute walk', 'Low', 'In Progress', 'Personal'),
(30, 1001, 'Buy coffee beans', '2026-04-12', '08:15:00', 'Medium roast', 'Medium', 'In Progress', 'General'),
(31, 1001, 'Renew insurance', '2026-03-17', '12:15:00', 'Car and house', 'Low', 'In Progress', 'General'),
(32, 1001, 'Organize desk', '2026-01-28', '08:30:00', 'Tidy up papers', 'Low', 'In Progress', 'Work'),
(33, 1001, 'Plan weekend trip', '2026-01-26', '12:00:00', 'Check hotel prices', 'Medium', 'Completed', 'Personal'),
(34, 1001, 'Meditation', '2026-03-21', '14:00:00', 'Daily mindfulness', 'Low', 'Pending', 'Health'),
(35, 1001, 'Online course', '2026-04-22', '13:15:00', 'Watch module 2', 'Low', 'In Progress', 'Study'),
(36, 1001, 'Meeting with boss', '2026-06-08', '11:30:00', 'Review performance', 'High', 'Pending', 'Work');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `email`, `profile_image`, `created_at`) VALUES
(1001, 'admin', '$2y$10$o501VfsX.aevICyEuenxR.IWC3dqftO6RDWFlCHFu9UnDbJRewsJe', 'admin@gmail.com', NULL, '2026-03-10 11:04:16'),
(1002, 'user1', '$2y$10$5H7ukE08HTjk5dkzptv8QOsM0u8l17H8dXBFfcaVn8SHwFIt0fupO', 'user1@gmail.com', NULL, '2026-03-10 15:54:32');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user_task_link` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1003;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tasks`
--
ALTER TABLE `tasks`
  ADD CONSTRAINT `fk_user_task_link` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
