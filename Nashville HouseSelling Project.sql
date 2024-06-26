--Cleaning Data in SQL Queries

SELECT * FROM PortfolioProject..NashvilleHousing

--Standarize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate) FROM PortfolioProject..NashvilleHousing
UPDATE NashvilleHousing SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address Data
SELECT * FROM PortfolioProject..NashvilleHousing order by ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress,
ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
Join PortfolioProject..NashvilleHousing B
on A.ParcelID = B.ParcelID and A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
Join PortfolioProject..NashvilleHousing B
on A.ParcelID = B.ParcelID and A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

--Breaking out Address into individual Columns (Address, City, State)

SELECT PropertyAddress FROM PortfolioProject..NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT * FROM PortfolioProject..NashvilleHousing

--**************************

SELECT OwnerAddress FROM PortfolioProject..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * FROM PortfolioProject..NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant " field
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER()OVER(
PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
--DELETE
SELECT * FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--DELETE UNUSED COLUMNS

SELECT * FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate