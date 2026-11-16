
-- NovaStore E-Ticaret Veri Yonetim Sistemi
-- Kamp ve Outdoor Magazasi
-- Veritabani: NovaStoreDB
-- SQL Server 2025


-- BOLUM 1: VERITABANI VE TABLOLAR

-- Veritabaninin olusturulmasi

CREATE DATABASE NovaStoreDB;
GO

USE NovaStoreDB;
GO


-- Categories tablosu

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);
GO


-- Customers tablosu

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    City VARCHAR(20) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL
);
GO


-- Products tablosu
-- CategoryID ile Categories tablosuna baglaniyor.

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2),
    Stock INT DEFAULT 0,
    CategoryID INT,
    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID)
);
GO


-- Orders tablosu
-- Siparis tarihi girilmezse mevcut tarih kullanilir.

CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2),
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
);
GO


-- OrderDetails tablosu
-- Siparislerle urunler arasindaki baglantiyi tutar.

CREATE TABLE OrderDetails (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);
GO


-- BOLUM 2: ORNEK VERILER

-- 5 kategori ekleniyor.

INSERT INTO Categories (CategoryName)
VALUES
(N'Kamp Ekipmanları'),
(N'Doğa Yürüyüşü'),
(N'Outdoor Giyim'),
(N'Bisiklet Aksesuarları'),
(N'Termos ve Mataralar');
GO


-- 15 urun ekleniyor. Her kategoride 3 urun var.

INSERT INTO Products (ProductName, Price, Stock, CategoryID)
VALUES
(N'4 Kişilik Kamp Çadırı', 4500.00, 15, 1),
(N'Uyku Tulumu', 1250.00, 32, 1),
(N'Kamp Ocağı', 850.00, 18, 1),

(N'Trekking Çantası', 2200.00, 25, 2),
(N'Trekking Baton Seti', 950.00, 40, 2),
(N'Outdoor Mont', 3200.00, 12, 3),
(N'Termal İçlik', 780.00, 35, 3),

(N'Bisiklet Kaskı', 1650.00, 22, 4),
(N'Bisiklet Aydınlatma Seti', 620.00, 45, 4),

(N'Çelik Termos 1L', 890.00, 50, 5),
(N'Matara 750ml', 450.00, 60, 5),
(N'Termos Bardak', 590.00, 28, 5),

(N'Trekking Ayakkabısı', 2950.00, 14, 2),
(N'Su Geçirmez Yağmurluk', 1750.00, 27, 3),
(N'Bisiklet Eldiveni', 490.00, 33, 4);
GO


-- 6 farkli musterinin bilgileri ekleniyor.

INSERT INTO Customers (FullName, City, Email)
VALUES
(N'Ahmet Yılmaz', N'Ankara', 'ahmet@example.com'),
(N'Elif Kaya', N'Antalya', 'elif@example.com'),
(N'Mert Demir', N'İzmir', 'mert@example.com'),
(N'Zeynep Arslan', N'İstanbul', 'zeynep@example.com'),
(N'Burak Şahin', N'Bursa', 'burak@example.com'),
(N'Derya Çelik', N'Trabzon', 'derya@example.com');
GO


-- Farkli tarihlerde verilmis 10 siparis.
-- Toplam tutarlar siparis detaylarina gore hesaplandi.

INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
VALUES
(1, '20260904', 6200.00),
(2, '20260912', 5150.00),
(3, '20260921', 4760.00),
(4, '20261003', 2890.00),
(5, '20261011', 2230.00),
(6, '20261018', 3150.00),
(1, '20261025', 2600.00),
(3, '20261030', 4130.00),
(2, '20261104', 5390.00),
(5, '20261108', 2630.00);
GO


-- Siparislerdeki urunler ve satin alinan adetler.
-- Her sipariste birbiriyle ilgili urunler bulunuyor.

INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
VALUES
-- Kamp cadiri ve ocak
(1, 1, 1),
(1, 3, 2),

-- Trekking cantasi ve ayakkabi
(2, 4, 1),
(2, 13, 1),

-- Outdoor mont ve termal iclik
(3, 6, 1),
(3, 7, 2),

-- Bisiklet kaski ve aydinlatma
(4, 8, 1),
(4, 9, 2),

-- Termos ve matara
(5, 10, 2),
(5, 11, 1),

-- Uyku tulumu ve trekking batonu
(6, 2, 1),
(6, 5, 2),

-- Yagmurluk ve kamp ocagi
(7, 14, 1),
(7, 3, 1),

-- Termos bardak ve trekking ayakkabisi
(8, 12, 2),
(8, 13, 1),

-- Kamp cadiri ve termos
(9, 1, 1),
(9, 10, 1),

-- Bisiklet kaski ve eldiven
(10, 8, 1),
(10, 15, 2);
GO


-- BOLUM 3: SORGULAR VE RAPORLAR

-- Sorgu 1
-- Stogu 20'den az olan urunleri azalan sirada listeleme.

SELECT
    ProductName AS UrunAdi,
    Stock AS StokMiktari
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;
GO


-- Sorgu 2
-- Musterilerin siparis tarihleri ve tutarlari.

SELECT
    c.FullName AS MusteriAdi,
    c.City AS Sehir,
    o.OrderDate AS SiparisTarihi,
    o.TotalAmount AS ToplamTutar
FROM Customers c
INNER JOIN Orders o
    ON c.CustomerID = o.CustomerID
ORDER BY o.OrderDate;
GO


-- Sorgu 3
-- Ahmet Yilmaz'in aldigi urunlerin fiyatlari ve kategorileri.

SELECT
    c.FullName AS MusteriAdi,
    p.ProductName AS UrunAdi,
    p.Price AS Fiyat,
    cat.CategoryName AS KategoriAdi
FROM Customers c
INNER JOIN Orders o
    ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od
    ON o.OrderID = od.OrderID
INNER JOIN Products p
    ON od.ProductID = p.ProductID
INNER JOIN Categories cat
    ON p.CategoryID = cat.CategoryID
WHERE c.FullName = N'Ahmet Yılmaz'
ORDER BY o.OrderDate, od.DetailID;
GO


-- Sorgu 4
-- Her kategoride kac farkli urun oldugunu bulma.
-- LEFT JOIN sayesinde urunu olmayan kategoriler de gorunur.

SELECT
    c.CategoryName AS KategoriAdi,
    COUNT(p.ProductID) AS UrunSayisi
FROM Categories c
LEFT JOIN Products p
    ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY c.CategoryID;
GO


-- Sorgu 5
-- Musterilerin toplam harcamalarini hesaplama.
-- En cok harcayan musteri en ustte listelenir.

SELECT
    c.FullName AS MusteriAdi,
    COALESCE(SUM(o.TotalAmount), 0) AS ToplamCiro
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FullName
ORDER BY ToplamCiro DESC;
GO


-- Sorgu 6
-- Siparis tarihinden bugune kadar gecen gun sayisi.

SELECT
    OrderID AS SiparisID,
    OrderDate AS SiparisTarihi,
    DATEDIFF(DAY, OrderDate, GETDATE()) AS GecenGun
FROM Orders
ORDER BY OrderDate;
GO


-- BOLUM 4: VIEW VE YEDEKLEME

-- Siparis ozeti icin bir VIEW olusturuluyor.
-- Musteri, tarih, urun ve miktar bilgilerini birlestirir.

CREATE VIEW vw_SiparisOzet
AS
SELECT
    c.FullName AS MusteriAdi,
    o.OrderDate AS SiparisTarihi,
    p.ProductName AS UrunAdi,
    od.Quantity AS Adet
FROM Customers c
INNER JOIN Orders o
    ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od
    ON o.OrderID = od.OrderID
INNER JOIN Products p
    ON od.ProductID = p.ProductID;
GO


-- Olusturulan VIEW'in sonucu.

SELECT *
FROM vw_SiparisOzet
ORDER BY SiparisTarihi, UrunAdi;
GO


-- EK KONTROLLER

-- Tablo kayit sayilarini kontrol etme.

SELECT
    (SELECT COUNT(*) FROM Categories) AS KategoriSayisi,
    (SELECT COUNT(*) FROM Products) AS UrunSayisi,
    (SELECT COUNT(*) FROM Customers) AS MusteriSayisi,
    (SELECT COUNT(*) FROM Orders) AS SiparisSayisi,
    (SELECT COUNT(*) FROM OrderDetails) AS DetaySayisi;
GO


-- Toplam ciro ve satilan urun adedi.

SELECT
    (SELECT SUM(TotalAmount) FROM Orders) AS GenelCiro,
    (SELECT SUM(Quantity) FROM OrderDetails) AS SatilanUrunAdedi;
GO


-- Siparis tutarlariyla urun tutarlarini karsilastirma.
-- Sonuc bos gelirse tutarlar uyusuyor demektir.

SELECT
    o.OrderID,
    o.TotalAmount AS KayitliTutar,
    COALESCE(
        SUM(p.Price * od.Quantity), 0
    ) AS HesaplananTutar
FROM Orders o
LEFT JOIN OrderDetails od
    ON o.OrderID = od.OrderID
LEFT JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY o.OrderID, o.TotalAmount
HAVING o.TotalAmount <>
    COALESCE(SUM(p.Price * od.Quantity), 0);
GO


-- Veritabaninin tam yedegini alma.
-- Calistirmadan once C:\Yedek klasoru hazir olmali.

BACKUP DATABASE NovaStoreDB
TO DISK = N'C:\Yedek\NovaStoreDB.bak'
WITH
    NAME = N'NovaStoreDB Tam Yedek',
    STATS = 10;
GO

-- NovaStore SQL dosyasi sonu
