# eHotel — Hotel Reservation System

A full-stack hotel reservation web application built with PHP, PostgreSQL, Bootstrap 5, and jQuery.

## Features

- **Room Search** — Filter available rooms by dates, city, chain, star rating, price, capacity, and more
- **Reservations** — Book rooms for existing or new clients
- **Direct Rentals** — Walk-in rental with employee assignment
- **Check-in** — Convert active reservations to rentals (check-in workflow)
- **Client Management** — Add, edit, delete clients
- **Employee Management** — Add, edit, delete employees with hotel assignment
- **Hotel Management** — Add, edit, delete hotels per chain
- **Room Management** — Add, edit, delete rooms with full attributes

## Prerequisites

- **PostgreSQL** 12+
- **PHP** 7.4+ with `pdo_pgsql` extension enabled
- **Web server** (Apache, Nginx) or PHP's built-in server

## Installation

### 1. Clone / Download

```bash
git clone <repo-url>
cd eHotel
```

### 2. Database Setup

Create the database and load the schema + sample data:

```bash
createdb ehotel
psql -U postgres -d ehotel -f database/ehotel.sql
```

> **Note:** The SQL file creates all tables, triggers, views, indexes, and inserts ~40 hotels, 240 rooms, 12 clients, 15 employees, sample reservations and rentals.

### 3. Configure Database Credentials

Edit `app/config.php` to match your PostgreSQL setup:

```php
define('DB_HOST', 'localhost');
define('DB_PORT', '5432');
define('DB_NAME', 'ehotel');
define('DB_USER', 'postgres');
define('DB_PASS', 'postgres');
```

### 4. Run the Application

Using PHP's built-in server (development):

```bash
cd app
php -S localhost:8000
```

### 5. Open in Browser

```
http://localhost:8000
```

## File Structure

```
eHotel/
├── database/
│   └── ehotel.sql          # Full PostgreSQL schema + seed data
├── app/
│   ├── config.php           # Database connection
│   ├── index.php            # Room search page
│   ├── reservation.php      # Create reservation
│   ├── rental.php           # Direct rental (walk-in)
│   ├── checkin.php          # Check-in (convert reservation → rental)
│   ├── clients.php          # Manage clients
│   ├── employees.php        # Manage employees
│   ├── hotels.php           # Manage hotels
│   ├── rooms.php            # Manage rooms
│   └── api/
│       ├── search_rooms.php
│       ├── create_reservation.php
│       ├── create_rental.php
│       ├── convert_reservation.php
│       ├── get_clients.php / save_client.php / delete_client.php
│       ├── get_employees.php / save_employee.php / delete_employee.php
│       ├── get_hotels.php / save_hotel.php / delete_hotel.php
│       ├── get_rooms.php / save_room.php / delete_room.php
│       ├── get_chains.php
│       └── get_reservations.php
└── README.md
```

## Database Schema

| Table | Description |
|-------|-------------|
| `hotel_chain` | Hotel chains (Marriott, Hilton, etc.) |
| `hotel` | Individual hotels with chain, category, location |
| `room` | Rooms with price, capacity, view, amenities |
| `client` | Registered guests |
| `employee` | Hotel staff |
| `reservation` | Room bookings (active / cancelled / converted) |
| `rental` | Active rentals (direct or from reservation) |

### Database Views

- `available_rooms_by_zone` — Available room count per city
- `hotel_total_capacity` — Total rooms and guest capacity per hotel

### Triggers

- Auto-increment `hotel.num_rooms` on room insert/delete
- Auto-set `reservation.status = 'converted'` when a rental is created from a reservation
