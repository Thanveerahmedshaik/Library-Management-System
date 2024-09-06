SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;


--Project Task

--Task 1. Create a New Book Record 
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn,book_title,category,rental_price,status,author,publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');


--Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101'


--Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121'


SELECT * FROM issued_status
WHERE issued_id = 'IS121'


--Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id='E101';


--Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_emp_id, COUNT(issued_id) AS total_books_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1
ORDER BY  COUNT(issued_id)


--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results 
-- each book and total book_issued_cnt**

CREATE TABLE book_cnts
AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_book_isbn) AS no_issued

FROM books as b
JOIN 
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn

SELECT * FROM book_cnts

--Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic'

--Task 8: Find Total Rental Income by Category:
SELECT 
		b.category, 
		SUM(b.rental_price) AS Rental_Income, 
		COUNT(*) AS Num_of_times_issued
FROM books b
JOIN issued_status ist
ON ist.issued_book_isbn = b.isbn
GROUP BY b.category



--Task 9: List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE members.reg_date >= CURRENT_DATE - 180

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES('C118', 'Sam', '145 Main St', '2024-06-01')


DELETE FROM members WHERE member_id = 'C118'


SELECT * FROM branch;
SELECT * FROM branch


--Task 10 List Employees with Their Branch Manager's Name and their branch details:
SELECT e1.*,
		b.branch_id,
		e2.emp_name AS manager
		FROM employees AS e1
	JOIN branch b 
	ON b.branch_id = e1.branch_id
	JOIN 
	employees AS e2
	ON e2.emp_id = b.manager_id


--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE expensive_books
AS
SELECT * FROM books
WHERE rental_price > 7 ;

--Task 12: Retrieve the List of Books Not Yet Returned


SELECT * 
FROM 
issued_status AS isd
LEFT JOIN 
return_status AS ret
ON isd.issued_id = ret.issued_id
WHERE ret.issued_id IS NULL





































































































































































