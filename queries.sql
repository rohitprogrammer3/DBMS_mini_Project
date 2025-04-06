--QUEREY-9:Find the author with the most books in the library.
SELECT Author, COUNT(*) AS TotalBooks
FROM Books
GROUP BY Author
ORDER BY TotalBooks DESC
LIMIT 1;

-- QUEREY-10:Get the top 5 most borrowed books.
SELECT B.BookID, B.Title, T.TimesBorrowed
FROM Books B
JOIN (
    SELECT BookID, COUNT(*) AS TimesBorrowed
    FROM Transactions
    GROUP BY BookID
    ORDER BY TimesBorrowed DESC
    LIMIT 5
) T ON B.BookID = T.BookID;

-- QUEREY-11:Retrieve overdue books and their respective borrowers.
SELECT B.BookID, B.Title, M.MemberID, M.Name
FROM Books B
JOIN Transactions T ON B.BookID = T.BookID
JOIN Members M ON T.MemberID = M.MemberID
WHERE T.ReturnDate IS NULL
  AND T.BorrowDate < CURDATE() - INTERVAL 6 MONTH;

--QUEREY-12:Find members who have borrowed more than 3 books in a month.
SELECT T.MemberID, YEAR(T.BorrowDate) AS YearBorrowed, MONTH(T.BorrowDate) AS MonthBorrowed, COUNT(*) AS TotalBorrows
FROM Transactions T
GROUP BY T.MemberID, YEAR(T.BorrowDate), MONTH(T.BorrowDate)
HAVING COUNT(*) > 3;

-- QUEREY-13:Retrieve books by a specific genre with availability status.
SELECT * FROM Books
WHERE Genre = 'History' AND Availability = 'Available';

--QUEREY-14:Find the longest borrowed book duration. 
WITH DurationStats AS (
    SELECT BookID, DATEDIFF(ReturnDate, BorrowDate) AS DaysHeld
    FROM Transactions
    WHERE ReturnDate IS NOT NULL

    UNION ALL

    SELECT BookID, DATEDIFF(CURDATE(), BorrowDate)
    FROM Transactions
    WHERE ReturnDate IS NULL
),
MaxHold AS (
    SELECT MAX(DaysHeld) AS MaxDays FROM DurationStats
)
SELECT DISTINCT B.BookID, B.Title, B.Author, B.Genre
FROM Books B
JOIN DurationStats DS ON B.BookID = DS.BookID
JOIN MaxHold MH ON DS.DaysHeld = MH.MaxDays;

--QUEREY-15:List books borrowed and returned on the same day.
SELECT *
FROM Books
WHERE BookID IN (
    SELECT BookID
    FROM Transactions
    WHERE DATEDIFF(ReturnDate, BorrowDate) = 0
);

-- QUEREY-16:Retrieve the most recent borrowing transaction.
SELECT *
FROM Transactions
WHERE BorrowDate = (
    SELECT MAX(BorrowDate)
    FROM Transactions
);

