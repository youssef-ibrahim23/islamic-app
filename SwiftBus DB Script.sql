-- USERS TABLE
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(10) CHECK (role IN ('TRAVELER', 'DRIVER', 'ADMIN')),
);

-- BUSES TABLE
CREATE TABLE buses (
    bus_id SERIAL PRIMARY KEY,
    model VARCHAR(50) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    assigned_driver INT REFERENCES users(user_id)
);

-- TRIPS TABLE
CREATE TABLE trips (
    trip_id SERIAL PRIMARY KEY,
    origin VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    duration INT NOT NULL CHECK (duration > 0),
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    total_seats INT NOT NULL CHECK (total_seats > 0),
    available_seats INT NOT NULL CHECK (available_seats >= 0),
    status BOOLEAN DEFAULT TRUE,
    bus_id INT REFERENCES buses(bus_id),
    driver_id INT REFERENCES users(user_id)
);

-- BOOKINGS TABLE
CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    trip_id INT REFERENCES trips(trip_id),
    status VARCHAR(20) CHECK (status IN ('APPROVED', 'REJECT', 'PENDING')),
	passengers int REFERENCES USERS(USER_ID),
	total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
	booking_date DATE DEFAULT CURRENT_TIMESTAMP
);

-- TICKETS TABLE
CREATE TABLE tickets (
    ticket_id SERIAL PRIMARY KEY,
    trip_id INT REFERENCES trips(trip_id),
    booking_id INT REFERENCES bookings(booking_id),
    pdf_file_bytea BYTEA
);

-- FEEDBACK TABLE
CREATE TABLE feedbacks (
    feedback_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    trip_id INT REFERENCES trips(trip_id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment VARCHAR(1000)
);


-- USERS
INSERT INTO users (user_name, email, password, role) VALUES
('Roaya' , 'roaya@gmail.com' , 'P@ssw0rd' , 'ADMIN')
('BarmoGa' , 'barmoga@gmail.com' , 'P@ssw0rd' , 'TRAVELER' )
('John Smith', 'john.smith@email.com', 'hashed_pass1', 'TRAVELER'),
('Sarah Johnson', 'sarah.j@email.com', 'hashed_pass2', 'TRAVELER'),
('Michael Brown', 'michael.b@email.com', 'hashed_pass3', 'TRAVELER'),
('Emily Davis', 'emily.d@email.com', 'hashed_pass4', 'TRAVELER'),
('David Wilson', 'david.w@email.com', 'hashed_pass5', 'TRAVELER'),
('Jennifer Miller', 'jennifer.m@email.com', 'hashed_pass6', 'TRAVELER'),
('Robert Taylor', 'robert.t@email.com', 'hashed_pass7', 'TRAVELER'),
('Lisa Anderson', 'lisa.a@email.com', 'hashed_pass8', 'TRAVELER'),
('William Thomas', 'william.t@email.com', 'hashed_pass9', 'TRAVELER'),
('Jessica Jackson', 'jessica.j@email.com', 'hashed_pass10', 'TRAVELER'),
('James White', 'james.w@email.com', 'hashed_pass11', 'TRAVELER'),
('Karen Harris', 'karen.h@email.com', 'hashed_pass12', 'TRAVELER'),
('Daniel Martin', 'daniel.m@email.com', 'hashed_pass13', 'TRAVELER'),
('Nancy Garcia', 'nancy.g@email.com', 'hashed_pass14', 'TRAVELER'),
('Charles Rodriguez', 'charles.r@email.com', 'hashed_pass15', 'TRAVELER'),
('Mark Thompson', 'mark.t@swiftbus.com', 'hashed_pass16', 'DRIVER'),
('Steven Martinez', 'steven.m@swiftbus.com', 'hashed_pass17', 'DRIVER'),
('Paul Robinson', 'paul.r@swiftbus.com', 'hashed_pass18', 'DRIVER'),
('Kevin Clark', 'kevin.c@swiftbus.com', 'hashed_pass19', 'DRIVER'),
('Jason Lewis', 'jason.l@swiftbus.com', 'hashed_pass20', 'DRIVER'),
('Laura Walker', 'laura.w@swiftbus.com', 'hashed_pass21', 'DRIVER'),
('Donna Hall', 'donna.h@swiftbus.com', 'hashed_pass22', 'DRIVER'),
('Ryan Young', 'ryan.y@swiftbus.com', 'hashed_pass23', 'DRIVER'),
('Scott Allen', 'scott.a@swiftbus.com', 'hashed_pass24', 'DRIVER'),
('Brian King', 'brian.k@swiftbus.com', 'hashed_pass25', 'ADMIN');

--Buses
INSERT INTO buses (model, capacity, assigned_driver) VALUES
('Volvo 9700', 50, 16),
('Mercedes Tourismo', 45, 17),
('Scania Irizar i6', 55, 18),
('MAN Lion''s Coach', 48, 19),
('Setra S 515 HD', 52, 20),
('Van Hool TX16 Astron', 49, 21),
('Neoplan Tourliner', 47, 22),
('Iveco Magelys', 51, 23),
('Yutong TC9', 53, 24),
('Higer Touring', 46, 16),
('King Long XMQ6129', 50, 17),
('Zhong Tong LCK6126', 48, 18),
('Ankai HFF6120K09D', 52, 19),
('Golden Dragon XML6127', 49, 20),
('Foton BJ6128', 47, 21),
('Hyundai Universe', 51, 22),
('Daewoo FX212', 53, 23),
('Temsa HD9', 46, 24),
('Solaris Urbino 18', 50, 16),
('VDL Futura FHD2', 48, 17);

--Trips
INSERT INTO trips (origin, destination, date, duration, price, total_seats, available_seats, bus_id, driver_id) VALUES
('New York', 'Boston', '2025-05-10', 4, 29.99, 50, 45, 1, 16),
('Los Angeles', 'San Francisco', '2025-05-11', 6, 39.99, 45, 40, 2, 17),
('Chicago', 'Detroit', '2025-05-12', 5, 34.99, 55, 50, 3, 18),
('Houston', 'Dallas', '2025-05-13', 4, 27.99, 48, 43, 4, 19),
('Phoenix', 'Las Vegas', '2025-05-14', 5, 32.99, 52, 47, 5, 20),
('Philadelphia', 'Washington DC', '2025-05-15', 3, 24.99, 49, 44, 6, 21),
('San Antonio', 'Austin', '2025-05-16', 2, 19.99, 47, 42, 7, 22),
('San Diego', 'Los Angeles', '2025-05-17', 2, 22.99, 51, 46, 8, 23),
('Dallas', 'Houston', '2025-05-18', 4, 27.99, 53, 48, 9, 24),
('San Jose', 'Sacramento', '2025-05-19', 3, 26.99, 46, 41, 10, 16),
('Austin', 'San Antonio', '2025-05-20', 2, 19.99, 50, 45, 11, 17),
('Jacksonville', 'Miami', '2025-05-21', 7, 44.99, 48, 43, 12, 18),
('Fort Worth', 'El Paso', '2025-05-22', 9, 54.99, 52, 47, 13, 19),
('Columbus', 'Cleveland', '2025-05-23', 3, 24.99, 49, 44, 14, 20),
('Charlotte', 'Atlanta', '2025-05-24', 4, 29.99, 47, 42, 15, 21),
('San Francisco', 'Portland', '2025-05-25', 10, 59.99, 51, 46, 16, 22),
('Indianapolis', 'St. Louis', '2025-05-26', 5, 34.99, 53, 48, 17, 23),
('Seattle', 'Vancouver', '2025-05-27', 4, 39.99, 46, 41, 18, 24),
('Denver', 'Salt Lake City', '2025-05-28', 6, 42.99, 50, 45, 19, 16),
('Washington DC', 'New York', '2025-05-29', 4, 29.99, 48, 43, 20, 17),
('Boston', 'New York', '2025-05-30', 4, 29.99, 50, 45, 1, 18),
('San Francisco', 'Los Angeles', '2025-06-01', 6, 39.99, 45, 40, 2, 19),
('Detroit', 'Chicago', '2025-06-02', 5, 34.99, 55, 50, 3, 20),
('Dallas', 'Houston', '2025-06-03', 4, 27.99, 48, 43, 4, 21),
('Las Vegas', 'Phoenix', '2025-06-04', 5, 32.99, 52, 47, 5, 22);

--Bookings
INSERT INTO bookings (user_id, trip_id, status, passengers, total_price) VALUES
(1, 1, 'APPROVED', 2, 59.98),
(2, 2, 'APPROVED', 1, 39.99),
(3, 3, 'PENDING', 3, 104.97),
(4, 4, 'APPROVED', 2, 55.98),
(5, 5, 'APPROVED', 1, 32.99),
(6, 6, 'REJECT', 4, 99.96),
(7, 7, 'APPROVED', 2, 39.98),
(8, 8, 'PENDING', 1, 22.99),
(9, 9, 'APPROVED', 3, 83.97),
(10, 10, 'APPROVED', 2, 53.98),
(11, 11, 'PENDING', 1, 19.99),
(12, 12, 'APPROVED', 4, 179.96),
(13, 13, 'APPROVED', 2, 109.98),
(14, 14, 'REJECT', 1, 24.99),
(15, 15, 'APPROVED', 3, 89.97),
(1, 16, 'PENDING', 2, 119.98),
(2, 17, 'APPROVED', 1, 34.99),
(3, 18, 'APPROVED', 4, 159.96),
(4, 19, 'APPROVED', 2, 85.98),
(5, 20, 'PENDING', 1, 29.99),
(6, 21, 'APPROVED', 3, 89.97),
(7, 22, 'APPROVED', 2, 79.98),
(8, 23, 'REJECT', 1, 34.99),
(9, 24, 'APPROVED', 4, 111.96),
(10, 25, 'PENDING', 2, 65.98);

select * from feedback;

--FeedBacks
INSERT INTO feedbacks (user_id, trip_id, rating, comment) VALUES
(1, 1, 5, 'Excellent service, comfortable seats and punctual departure.'),
(2, 2, 4, 'Good experience overall, but WiFi didn''t work.'),
(3, 3, 3, 'Average trip, the bus was a bit old but got us there safely.'),
(4, 4, 5, 'Fantastic driver and very clean bus. Will travel again!'),
(5, 5, 2, 'Delayed by 45 minutes and no explanation given.'),
(6, 6, 1, 'Terrible experience, bus broke down halfway.'),
(7, 7, 4, 'Comfortable ride with good amenities.'),
(8, 8, 5, 'Perfect trip, couldn''t ask for better service.'),
(9, 9, 3, 'Seats were a bit cramped but otherwise okay.'),
(10, 10, 4, 'Friendly staff and clean facilities.'),
(11, 11, 5, 'Great value for money, would recommend.'),
(12, 12, 2, 'Too many stops, made the trip much longer.'),
(13, 13, 4, 'Good service, just wish there were more legroom.'),
(14, 14, 5, 'Excellent driver who kept us informed throughout.'),
(15, 15, 3, 'Average experience, nothing special.'),
(1, 16, 4, 'Smooth ride with beautiful scenery.'),
(2, 17, 5, 'Best bus service I''ve ever used!'),
(3, 18, 1, 'Bus was dirty and seats were broken.'),
(4, 19, 4, 'Comfortable and on time, good experience.'),
(5, 20, 5, 'Perfect from start to finish.'),
(6, 21, 3, 'Okay for the price but could be better.'),
(7, 22, 4, 'Good value, would use again.'),
(8, 23, 2, 'AC wasn''t working properly, very hot.'),
(9, 24, 5, 'Excellent service, very professional.'),
(10, 25, 4, 'Comfortable ride with friendly staff.');
