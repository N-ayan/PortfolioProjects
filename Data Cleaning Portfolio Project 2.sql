-----------------------------------------------------------------------------
-- Cleaning Data In SQL Queries 

SELECT * 
FROM PortfolioProjects..NashvilleHousing

-----------------------------------------------------------------------------

--Standardize Date Format

UPDATE NashvilleHousing --not working
SET SaleDate = CONVERT(DATE, SaleDate) --not working

ALTER TABLE NashvilleHousing 
ADD SaleDateNew Date

UPDATE NashvilleHousing
SET SaleDateNew = CONVERT(DATE, SaleDate)

SELECT SaleDate, SaleDateNew
FROM PortfolioProjects..NashvilleHousing

-----------------------------------------------------------------------------

--Populate Property Address data

SELECT *
FROM PortfolioProjects..NashvilleHousing
WHERE PropertyAddress IS NULL

/* If there are two same parcel ID and one of them has property address then 
it's obvious that another parcel ID would also have same propert address*/
 

--isnull will check null values of property adrress of a
--and then update it with property address of b matching with parcel id
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------

-- Breaking out Address into Individual columns ( Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjects..NashvilleHousing

/* Query is going till ',' then removing it because of -1*/

ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing 
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress) )

SELECT * FROM NashvilleHousing

 
 -- Breaking out OwnerAddress into Individual columns ( Address, City, State)
 
ALTER TABLE NashvilleHousing
ADD OwnerAddressSplit NVARCHAR(255);


/*we can use parsename instead of substring. It is more easy to follow.
Parsename split text backwards and they use '.' for separation of text.*/

UPDATE NashvilleHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerAddressCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerAddressState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-----------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant".

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN  'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END



-----------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY 
	ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
		UniqueID
	) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-----------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
