--Cleaning Data in SQL Queries
Select* 
FROM PortfolioProject..NashvilleHousing

--Change Sale Date

Select SaleDateConverted, Convert(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)




--Populate Property Address data 

Select *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID] <> b.[UniqueID] 
Where a.PropertyAddress is null


UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID] <> b.[UniqueID] 
	 WHERE a.PropertyAddress is null


--Dividing Address into multiple columns (Address, City, State)

Select PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD  PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select*
FROM PortfolioProject..NashvilleHousing




Select OwnerAddress
FROM PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD  OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD  OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 




Select*
FROM PortfolioProject..NashvilleHousing




--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




--Remove Duplicates

WITH RowNumCTE as(
Select*,
       ROW_NUMBER() over (
       Partition by ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
				    UniqueID
					) row_num
	                

FROM PortfolioProject..NashvilleHousing
)

Select*
FROM RowNumCTE
WHERE row_num > 1 




--Deleted Unused Columns




Select*
FROM PortfolioProject..NashvilleHousing

ALTER TABLE	PortfolioProject..NashvilleHousing
DROP COLUMN  PropertyAddresS, OwnerAddress, TaxDistrict

ALTER TABLE	PortfolioProject..NashvilleHousing
DROP COLUMN  SaleDate