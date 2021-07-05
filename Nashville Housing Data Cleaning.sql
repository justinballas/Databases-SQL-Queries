select * from dbo.NashvilleHousing

--Standardize Date Format

Select SaleDate, convert(Date,SaleDate)
from dbo.NashvilleHousing

Update NashvilleHousing
set SaleDate = convert(Date,SaleDate)

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = convert(Date,SaleDate)

------- Populate Property address data

select PropertyAddress
from NashvilleHousing
where PropertyAddress is null

select * from NashvilleHousing
order by ParcelID

-------- ParcelID is the same when Address is the same, we can assume that ParcelIDs
-------- with nulls can be populated with addresses associated previously with the
-------- ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from NashvilleHousing
order by ParcelID

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

From NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
add PropertSplitCity Nvarchar(255);

Update NashvilleHousing
set PropertSplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select PropertySplitAddress, PropertSplitCity
from NashvilleHousing




select OwnerAddress
from NashvilleHousing


select
Parsename(replace(OwnerAddress, ',','.'),3),
Parsename(replace(OwnerAddress, ',','.'),2),
Parsename(replace(OwnerAddress, ',','.'),1)
from NashvilleHousing


ALTER TABLE NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = Parsename(replace(OwnerAddress, ',','.'),3)


ALTER TABLE NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = Parsename(replace(OwnerAddress, ',','.'),2)


ALTER TABLE NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = Parsename(replace(OwnerAddress, ',','.'),1)

select * from NashvilleHousing

------ Change Y and N to Yes and No in 'Sold as Vacant' field.

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end



-- Remove Duplicates

with RowNumCTE as (
select *,
 row_number() over (
	partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			order by 
				UniqueID
				) row_num

from NashVilleHousing
--order by ParcelID
)
delete
from RowNumCTE
Where row_num > 1
--order by PropertyAddress


--- Delete Unused Columns


alter table NashVilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress