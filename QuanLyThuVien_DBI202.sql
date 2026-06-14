

-- Tạo và dùng database
CREATE DATABASE Library;
GO
USE Library;
GO

-- ------------------------------------------------------------
-- Bảng 1: CATEGORY (Thể loại sách)
-- ------------------------------------------------------------
CREATE TABLE Category (
    CategoryID   INT           PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL,
    Description  NVARCHAR(255)
);

-- ------------------------------------------------------------
-- Bảng 2: AUTHOR (Tác giả)
-- ------------------------------------------------------------
CREATE TABLE Author (
    AuthorID  INT           PRIMARY KEY IDENTITY(1,1),
    FullName  NVARCHAR(150) NOT NULL,
    Country   NVARCHAR(100),
    BirthYear INT
);

-- ------------------------------------------------------------
-- Bảng 3: BOOKTITLE (Đầu sách)
-- ------------------------------------------------------------
CREATE TABLE BookTitle (
    BookID      INT           PRIMARY KEY IDENTITY(1,1),
    Title       NVARCHAR(200) NOT NULL,
    CategoryID  INT           NOT NULL,
    Publisher   NVARCHAR(150),
    PublishYear INT,
    ISBN        VARCHAR(20)   UNIQUE,
    CONSTRAINT FK_BookTitle_Category FOREIGN KEY (CategoryID)
        REFERENCES Category(CategoryID)
);

-- ------------------------------------------------------------
-- Bảng 4: BOOK_AUTHOR (Quan hệ nhiều-nhiều Sách - Tác giả)
-- ------------------------------------------------------------
CREATE TABLE Book_Author (
    BookID   INT NOT NULL,
    AuthorID INT NOT NULL,
    PRIMARY KEY (BookID, AuthorID),
    CONSTRAINT FK_BA_Book   FOREIGN KEY (BookID)   REFERENCES BookTitle(BookID),
    CONSTRAINT FK_BA_Author FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID)
);

-- ------------------------------------------------------------
-- Bảng 5: BOOKCOPY (Bản sao vật lý của sách)
-- ------------------------------------------------------------
CREATE TABLE BookCopy (
    CopyID    INT          PRIMARY KEY IDENTITY(1,1),
    BookID    INT          NOT NULL,
    Condition NVARCHAR(50) NOT NULL DEFAULT 'Good'
                           CHECK (Condition IN ('Good','Fair','Damaged')),
    IsAvailable BIT        NOT NULL DEFAULT 1,  -- 1 = còn trên kệ
    CONSTRAINT FK_BookCopy_Book FOREIGN KEY (BookID) REFERENCES BookTitle(BookID)
);

-- ------------------------------------------------------------
-- Bảng 6: MEMBER (Độc giả)
-- ------------------------------------------------------------
CREATE TABLE Member (
    MemberID  INT           PRIMARY KEY IDENTITY(1,1),
    FullName  NVARCHAR(150) NOT NULL,
    Email     VARCHAR(150)  UNIQUE,
    Phone     VARCHAR(15),
    Address   NVARCHAR(255),
    DOB       DATE
);

-- ------------------------------------------------------------
-- Bảng 7: LIBRARYCARD (Thẻ thư viện)
-- ------------------------------------------------------------
CREATE TABLE LibraryCard (
    CardID    INT  PRIMARY KEY IDENTITY(1,1),
    MemberID  INT  NOT NULL UNIQUE,          -- Mỗi độc giả chỉ có 1 thẻ
    IssueDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    ExpiryDate DATE NOT NULL,
    IsActive  BIT  NOT NULL DEFAULT 1,
    CONSTRAINT FK_Card_Member FOREIGN KEY (MemberID) REFERENCES Member(MemberID)
);

-- ------------------------------------------------------------
-- Bảng 8: STAFF (Nhân viên thư viện)
-- ------------------------------------------------------------
CREATE TABLE Staff (
    StaffID   INT           PRIMARY KEY IDENTITY(1,1),
    FullName  NVARCHAR(150) NOT NULL,
    Email     VARCHAR(150)  UNIQUE,
    Phone     VARCHAR(15),
    Role      NVARCHAR(50)  NOT NULL DEFAULT 'Librarian'
                            CHECK (Role IN ('Librarian','Manager','Admin'))
);

-- ------------------------------------------------------------
-- Bảng 9: BORROWING (Phiếu mượn sách)
-- ------------------------------------------------------------
CREATE TABLE Borrowing (
    BorrowID     INT  PRIMARY KEY IDENTITY(1,1),
    MemberID     INT  NOT NULL,
    CopyID       INT  NOT NULL,
    StaffID      INT  NOT NULL,              -- nhân viên xử lý
    BorrowDate   DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    DueDate      DATE NOT NULL,              -- hạn trả (BorrowDate + 14)
    ReturnDate   DATE,                       -- NULL = chưa trả
    Status       NVARCHAR(20) NOT NULL DEFAULT 'Borrowing'
                 CHECK (Status IN ('Borrowing','Returned','Overdue')),
    CONSTRAINT FK_Borrow_Member FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    CONSTRAINT FK_Borrow_Copy   FOREIGN KEY (CopyID)   REFERENCES BookCopy(CopyID),
    CONSTRAINT FK_Borrow_Staff  FOREIGN KEY (StaffID)  REFERENCES Staff(StaffID)
);

-- ------------------------------------------------------------
-- Bảng 10: FINE (Phiếu phạt trễ hạn)
-- ------------------------------------------------------------
CREATE TABLE Fine (
    FineID      INT           PRIMARY KEY IDENTITY(1,1),
    BorrowID    INT           NOT NULL UNIQUE,  -- 1 lần mượn => tối đa 1 phiếu phạt
    DaysLate    INT           NOT NULL,
    FinePerDay  DECIMAL(10,2) NOT NULL DEFAULT 2000.00,  -- 2.000 VNĐ/ngày
    TotalAmount DECIMAL(10,2) NOT NULL,
    IsPaid      BIT           NOT NULL DEFAULT 0,
    PaidDate    DATE,
    CONSTRAINT FK_Fine_Borrow FOREIGN KEY (BorrowID) REFERENCES Borrowing(BorrowID)
);

-- ============================================================
--  PHẦN DỮ LIỆU MẪU (Sample Data)
-- ============================================================

-- Category
INSERT INTO Category (CategoryName, Description) VALUES
(N'Văn học',        N'Tiểu thuyết, truyện ngắn, thơ ca'),
(N'Khoa học',       N'Vật lý, hóa học, sinh học'),
(N'Công nghệ',      N'Lập trình, CNTT, kỹ thuật số'),
(N'Lịch sử',        N'Lịch sử Việt Nam và thế giới'),
(N'Kinh tế',        N'Kinh doanh, tài chính, quản trị');

-- Author
INSERT INTO Author (FullName, Country, BirthYear) VALUES
(N'Nguyễn Nhật Ánh',   N'Việt Nam', 1955),
(N'Nam Cao',            N'Việt Nam', 1917),
(N'Robert C. Martin',   N'Hoa Kỳ',  1952),
(N'Thomas H. Cormen',   N'Hoa Kỳ',  1956),
(N'Yuval Noah Harari',  N'Israel',   1976);

-- BookTitle
INSERT INTO BookTitle (Title, CategoryID, Publisher, PublishYear, ISBN) VALUES
(N'Cho tôi xin một vé đi tuổi thơ',  1, N'NXB Trẻ',          2008, '978-604-1-10001-1'),
(N'Chí Phèo',                         1, N'NXB Văn học',       1941, '978-604-1-10002-2'),
(N'Clean Code',                        3, N'Prentice Hall',     2008, '978-0-13-235088-4'),
(N'Introduction to Algorithms',        3, N'MIT Press',         2009, '978-0-262-03384-8'),
(N'Sapiens: Lược sử loài người',       4, N'NXB Tri Thức',      2014, '978-604-1-10005-5');

-- Book_Author
INSERT INTO Book_Author (BookID, AuthorID) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5);

-- BookCopy (mỗi đầu sách có 2-3 bản)
INSERT INTO BookCopy (BookID, Condition, IsAvailable) VALUES
(1, 'Good', 1), (1, 'Good', 1),
(2, 'Fair', 1), (2, 'Good', 1),
(3, 'Good', 1), (3, 'Good', 1), (3, 'Fair', 1),
(4, 'Good', 1), (4, 'Good', 1),
(5, 'Good', 1), (5, 'Damaged', 1);

-- Member
INSERT INTO Member (FullName, Email, Phone, Address, DOB) VALUES
(N'Trần Văn An',     'an.tv@fpt.edu.vn',   '0901234561', N'Hà Nội',     '2003-05-12'),
(N'Nguyễn Thị Bình', 'binh.nt@fpt.edu.vn', '0901234562', N'TP.HCM',     '2002-08-20'),
(N'Lê Minh Cường',   'cuong.lm@fpt.edu.vn','0901234563', N'Đà Nẵng',    '2003-11-03'),
(N'Phạm Thu Hà',     'ha.pt@fpt.edu.vn',   '0901234564', N'Cần Thơ',    '2004-01-15'),
(N'Hoàng Đức Mạnh',  'manh.hd@fpt.edu.vn', '0901234565', N'Hải Phòng',  '2002-07-30');

-- LibraryCard
INSERT INTO LibraryCard (MemberID, IssueDate, ExpiryDate, IsActive) VALUES
(1, '2024-01-10', '2026-01-10', 1),
(2, '2024-02-15', '2026-02-15', 1),
(3, '2024-03-01', '2026-03-01', 1),
(4, '2024-04-20', '2026-04-20', 1),
(5, '2023-09-05', '2025-09-05', 0);  -- thẻ đã hết hạn

-- Staff
INSERT INTO Staff (FullName, Email, Phone, Role) VALUES
(N'Đinh Thị Lan',    'lan.dt@library.vn', '0281234001', 'Librarian'),
(N'Bùi Quốc Hùng',   'hung.bq@library.vn','0281234002', 'Manager'),
(N'Vũ Thị Nga',      'nga.vt@library.vn', '0281234003', 'Librarian');

-- Borrowing
INSERT INTO Borrowing (MemberID, CopyID, StaffID, BorrowDate, DueDate, ReturnDate, Status) VALUES
(1, 1,  1, '2025-05-01', '2025-05-15', '2025-05-14', 'Returned'),  -- trả đúng hạn
(2, 3,  1, '2025-05-10', '2025-05-24', '2025-05-28', 'Returned'),  -- trả trễ 4 ngày
(3, 5,  3, '2025-06-01', '2025-06-15', NULL,          'Borrowing'), -- đang mượn
(4, 8,  3, '2025-04-01', '2025-04-15', '2025-04-20', 'Returned'),  -- trả trễ 5 ngày
(1, 10, 1, '2025-06-05', '2025-06-19', NULL,          'Borrowing'); -- đang mượn

-- Fine (chỉ các lần mượn trả trễ)
INSERT INTO Fine (BorrowID, DaysLate, FinePerDay, TotalAmount, IsPaid, PaidDate) VALUES
(2, 4, 2000.00,  8000.00, 1, '2025-05-28'),  -- đã nộp phạt
(4, 5, 2000.00, 10000.00, 0, NULL);           -- chưa nộp phạt

-- ============================================================
--  PHẦN TRUY VẤN MINH HOẠ (Demo Queries)
-- ============================================================

-- Q1: Danh sách tất cả sách kèm tác giả và thể loại
SELECT bt.Title, a.FullName AS Author, c.CategoryName, bt.PublishYear
FROM BookTitle bt
JOIN Book_Author ba ON bt.BookID = ba.BookID
JOIN Author a        ON ba.AuthorID = a.AuthorID
JOIN Category c      ON bt.CategoryID = c.CategoryID;

-- Q2: Sách hiện đang có sẵn trên kệ
SELECT bt.Title, COUNT(bc.CopyID) AS AvailableCopies
FROM BookCopy bc
JOIN BookTitle bt ON bc.BookID = bt.BookID
WHERE bc.IsAvailable = 1
GROUP BY bt.Title;

-- Q3: Các phiếu mượn đang trễ hạn (chưa trả & đã quá DueDate)
SELECT m.FullName AS Member, bt.Title, b.BorrowDate, b.DueDate,
       DATEDIFF(DAY, b.DueDate, GETDATE()) AS DaysOverdue
FROM Borrowing b
JOIN Member m    ON b.MemberID = m.MemberID
JOIN BookCopy bc ON b.CopyID   = bc.CopyID
JOIN BookTitle bt ON bc.BookID = bt.BookID
WHERE b.ReturnDate IS NULL AND b.DueDate < CAST(GETDATE() AS DATE);

-- Q4: Tổng tiền phạt chưa nộp theo từng độc giả
SELECT m.FullName, SUM(f.TotalAmount) AS TotalUnpaidFine
FROM Fine f
JOIN Borrowing b ON f.BorrowID  = b.BorrowID
JOIN Member m    ON b.MemberID  = m.MemberID
WHERE f.IsPaid = 0
GROUP BY m.FullName;

-- Q5: Thống kê số lần mượn theo từng độc giả
SELECT m.FullName, COUNT(b.BorrowID) AS TotalBorrows
FROM Member m
LEFT JOIN Borrowing b ON m.MemberID = b.MemberID
GROUP BY m.FullName
ORDER BY TotalBorrows DESC;
