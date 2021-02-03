-- Keep a log of any SQL queries you execute as you solve the mystery.

-- List all events from the day of crime
SELECT description FROM crime_scene_reports
WHERE day = 28 AND month = 7 AND year = 2020;
-- Theft of the CS50 duck took place at 10:15 am at the Chamberlin Street courthouse.
-- Interviews were conducted today with three witnesses who were present at the time
-- — each of their interview transcripts mentions the courthouse.

-- Criminal records mention courthouse => List courthouse sequrity logs from 07/27/2020
SELECT transcript, name FROM interviews
WHERE day = 28 AND month = 7 AND year = 2020;
-- 1 -- Sometime within ten minutes of the theft, I saw the thief get into a car in the courthouse parking
--      lot and drive away. If you have security footage from the courthouse parking lot, you might want
--      to look for cars that left the parking lot in that time frame. | Ruth

-- 2 -- I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived
--      at the courthouse, I was walking by the ATM on Fifer Street and saw the thief there withdrawing some money. | Eugene

-- 3 -- As the thief was leaving the courthouse, they called someone who talked to them for less than a minute.
--      In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow.
--      The thief then asked the person on the other end of the phone to purchase the flight ticket. | Raymond

-- FIRST POSSIBLE VERSION OF EVENTS CHRONOLOGY:
-- 1. Theft talking for less than a minute ->
-- 2. leaving the parking lot with the car (10:15 - 10:25) ->
-- 3. using atm on Fifer Street ->
-- 4. flying on the earliest flight on 29th.

-- List courthouse sequrity logs from 07/27/2020 for cars leaving parking lot after 10:15 - 10:25
SELECT license_plate FROM courthouse_security_logs
WHERE day = 28 AND month = 7 AND year = 2020
AND hour = 10 AND minute >= 15 and minute< 26
AND activity = 'exit';
-- SUSPECTS ->
-- 5P2BI95
-- 94KL13X
-- 6P58WS2
-- 4328GD8
-- G412CB7
-- L93JTIZ
-- 322W7JE
-- 0NTHK55

-- List people who are owners of license plates which left courthouse parking lot between 10:15 and 10:25.
SELECT license_plate, name FROM people WHERE license_plate IN (
'5P2BI95',
'94KL13X',
'6P58WS2',
'4328GD8',
'G412CB7',
'L93JTIZ',
'322W7JE',
'0NTHK55');
--> SUSPECTS:
-- R_PLATES (1)
-- 5P2BI95 => Patrick
-- 94KL13X => Amber
-- 6P58WS2 => Elizabeth
-- 4328GD8 => Roger
-- G412CB7 => Danielle
-- L93JTIZ => Russell
-- 322W7JE => Evelyn
-- 0NTHK55 => Ernest

-- Checking who was talking for less than a minute
-- Callers
SELECT name, phone_number FROM people WHERE phone_number IN
(SELECT caller FROM phone_calls
WHERE duration < 60 AND day = 28 AND month = 7 AND year = 2020);
-- name | phone_number
-- CALLERS :
-- Bobby | (826) 555-1652 x
-- Roger | (130) 555-0289 =>
-- Victoria | (338) 555-6650 x
-- Madison | (286) 555-6063 x
-- Russell | (770) 555-1861 =>
-- Evelyn | (499) 555-9472 =>
-- Ernest | (367) 555-5533 =>
-- Kimberly | (031) 555-6622 x

-- Receivers
SELECT name, phone_number FROM people WHERE phone_number IN
(SELECT receiver FROM phone_calls
WHERE duration < 60 AND day = 28 AND month = 7 AND year = 2020);
-- name | phone_number
-- RECEIVERS:
-- James | (676) 555-6554
-- Larry | (892) 555-8872
-- Anna | (704) 555-2131
-- Jack | (996) 555-8899
-- Melissa | (717) 555-1342
-- Jacqueline | (910) 555-3251
-- Philip | (725) 555-3243
-- Berthold | (375) 555-8161
-- Doris | (066) 555-9701

