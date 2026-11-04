-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 04, 2026 at 10:59 AM
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
-- Database: `bulk_grocery`
--

-- --------------------------------------------------------

--
-- Table structure for table `order_pools`
--

CREATE TABLE `order_pools` (
  `pool_id` int(11) NOT NULL,
  `status` varchar(50) DEFAULT 'open',
  `closes_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_pools`
--

INSERT INTO `order_pools` (`pool_id`, `status`, `closes_at`) VALUES
(1, 'open', '2026-12-31 23:59:59');

-- --------------------------------------------------------

--
-- Table structure for table `pool_orders`
--

CREATE TABLE `pool_orders` (
  `id` int(11) NOT NULL,
  `pool_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pool_orders`
--

INSERT INTO `pool_orders` (`id`, `pool_id`, `product_id`, `quantity`) VALUES
(1, 1, 1, 1),
(2, 1, 2, 1);

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `unit_size` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `name`, `unit_size`) VALUES
(1, 'Basmati Rice', '1 kg'),
(2, 'Fresh Milk', '1 L');

-- --------------------------------------------------------

--
-- Table structure for table `reverse_bids`
--

CREATE TABLE `reverse_bids` (
  `id` int(11) NOT NULL,
  `pool_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `bid_amount` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reverse_bids`
--

INSERT INTO `reverse_bids` (`id`, `pool_id`, `vendor_id`, `bid_amount`) VALUES
(1, 1, 1, 100.00),
(2, 2, 1, 20000.00);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `order_pools`
--
ALTER TABLE `order_pools`
  ADD PRIMARY KEY (`pool_id`);

--
-- Indexes for table `pool_orders`
--
ALTER TABLE `pool_orders`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`);

--
-- Indexes for table `reverse_bids`
--
ALTER TABLE `reverse_bids`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `order_pools`
--
ALTER TABLE `order_pools`
  MODIFY `pool_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `pool_orders`
--
ALTER TABLE `pool_orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `reverse_bids`
--
ALTER TABLE `reverse_bids`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
