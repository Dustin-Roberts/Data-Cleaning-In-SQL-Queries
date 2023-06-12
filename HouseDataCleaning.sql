/*

Cleaning Data in SQL Queries

Skills used: CTE's, Windows Functions, SUBSTRING, CONVERT, ISNULL, 
	CHARINDEX, LEN, PARSENAME, REPLACE, ROW_NUMBER, COUNT

*/

Select *
From DataCleaningProject..NashvilleHousing


-- REMOVING TIMESTAMP FROM DATE COLUMN

Select SaleDate, CONVERT(Date, SaleDate)
From DataCleaningProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From DataCleaningProject..NashvilleHousing


-- POPULATE PROPERTY ADDRESS DATA
Select *
From DataCleaningProject..NashvilleHousing
Order By ParcelID


-- Finding Properties without address data
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningProject..NashvilleHousing a
Join DataCleaningProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Updating property address into correct column
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningProject..NashvilleHousing a
Join DataCleaningProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Checking to make sure property addresses have been populated
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningProject..NashvilleHousing a
Join DataCleaningProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- BREAKING PROPERTYADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY)

Select PropertyAddress
From DataCleaningProject..NashvilleHousing

-- Finding Substring before and after comma delimeter using CHARINDEX
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From DataCleaningProject..NashvilleHousing

-- Altering table to include new columns
ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

-- Populating new columns for Address and City
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- Checking that data was populated correctly
Select *
From DataCleaningProject..NashvilleHousing


-- BREAKING OWNER ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY)

Select OwnerAddress
From DataCleaningProject..NashvilleHousing

-- Finding Substrings using PARSENAME and REPLACE
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From DataCleaningProject..NashvilleHousing

-- Altering table to include new columns
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

-- Populating new columns for Address and City
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Checking that data was populated correctly
Select *
From DataCleaningProject..NashvilleHousing


-- CHANGING Y AND N TO YES AND NO IN SOLDASVACANT COLUMN

-- Checking how many Y and N vs Yes and No
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaningProject..NashvilleHousing
Group By SoldAsVacant
Order By 2

-- Changing Y and N to Yes and No with CASE and When/Else statements
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End
From DataCleaningProject..NashvilleHousing


-- Updating SoldAsVacant field
Update NashvilleHousing
SET SoldAsVacant = 
	   CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End
From DataCleaningProject..NashvilleHousing

-- Checking if update worked correctly
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaningProject..NashvilleHousing
Group By SoldAsVacant
Order By 2


-- REMOVING DUPLICATES

-- Finding Duplicates and Deleting by using CTE and Partitioning
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By UniqueID
				 ) row_num

From DataCleaningProject..NashvilleHousing
)
DELETE 
From RowNumCTE
Where row_num > 1


-- DELETING UNUSED COLUMNS

ALTER TABLE DataCleaningProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From DataCleaningProject..NashvilleHousing