use `Hotel Booking Management System`;

CREATE TABLE Hotels(
    hotel_id INT PRIMARY KEY AUTO_INCREMENT,
    hotel_name VARCHAR(50),
    city VARCHAR(30),
    star_rating INT
);

CREATE TABLE Rooms(
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    hotel_id INT,
    room_number VARCHAR(10),
    room_type VARCHAR(20),
    price DECIMAL(10,2),
    status VARCHAR(20),

    FOREIGN KEY(hotel_id)
    REFERENCES Hotels(hotel_id)
);

CREATE TABLE Guests(
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_name VARCHAR(50),
    phone VARCHAR(15),
    city VARCHAR(30)
);

CREATE TABLE Bookings(
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    booking_status VARCHAR(20),

    FOREIGN KEY(guest_id)
    REFERENCES Guests(guest_id),

    FOREIGN KEY(room_id)
    REFERENCES Rooms(room_id)
);

CREATE TABLE Payments(
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    amount DECIMAL(10,2),
    payment_status VARCHAR(20),

    FOREIGN KEY(booking_id)
    REFERENCES Bookings(booking_id)
);

INSERT INTO Hotels(hotel_name,city,star_rating)
VALUES
('Grand Palace','Chennai',5),
('Royal Inn','Bangalore',4),
('Blue Moon','Hyderabad',3);


INSERT INTO Rooms(hotel_id,room_number,room_type,price,status)
VALUES
(1,'101','Standard',2500,'Available'),
(1,'102','Deluxe',4000,'Occupied'),
(1,'103','Suite',7000,'Occupied'),
(2,'201','Standard',2200,'Available'),
(2,'202','Deluxe',3800,'Occupied'),
(3,'301','Standard',1800,'Available'),
(3,'302','Suite',6000,'Occupied');


INSERT INTO Guests(guest_name,phone,city)
VALUES
('Rahul','9876543210','Chennai'),
('Priya','9876543211','Bangalore'),
('Arun','9876543212','Hyderabad'),
('Sneha','9876543213','Coimbatore'),
('Karthik','9876543214','Mumbai');

INSERT INTO Bookings(guest_id,room_id,check_in,check_out,booking_status)
VALUES
(1,2,'2026-09-25','2026-09-30','Completed'),
(2,3,'2026-09-25','2026-09-29','Active'),
(3,5,'2026-09-25','2026-09-30','Active'),
(4,7,'2026-09-20','2026-09-27','Completed'),
(1,1,'2026-09-05','2026-09-28','Booked'),
(5,4,'2026-09-25','2026-09-29','Cancelled');

INSERT INTO Payments(booking_id,amount,payment_status)
VALUES
(1,20000,'Paid'),
(2,35000,'Paid'),
(3,12000,'Pending'),
(4,15000,'Paid'),
(5,7500,'Pending'),
(6,0,'Refunded');





-- 1. Display Available Rooms. Display all rooms that are currently available for booking.

select room_number, room_type, price, hotel_name ,status from Rooms r
join Hotels h on r.hotel_id = h.hotel_id
where status ='Available';

-- 2. Find Guests Staying Today. Display guests who are currently staying in the hotel. Today's date should be between Check-In and Check-Out.

select guest_name, booking_status from Guests g
join Bookings b on g.guest_id = b.guest_id
where CURDATE() between b.check_in and b.check_out and b.booking_status = 'Active';

-- 3. Calculate Total Revenue. Find the total money received from paid bookings.

select sum(amount) as Total_Revenue from  Payments
where payment_status='Paid';

-- 4. Display Bookings Between Two Dates. Example: From 25 sep to 28sep

SELECT booking_id, guest_name, check_in, check_out from Bookings b
join Guests g on b.guest_id=g.guest_id
where check_in between '2026-09-25' AND '2026-09-28';

-- 5. Find the Most Booked Room Type. Find which room category is booked most often.

select room_type, count(*) AS Total_Bookings from Rooms r
join Bookings b on r.room_id=b.room_id
group by room_type
order by Total_Bookings desc
limit 1;

-- 6. Calculate Occupancy Rate. Occupancy Rate tells us what percentage of rooms are occupied.
-- Formula Occupancy Rate = (Occupied Rooms / Total Rooms) × 100

SELECT ROUND((COUNT(CASE WHEN status='Occupied' THEN 1 END) * 100.0 / COUNT(*)), 2) AS Occupancy_Rate
FROM Rooms;

SELECT
    ROUND(
        (SELECT COUNT(*) FROM Rooms WHERE status = 'Occupied')
        * 100.0 / COUNT(*),
        2
    ) AS Occupancy_Rate
FROM Rooms;

-- 7. Display Cancelled Bookings

select booking_id, guest_name, hotel_name, room_number from Bookings b 
join Guests  g on b.guest_id= g.guest_id
join Rooms r on b.room_id= r.room_id
join Hotels h on r.hotel_id= h.hotel_id
where booking_status='Cancelled';

-- 8. Find Customers with Multiple Bookings

select guest_name,COUNT(guest_name) as Total_Bookings from Guests g
join Bookings b on g.guest_id= b.guest_id
group by guest_name
having COUNT(*)>1;

-- 9. Display Average Room Price

select avg(price) as Avg_Room_Price from Rooms;

-- 10. Find Hotels with More Than 100 Rooms(2)
-- The current sample data has only a few rooms. In a real hotel database, this query identifies large hotels.

select hotel_name, count(room_id) as Total_Rooms from Hotels h 
join Rooms r on h.hotel_id= r.hotel_id
group by hotel_name
having count(room_id)>2;

-- 11. Find the highest-paying guest
 
select g.guest_name, sum(p.amount) as Total_Spent from Guests g
join Bookings b on g.guest_id=b.guest_id
join Payments p on b.booking_id=p.booking_id
group by g.guest_name
order by Total_Spent Desc
limit 1;

-- 12. Hotel-wise revenue

select h.hotel_name, sum(p.amount) as Revenue from Hotels h
join Rooms r on h.hotel_id=r.hotel_id
join Bookings b on r.room_id=b.room_id
join Payments p on b.booking_id=p.booking_id
where p.payment_status='Paid'
group by h.hotel_name;

-- 13. Most expensive room
select room_number, room_type, price from Rooms
order by price desc
limit 1;

-- 14. Guests who have never made a booking

select  g.guest_name
from Guests g
left join Bookings b on g.guest_id=b.guest_id
where b.booking_id is null;

-- 15. Rank hotels by revenue

select h.hotel_name, sum(p.amount) as Revenue,
rank() over (order by SUM(p.amount) desc) as Revenue_Rank
from Hotels h
join Rooms r on h.hotel_id=r.hotel_id
join Bookings b on r.room_id=b.room_id
join Payments p on b.booking_id=p.booking_id
where p.payment_status='Paid'
group by h.hotel_name;

