# Library Management System using SQL Project 

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_management_project`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/Thanveerahmedshaik/Library-Management-System/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/Thanveerahmedshaik/Library-Management-System/blob/main/ERD.png)

- **Database Creation**: Created a database named `library_management_project`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_management_project;

--Creating Branch Table
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
             (
                 branch_id  VARCHAR(10) PRIMARY KEY,
                 manager_id VARCHAR(10),
                 branch_address VARCHAR(55),
                 contact_no VARCHAR(10)
            );

ALTER TABLE branch
ALTER COLUMN contact_no TYPE VARCHAR(20);

--Creating Branch 'Employee'
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
    (
        emp_id VARCHAR(10) PRIMARY KEY,
        emp_name VARCHAR(25),
        position VARCHAR(15),
        salary INT,
        branch_id VARCHAR(25)      --FK
    );

--Creating Branch 'book'
DROP TABLE IF EXISTS books;
CREATE TABLE books
    (
        isbn VARCHAR(20) PRIMARY KEY,
        book_title VARCHAR (75),
        category VARCHAR(10),
        rental_price FLOAT,
        status VARCHAR(15),
        author VARCHAR(35),
        publisher VARCHAR(55)
    );

ALTER TABLE books
ALTER COLUMN category TYPE VARCHAR(20);


--Creating Branch 'members'
DROP TABLE IF EXISTS members;
CREATE TABLE members
    (
        member_id VARCHAR(20) PRIMARY KEY,
        member_name VARCHAR(25),
        member_address VARCHAR(20),
        reg_date DATE
    );

--Creating Branch 'issued_status'
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
    (
        issued_id VARCHAR(10) PRIMARY KEY,
        issued_member_id VARCHAR(10),  --FK
        issued_book_name VARCHAR(75),
        issued_date DATE,
        issued_book_isbn VARCHAR(25),  --FK
        issued_emp_id VARCHAR(10).     --FK
    );

--Creating Branch 'return_status'
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
    (
        return_id VARCHAR(10) PRIMARY KEY,
        issued_id VARCHAR(10),
        return_book_name VARCHAR(75),
        return_date DATE,
        return_book_isbn VARCHAR(25)
        
    );


-- FOREIGN KEY CONSTRAINTS

ALTER TABLE issued_status
ADD CONSTRAINT Fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);



ALTER TABLE issued_status
ADD CONSTRAINT Fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);


ALTER TABLE issued_status
ADD CONSTRAINT Fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);


ALTER TABLE employees
ADD CONSTRAINT Fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

ALTER TABLE return_status DROP CONSTRAINT fk_issued_status;


```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121' ;
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT issued_emp_id, COUNT(issued_id) AS total_books_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1
ORDER BY  COUNT(issued_id)
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_cnts
AS
SELECT 
    b.isbn,
    b.book_title,
    COUNT(ist.issued_book_isbn) AS issue_count
FROM books as b
JOIN 
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
      b.category, 
      SUM(b.rental_price) AS Rental_Income, 
      COUNT(*) AS Num_of_times_issued
FROM books b
JOIN issued_status ist
ON ist.issued_book_isbn = b.isbn
GROUP BY b.category

```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE members.reg_date >= CURRENT_DATE - 180;
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT e1.*,
        b.branch_id,
        e2.emp_name AS manager
        FROM employees AS e1
    JOIN branch b 
    ON b.branch_id = e1.branch_id
    JOIN 
    employees AS e2
    ON e2.emp_id = b.manager_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE expensive_books
AS
SELECT * FROM books
WHERE rental_price > 7 ;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT * 
FROM 
issued_status AS isd
LEFT JOIN 
return_status AS ret
ON isd.issued_id = ret.issued_id
WHERE ret.issued_id IS NULL
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT ist.issued_member_id,
        m.member_name,
        bk.book_title, 
        ist.issued_date,
        --rs.return_date,
        CURRENT_DATE - ist.issued_date as overdue_days
FROM issued_status as ist
JOIN members as m
    ON m.member_id = ist.issued_member_id     
JOIN books as bk
    ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status as rs
    ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS null AND CURRENT_DATE - ist.issued_date > 30
ORDER BY 1
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$

    DECLARE
    --Declare the variable
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    BEGIN 
    --Logic goes here
    --Inserting into returns based on users input

        INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
        VALUES
        (p_return_id,p_issued_id, CURRENT_DATE, p_book_quality ); -- Values will be entered by the user when the function is called

        --Get the isbn 
        SELECT 
            issued_book_isbn,
            issued_book_name
            INTO 
            v_isbn,
            v_book_name
        FROM issued_status
        WHERE issued_id = p_issued_id;
        
        UPDATE books
        SET status = 'yes'
        WHERE isbn = v_isbn;

        RAISE NOTICE 'Thank you for returning %', v_book_name ;
    
    END

$$





--Testing Functions add_return_records

SELECT * FROM issued_status
WHERE issued_id = 'IS135'

--To check the status of the book 'yes- book is available to rent' , 'no- book is rented out'
SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-307-58837-1';

--check when the book is issued 
SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

--check return status 
SELECT * 
FROM return_status
WHERE issued_id = 'IS135'

DELETE FROM return_status
WHERE return_id = '138'

CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_reports
AS
    SELECT b.branch_id,
           b.manager_id,
           COUNT(ist.issued_id) as number_book_issued,
           COUNT(rs.return_id) as number_of_book_return,
           SUM(bk.rental_price) as total_revenue
    
    FROM issued_status as ist
        JOIN 
        employees as e 
            ON e.emp_id = ist.issued_emp_id
        JOIN
        branch as b
            ON e.branch_id = b.branch_id
        LEFT JOIN 
        return_status as rs
            ON rs.issued_id = ist.issued_id
        JOIN books as bk
            ON ist.issued_book_isbn = bk.isbn
    GROUP BY 1,2;

SELECT * FROM branch_reports;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.

```sql

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (
                      SELECT DISTINCT issued_member_id 
                    FROM issued_status
                    WHERE issued_date >= CURRENT_DATE - INTERVAL '2 months'
                    )
;

SELECT * FROM active_members;


```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
--employees => issued_status  => branch

SELECT e.emp_name, b.branch_id, COUNT(ist.issued_id) as total_books_processed FROM employees as e
JOIN 
issued_status as ist 
ON e.emp_id = ist.issued_emp_id
JOIN branch as b 
ON e.branch_id = b.branch_id
GROUP BY 1,2
ORDER BY total_books_processed DESC
LIMIT 3
```


**Task 18: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.<br />
Description:<br />
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:<br />
The stored procedure should take the book_id as an input parameter.<br />
The procedure should first check if the book is available (status = 'yes').<br />
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.<br />
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE 
---DEclaring the variables 
    v_status VARCHAR(10);

BEGIN 
    -- All the logic goes here 
    -- checking if the book is available 
    SELECT 
        status 
        INTO 
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id,p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
    
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;
        
        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform that the book you have requested is unavailable book_isbn : %', p_issued_book_isbn;

    END IF;
    
END

$$


CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

```



## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/Thanveerahmedshaik/Library-Management-System.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Thanveer Ahmed Shaik

This project showcases SQL skills essential for database management and data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!


- **LinkedIn**: [linkedin.com/in/thanveer-ahmed-shaik/](https://www.linkedin.com/in/thanveer-ahmed-shaik/)
- **Mail**: **shaikthanveerahmed123@gmail.com**


Thank you for your interest in this project!
