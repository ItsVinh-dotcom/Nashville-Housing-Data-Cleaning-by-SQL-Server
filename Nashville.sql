/*
Cleaning data in SQL Queries
*/
Select *
From Nashville
-------------------------------------------------------
-- Standardlize date format

Select SaleDateConverted, CONVERT(date, SaleDate)
From Nashville


Update Nashville
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE Nashville
Add SaleDateConverted Date;


Update Nashville
SET SaleDateConverted = CONVERT(Date, SaleDate)

------------------------------------------------------
--Populate Property Address data

Select *
From Nashville
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashville a
Join Nashville b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashville a
Join Nashville b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

-------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From Nashville
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From Nashville



ALTER TABLE Nashville
Add PropertySplitAddress Nvarchar(255);


Update Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE Nashville
Add PropertySplitCity Nvarchar(255);


Update Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT * From Nashville



SELECT OwnerAddress 
From Nashville

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
From Nashville


ALTER TABLE Nashville
Add OwnerSplitAddress Nvarchar(255);


Update Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nashville
Add OwnerSplitCity Nvarchar(255);


Update Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE Nashville
Add OwnerSplitState Nvarchar(255);

Update Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT *
From Nashville


----------------------------------------------------------------------


--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville
Group by SoldAsVacant
Order by 1

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then '1'
	   When SoldAsVacant = 'N' Then '0'
	   END
From Nashville

UPDATE Nashville
SET SoldAsVacant = CASE When SoldAsVacant = '1' Then 'Y'
						When SoldAsVacant = '0' Then 'N'
						ELSE SoldAsVacant
						END

------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From Nashville
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

DELETE
From RowNumCTE
Where row_num > 1


-------------------------------------------------------

--Delete Unused Columns

Select *
From Nashville

ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Nashville
DROP COLUMN SaleDate