-- Match callers with receivers
SELECT caller, receiver FROM phone_calls
WHERE caller IN('(130) 555-0289', '(770) 555-1861', '(499) 555-9472', '(367) 555-5533' )
AND duration < 60 AND day = 28 AND month = 7 AND year = 2020;
-- Roger => (130) 555-0289 | (996) 555-8899 => Jack
-- Evelyn => (499) 555-9472 | (892) 555-8872 => Larry
-- Ernest => (367) 555-5533 | (375) 555-8161 => Berthold
-- Evelyn => (499) 555-9472 | (717) 555-1342 => Mellisa
-- Russell => (770) 555-1861 | (725) 555-3243 => Philip


-- Checking people who withdrawed money at repoerted ATM around on Fifer Street
SELECT name FROM people
JOIN bank_accounts ON bank_accounts.person_id = people.id
WHERE account_number IN(
SELECT account_number FROM atm_transactions WHERE day = 28 AND month = 7 AND year = 2020
AND atm_location = 'Fifer Street' AND transaction_type = 'withdraw');
-- PEOPLE WHO WITHDRAW MONEY
-- Ernest(s)
-- Russell(s)
-- Roy
-- Bobby
-- Elizabeth
-- Danielle(s)
-- Madison
-- Victoria

--> SUSPECTS
-- LIC_PL (1) CALL     |||(2) CALL RECEIVERS |||   (3)ATM   |||     (4)FLIGHT
-- 5P2BI95 => Patrick  |x|                   |||            |||
-- 94KL13X => Amber    |x|                   |||            |||
-- 6P58WS2 => Elizabeth|x|                   |||            |||
-- 4328GD8 => Roger(s)    => +Jack           |x|            |||
-- G412CB7 => Danielle |x|                      ?? Danielle |||
-- L93JTIZ => Russell     => +Philip            => Russell  |||
-- 322W7JE => Evelyn(s)   => +Larry +Mellisa |x|            |||
-- 0NTHK55 => Ernest(s)   => +Berthold          => Ernest      => Ernest

-- Checking what was the first flight on the 29th of July
SELECT id, origin_airport_id, destination_airport_id, hour, minute FROM flights
WHERE day = 29 AND month = 7 AND year = 2020 ORDER BY HOUR, minute LIMIT 1;

-- id | origin_airport_id | destination_airport_id | hour | minute
-- 36 |         8         |             4          |   8  |  20

-- Check destination_airport_id name which will be part of the answer
SELECT city FROM airports WHERE id = 4;
-- city
-- London

-- Checking people who booked tickets on the first flight on 29th of July
SELECT name FROM people WHERE passport_number IN
(SELECT passport_number FROM passengers WHERE flight_id = 36);
-- name
-- Bobby x
-- Roger x
-- Madison x
-- Danielle x
-- Evelyn x
-- Edward x
-- Ernest(s)
-- Doris x


-- FINAL VERSION OF EVENTS                                                      ________
--> SUSPECTS                                                                   | ANSWER |
-- LIC_PL (1) CALL     ||| (2) Helpers       ||| (3)ATM     ||| (4)FLIGHT ===> |        |
-- 5P2BI95 => Patrick  |x|                   |||            |||                |        |
-- 94KL13X => Amber    |x|                   |||            |||                |        |
-- 6P58WS2 => Elizabeth|x|                   |||            |||                |        |
-- 4328GD8 => Roger(s)    => +Jack           |x|            |||                | LONDON |
-- G412CB7 => Danielle |x|                      ?? Danielle |x|                |        |
-- L93JTIZ => Russell     => +Philip            => Russell  |x|                | Ernest |
-- 322W7JE => Evelyn(s)   => +Larry +Mellisa |x|                               |   +    |
-- 0NTHK55 => Ernest(s)   => +Berthold          => Ernest      => Ernest ====> |Berthold|
--                                                                             |________|
-- (s) - suspect
-- |x| - point where suspicion didn't get confirmed