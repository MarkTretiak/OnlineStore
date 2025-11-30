# OnlineStore Database Project

This repository contains the implementation of my database course project developed using Microsoft SQL Server. The project demonstrates a complete relational database design for a small online retail system, including schema creation, data population, indexing, queries, stored procedures, triggers, and transactional logic.

# Project Overview

The database models a simplified online store environment and includes the following core entities:

'Customers' – customer information

'Categories' – product classification

'Products' – merchandise offered by the store

'Orders' – purchase orders placed by customers

'OrderItems' – junction table representing the many-to-many relationship between Orders and Products

'Payments' – payment records linked to each order

'Logs' – auxiliary table used to demonstrate TRUNCATE operations

The system supports realistic operations such as order processing, payment handling, and stock updates.

Implemented Course Requirements
Database Design

Use of primary keys with IDENTITY auto-increment

Use of foreign keys to enforce referential integrity

Implementation of a many-to-many relationship through the OrderItems table

Use of various SQL data types (INT, VARCHAR, DECIMAL, DATETIME)

Indexes

Unique index on customer emails

Non-unique indexes for product name and order date to improve query performance

Data Manipulation

Multi-row INSERT statements for all tables

UPDATE operations adjusting product price and stock

DELETE operations filtering by conditions

TRUNCATE operation demonstrated using the Logs table

Querying and Data Retrieval

Aggregate queries using COUNT, SUM, AVG

Grouped reporting with GROUP BY

Ordered output using ORDER BY

Pagination implemented using OFFSET … FETCH

Customer spending summary using joins and aggregation

Joins and Views

INNER JOIN and LEFT JOIN examples

Multi-table join combining Customers → Orders → OrderItems → Products

A consolidated reporting view: OrderDetails

Programmability

Scalar function: GetOrderTotal

Trigger: UpdateOrderTotal (automatically recalculates order totals)

Stored procedure: GetOrdersPaged (paged order retrieval)

Transaction example using BEGIN TRY / CATCH, demonstrating safe COMMIT/ROLLBACK handling

How to Run the Project

Open SQL Server Management Studio (SSMS).

Load the file OnlineStore.sql into a new query window.

Execute the entire script (F5).

The script will:

Create the OnlineStore database

Generate all tables, indexes, and constraints

Populate sample data

Create the function, trigger, stored procedure, and view

Run demonstration updates, deletions, and SELECT queries

Repository Contents

OnlineStore.sql – full SQL script with all database objects and sample operations

Presentation.pptx – project presentation for course submission

diagram.png – entity–relationship diagram of the database schema
