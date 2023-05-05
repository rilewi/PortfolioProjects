--Data Cleaning

SELECT *
FROM PortfolioProject2..NashvilleHousing


--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject2..NashvilleHousing

UPDATE PortfolioProject2..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) 

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject2..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



--Populate Property Address data, NULLS

SELECT *
FROM PortfolioProject2..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Separate PropertyAddress into individual columns

SELECT PropertyAddress
FROM PortfolioProject2..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))AS Address
FROM PortfolioProject2..NashvilleHousing


ALTER TABLE PortfolioProject2..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject2..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD PropertySplitCity1 Nvarchar(255);

UPDATE PortfolioProject2..NashvilleHousing
SET PropertySplitCity1 = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject2..NashvilleHousing



--Separate Owner Address into individual columns

SELECT OwnerAddress
FROM PortfolioProject2..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject2..NashvilleHousing


ALTER TABLE PortfolioProject2..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject2..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD OwnerSplitCity1 Nvarchar(255);

UPDATE PortfolioProject2..NashvilleHousing
SET OwnerSplitCity1 = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject2..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



--Change Y and N to Yes and NO in "Sold as Vancant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject2..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject2..NashvilleHousing

UPDATE PortfolioProject2..NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
		UniqueID
		) row_num

FROM PortfolioProject2..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num >1



--Delete Unused Columns

SELECT *
FROM PortfolioProject2..NashvilleHousing

ALTER TABLE PortfolioProject2..NashvilleHousing
DROP COLUMN PropertySplitCity
