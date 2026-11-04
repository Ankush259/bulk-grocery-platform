# Bulk Grocery Reverse Auction Platform

A demand aggregation and reverse auction system that groups local grocery orders into bulk pools, allowing wholesale vendors to bid for the fulfillment contract. The lowest bid wins, driving down prices for buyers.

## Tech Stack
* **Frontend Dashboard:** HTML5, CSS, JavaScript (Fetch API)
* **Backend:** PHP 8+ (running locally via built-in server)
* **Database:** MySQL (via XAMPP)
* **Mobile Client (WIP):** Flutter(Dart)

## Project Structure
* `/php_backend/` - Contains the PHP API endpoints (`submit_bid.php`, `get_aggregated_demand.php`) and database connection (`db_connect.php`).
* `/flutter_buyer_app/` - The mobile application where consumers place their grocery orders.
* `vendor_dashboard.html` - The web interface where wholesale vendors view active pools and submit lower bids.
* `bulk_grocery.sql` - The database schema and dummy data export for local setup.

## Installation & Setup

**1. Database Configuration**
1. Install and open **XAMPP Control Panel**.
2. Start the **MySQL** module.
3. Navigate to `http://localhost/phpmyadmin` in your browser.
4. Create a new database named exactly `bulk_grocery`.
5. Select the database, go to the **Import** tab, and upload `bulk_grocery.sql` to generate the required tables (`order_pools`, `pool_orders`, `products`, `reverse_bids`).

**2. Start the Backend Server**
1. Open your terminal in the `php_backend` directory.
2. Start the PHP server on port 8000:
   ```bash
   php -S 127.0.0.1:8000
