/*

DATA CLEANING & DATA EXPLORATION :  SQL Queries

*/

--CHECK YOUR DATA/FINAL TABLE : 

SELECT  *
FROM HousingData.dbo.NashvilleHousing

SELECT  COUNT(*)
FROM HousingData.dbo.NashvilleHousing

--MAKE CORRECTIONS : 
ALTER TABLE HousingData.dbo.NashvilleHousing
DROP COLUMN SaleDateConverted, PropertySpitAddress, PropertySPlitAddress, PropertySplitCity;


ALTER TABLE HousingData.dbo.NashvilleHousing
DROP COLUMN PropertySpitAddress;
--------------------------------------------------------------------------------------------------------------------------

--STEP 1 :  Standardize Date Format 


--The Date-Column  shows DATETIME FORMAT but, it  serves "No Purpose" in this context to show the Time.
--So, It is a lenghthy format which is Unnecessary to store. 
 --Hence, we will COnvert this Column from  DATETIME  to DATE  FORMAT. 

SELECT SaleDate
FROM HousingData.dbo.NashvilleHousing;

--Check if Conversion From 'DateTime' into 'Date' Works.
SELECT SaleDate, CONVERT(Date,SaleDate) AS PureDate
FROM HousingData.dbo.NashvilleHousing;



--ADD  New Column  that will be used to store 'Converted Dates'.
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

--UPDATE  New Column  with 'Converted Dates' VALUES
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);



 --------------------------------------------------------------------------------------------------------------------------

--STEP 2 : Populate Property Address data (FIX NULL VALUES)

SELECT PropertyAddress 
FROM HousingData.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL;


SELECT * 
FROM HousingData.dbo.NashvilleHousing
ORDER BY ParcelID;



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingData.dbo.NashvilleHousing a
JOIN HousingData.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;



UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingData.dbo.NashvilleHousing a
JOIN HousingData.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


--------------------------------------------------------------------------------------------------------------------------



-- STEP 3 : Breaking out "PropertyAddress" into Individual Columns (ADDRESS & CITY ) : 


--PROBLEM : WE HAVE THE COLUMN  "PropertyAddress"  with 2 PIECES OF DATA SEPEARATED BY A DELIMITER ','  
--			BUT THIS 2 DATA COULD BE SEPERATED IN 2 DIFF. COLUMNS.  SO, HERE IS THE PROCESS TO DO SO :


--1) CHK THE COLUMN FIRST : 
SELECT PropertyAddress 
FROM HousingData.dbo.NashvilleHousing ;



--2) SLICE THE PART  UNTIL ',' TO CHK IF IT PRINTS CORRECTLY :
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) AS ADDRESS ,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) AS CITY
FROM HousingData.dbo.NashvilleHousing ;


-- CREATE 1ST COLUMN FOR 'Address1' : 

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1);



-- CREATE 2nd COLUMN FOR 'Address2' : 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress));


--CHK BOTH COLUMNS : 
SELECT  PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing;

SELECT *
FROM NashvilleHousing;

--NOW, THESE DIVIDED COLUMNS ARE MUCH MORE USEFUL FOR DATA-ANALYSIS THAN THE 'OLD COLUMN' --> 'Address'.
--NOW THAT WE SPLIT THEM INTO 'ADDRESS' & 'CITY', THEY ARE VERY MUCH USEFUL.


-- STEP 4:  Breaking out "OwnerAddress" into Individual Columns (ADDRESS, CITY, STATE)


SELECT OwnerAddress 
FROM HousingData.dbo.NashvilleHousing ;


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM HousingData.dbo.NashvilleHousing ;



-- CREATE ALL 3 COLUMNS FOR ADDRESS, CITY,  & STATE : 

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);




ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);




ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);
 
 
--CHK ALL 3 COLUMNS : 
SELECT  OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing;

SELECT *
FROM NashvilleHousing;
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE  WHEN SoldAsVacant = 'N' THEN  'No'
	  WHEN SoldAsVacant = 'Y' THEN  'Yes'
	  ELSE SoldAsVacant
END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE  WHEN SoldAsVacant = 'N' THEN  'No'
	  WHEN SoldAsVacant = 'Y' THEN  'Yes'
	  ELSE SoldAsVacant
END

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--REMOVE DUPLICATES 

WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
					       UniqueID
						   ) row_num
FROM HousingData.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE 
WHERE row_num > 1
ORDER BY PropertyAddress;

--DELETE
--FROM RowNumCTE 
--WHERE row_num > 1;




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns (R)

SELECT * 
FROM HousingData.dbo.NashvilleHousing

 
--THIS COUNTS THE NUMBER OF COLUMNS IN MSSQL :

SELECT COUNT(*) AS Housing_Data_Columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NashvilleHousing'
  AND TABLE_SCHEMA = 'dbo';



ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

--DEALING WITH "NULL" VALUES : 

--🔎 Summary of Your Situation:
--Total records: ~56,373

--Records with OwnerName IS NULL: 31,158 (~55% of your data)

--The table shows that these rows often also have other NULL fields, but not always. Some have valid values 
--like SalePrice, PropertySplitAddress, PropertySplitCity, etc.

--Deleting all 31,158 rows just because OwnerName is NULL would mean removing over half of your dataset,
--and some of those rows still have useful info (like Sale Price, Parcel ID, etc.).

SELECT *
FROM NashvilleHousing
WHERE OwnerName IS NULL;

SELECT COUNT(*)
FROM NashvilleHousing
WHERE OwnerName IS NULL;
-- 31,158 RECORDS

SELECT COUNT(*) 
FROM HousingData.dbo.NashvilleHousing
-- 56,373 RECORDS



--Use this if you want to keep all rows but make the NULL values meaningful:

UPDATE NashvilleHousing
SET OwnerName = 'Unknown'
WHERE OwnerName IS NULL;






-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

