--SQL Project - library Management System

SELECT* FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

SELECT * FROM books;


--  Advanced SQL Operations

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's id, member's name, book title, issue date, and days overdue.



--issued_status == members == books == return_status
--Filter books which are returned
--Check if overddue is greater than 30 days( Lets not consider overdue if its lessthan 30)

SELECT ist.issued_member_id,
		m.member_name,
		bk.book_title, 
		ist.issued_date,
		--rs.return_date,
		CURRENT_DATE - ist.issued_date as overdue_days
FROM issued_status as ist
JOIN members as m
	ON m.member_id	= ist.issued_member_id 	
JOIN books as bk
	ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status as rs
	ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS null AND CURRENT_DATE - ist.issued_date > 30
ORDER BY 1


-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "available" 
--when they are returned (based on entries in the return_status table).



SELECT * FROM issued_status -- check if the book with the isbn is issued or not
WHERE issued_book_isbn = '978-0-451-52994-2';


SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';


UPDATE books    -- Update the records so that the status of the books table for the book is changed as issued
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';


SELECT * FROM return_status --Check if the book is returned or not
WHERE issued_id = 'IS130'

/*Lets say, Member has returned the boo k today as soon as the book is returned Update the status column from 
books table */

INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
VALUES
('RS125', 'IS130', CURRENT_DATE, 'Good');
SELECT * FROM return_status --Check if the book is returned or not
WHERE issued_id = 'IS130'

-- Now the book has added to the return table 

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

--Now update the status in the books table as the status off the book hasnt changed yet in the books table

UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-451-52994-2'

-- LETS DO THE SAME USING STORE PROCEDURES
-- As soon as some body enter a record in the return_status table it should update status in the books table


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







--If the member returns the book with book_id - 'IS_135' Update the status column in tthe books table



-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, 
--the number of books returned, and the total revenue generated from book rentals.


SELECT * FROM branch

SELECT * FROM employees

SELECT * FROM books

SELECT * FROM return_status

--Branch Performance report
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
	GROUP BY 1,2








-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing 
--members who have issued at least one book in the last 2 months.


CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (
		  			SELECT DISTINCT issued_member_id 
					FROM issued_status
					WHERE issued_date >= CURRENT_DATE - INTERVAL '2 months'
					)



SELECT * FROM active_members


/* Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/



--employees => issued_status  => branch
SELECT * FROM branch;

SELECT e.emp_name, b.branch_id, COUNT(ist.issued_id) as total_books_processed FROM employees as e
JOIN 
issued_status as ist 
ON e.emp_id = ist.issued_emp_id
JOIN branch as b 
ON e.branch_id = b.branch_id
GROUP BY 1,2
ORDER BY total_books_processed DESC
LIMIT 3

/* Task 19: Stored Procedure
 Objective: Create a stored procedure to manage the status of books in a library system.
   Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.*/

SELECT * FROM books;
SELECT * FROM issued_status

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




