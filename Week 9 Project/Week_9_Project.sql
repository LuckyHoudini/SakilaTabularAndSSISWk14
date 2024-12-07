-- Drop the procedure if it exists
IF OBJECT_ID('dbo.PopulateFactRental', 'P') IS NOT NULL
    DROP PROCEDURE dbo.PopulateFactRental;
GO

-- Create the stored procedure
CREATE PROCEDURE PopulateFactRental
AS
BEGIN
    -- Insert new records into FactRental
    INSERT INTO dbo.FactRental (
        RentalID,
		FilmKey,
		CategoryKey,
		LanguageKey,
		CustomerKey,
		StoreKey,
        RentalDateKey,
        ReturnDateKey,
        RentalDuration,
        RentalCost,
        RentalCount
    )
    SELECT
        r.rental_id AS RentalID,
		df.Filmkey,
		dc.CategoryKey,
		dl.LanguageKey,
		dcu.CustomerKey,
		ds.StoreKey,
        CAST(CONVERT(varchar(8), r.rental_date, 112) AS int) AS RentalDateKey,
        CAST(CONVERT(varchar(8), r.return_date, 112) AS int) AS ReturnDateKey,
        DATEDIFF(DAY, r.rental_date, r.return_date) AS RentalDuration,
        p.amount AS RentalCost,
        1 AS RentalCount 
    FROM Sakila.dbo.rental AS r
    JOIN Sakila.dbo.inventory AS i ON r.inventory_id = i.inventory_id
    JOIN Sakila.dbo.film AS f ON f.film_id = i.film_id
    JOIN Sakila.dbo.film_category AS fc ON f.film_id = fc.film_id
    JOIN Sakila.dbo.category AS c ON c.category_id = fc.category_id
    JOIN Sakila.dbo.payment AS p ON r.rental_id = p.rental_id
	JOIN SakilaDW.dbo.DimFilm AS df ON df.FilmID = f.film_id
    JOIN SakilaDW.dbo.DimCategory AS dc ON dc.CategoryID = c.category_id
    JOIN SakilaDW.dbo.DimLanguage AS dl ON dl.LanguageID = f.language_id
    JOIN SakilaDW.dbo.DimCustomer AS dcu ON dcu.CustomerID = r.customer_id
    JOIN SakilaDW.dbo.DimStore AS ds ON ds.StoreID = i.store_id
	WHERE r.return_date IS NOT NULL; 
END;