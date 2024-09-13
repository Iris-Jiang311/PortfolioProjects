SELECT *
FROM dbo.NashvilleHousing

-- Standarize the Date Format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted DATE

UPDATE NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted,  CONVERT(Date, SaleDate)
From NashvilleHousing

-- Populate Property Address data
-- 1. find PropertyAddress is NULL
Select *
From NashvilleHousing
Where PropertyAddress is NULL
-- 2. Parcel ID refer to the same property
-- if the Parcel ID has address can be the same as the Property Address
Select *
From NashvilleHousing
Order BY ParcelID
--  Join table self together
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL


-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
From NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)) as Address
FROM NashvilleHousing

-- 1. find the comma, and select the string before the comma
SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)) as Address, CHARINDEX(',',PropertyAddress)
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address
FROM NashvilleHousing

-- 2. separate full PropertyAddress into 2 columns
SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as Address
FROM NashvilleHousing

Alter TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)


Alter TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))

SELECT * FROM NashvilleHousing

-- OwnerAddress
SELECT OwnerAddress FROM NashvilleHousing

SELECT 
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)  ,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)  ,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
FROM NashvilleHousing;


Alter TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

Alter TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

Alter TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 

SELECT *
FROM NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant
From NashvilleHousing

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE when SoldAsVacant ='Y' Then 'Yes'
        when SoldAsVacant = 'N' Then 'No'
        else SoldAsVacant
        END
FROM NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE when SoldAsVacant ='Y' Then 'Yes'
                        when SoldAsVacant = 'N' Then 'No'
                        else SoldAsVacant
                        END


-- Remove duplicates
--  CTE: is like a temp table

WITH RowNumCTE AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID
    ) row_num
    FROM NashvilleHousing
    -- Order BY ParcelID
)


-- DELETE FROM RowNumCTE
-- WHERE row_num >1

Select * FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress

-- Delete Unused Columns
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate